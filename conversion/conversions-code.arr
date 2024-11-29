use context essentials2021

provide: get-art-in-4 end

include my-gdrive("conversions-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.
import tables as T
include string-dict

data Conversion:
  | conversion(from-cur :: String, to-cur :: String, rate :: Option<Number>)
end

type ConversionMap = StringDict<StringDict<Option<Number>>>

fun try-set(conversion-map :: ConversionMap, from-cur :: String, 
    to-cur :: String, rate :: Option<Number>):
  doc: ```attempt to set conversion rate from from-cur to to-cur. if there is an existing rate that 
       disagrees with the new rate, set the rate to none to indicate invalid conversion```
  if (conversion-map.has-key(from-cur)):
    from-cur-map = conversion-map.get-value(from-cur)
    if (from-cur-map.has-key(to-cur)):
      prior-rate = from-cur-map.get-value(to-cur)
      if (prior-rate == rate): # no need to change anything
        conversion-map 
      else: # different rates from same conversion so set to none
        conversion-map.set(from-cur, from-cur-map.set(to-cur, none)) 
      end
    else: # no previous rate to check
      conversion-map.set(from-cur, from-cur-map.set(to-cur, rate))
    end
  else: # no previous rate to check
    conversion-map.set(from-cur, [string-dict: to-cur, rate])
  end
where:
  # adding new from-cur entry works
  try-set([string-dict: ], "a", "b", some(2)) 
    is [string-dict: "a", [string-dict: "b", some(2)]]
  # adding identical entry works
  try-set([string-dict: "a", [string-dict: "b", some(2)]], "a", "b", some(2))
    is [string-dict: "a", [string-dict: "b", some(2)]]
  # adding new to-cur entry works
  try-set([string-dict: "a", [string-dict: "b", some(2)]], "a", "c", some(3))
    is [string-dict: "a", [string-dict: "b", some(2), "c", some(3)]]
  # adding not identical entry works
  try-set([string-dict: "a", [string-dict: "b", some(2)]], "a", "b", some(3)) 
    is [string-dict: "a", [string-dict: "b", none]]
end

fun try-multiply(maybe-num-1 :: Option<Number>, maybe-num-2 :: Option<Number>) -> Option<Number>:
  doc: "try to multiply to option numbers" 
  cases (Option) maybe-num-1:
    | none => none
    | some(num-1) => 
      cases (Option) maybe-num-2:
        | none => none
        | some(num-2) =>
          some(num-1 * num-2)
      end
  end
where:
  try-multiply(some(2), some(3)) is some(6)
  try-multiply(some(2), none) is none
  try-multiply(none, some(3)) is none
  try-multiply(none, none) is none
end

fun try-inverse(maybe-num :: Option<Number>):
  doc: "try to take the inverse of a number"
  cases (Option) maybe-num:
    | none => none
    | some(num) => 
      if (num == 0):
        none
      else:
        some(1 / num)
      end
  end
where:
  try-inverse(some(0)) is none
  try-inverse(some(2)) is some(1 / 2)
  try-inverse(none) is none
end

fun compose-conversions(a-conversion :: Conversion, original-map :: ConversionMap) -> ConversionMap:
  doc: "adds all conversions obtainable by composing a-conversion with another conversion"
  if (original-map.has-key(a-conversion.to-cur)):
    # get all conversions that can be chained onto a-conversion for a new conversion
    to-cur-map = original-map.get-value(a-conversion.to-cur)
    to-cur-map.keys().to-list().foldl({(to-cur, new-map):
        second-rate = to-cur-map.get-value(to-cur)
        combined-rate = try-multiply(a-conversion.rate, second-rate)
        # add composed conversion
        updated-map = try-set(new-map, a-conversion.from-cur, to-cur, combined-rate)
        # add inverse conversion as well
        try-set(updated-map, to-cur, a-conversion.from-cur, try-inverse(combined-rate))}, 
      original-map)
  else:
    # nothing to add
    original-map
  end
where:
  # empty works
  compose-conversions(conversion("a", "b", some(2)), [string-dict: ])
    is [string-dict: ]
  compose-conversions(conversion("a", "b", some(2)), [string-dict: "b", [string-dict: ]])
    is [string-dict: "b", [string-dict: ]]
  # basic composition works
  compose-conversions(conversion("a", "b", some(2)), [string-dict: 
      "b", [string-dict: "c", some(3)]])
    is [string-dict: "b", [string-dict: "c", some(3)], 
    "a", [string-dict: "c", some(6)], 
    "c", [string-dict: "a", some(1 / 6)]]
  # composition with multiple conversions works
  compose-conversions(conversion("a", "b", some(2)), [string-dict: 
      "b", [string-dict: "c", some(3), "d", some(5)]])
    is [string-dict:  
    "a", [string-dict: "c", some(6), "d", some(10)], 
    "b", [string-dict: "c", some(3), "d", some(5)],
    "c", [string-dict: "a", some(1 / 6)],
    "d", [string-dict: "a", some(1 / 10)]]
  # composition with a contradicting existing conversion replaces with none
  compose-conversions(conversion("a", "b", some(2)), [string-dict: 
      "b", [string-dict: "c", some(3)],
      "c", [string-dict: "a", some(7)]])
      is [string-dict: 
    "a", [string-dict: "c", some(6)],
    "b", [string-dict: "c", some(3)],
    "c", [string-dict: "a", none]]
end

# this is a helper that should never be run on its own 
# and is only seperated from get-all-conversions for code clarity
fun relax-conversions(original-map :: ConversionMap) -> ConversionMap:
  doc: "adds all conversions obtainable by composing two conversions"
  # loop over all starting currency
  conversions-list = original-map.keys().to-list().map({(from-cur):
      # loop over all ending currency
      original-map.get-value(from-cur).keys().to-list().map({(to-cur):
          conversion(from-cur, to-cur, original-map.get-value(from-cur).get-value(to-cur))
        }) 
    }).foldl({(main-list, inner-list): # flatten nested lists
      main-list.append(inner-list)
    }, empty)
  
  conversions-list.foldl({(a-conversion, conversion-map): 
      compose-conversions(a-conversion, conversion-map)}, original-map)
where:
  relax-conversions([string-dict: ]) is [string-dict: ]
  relax-conversions([string-dict: "a", [string-dict: "b", some(2)]]) is [string-dict:
    "a", [string-dict: "b", some(2)]]
  # cannot test fully as .keys().to-list() is not guaranteed to be in the same order
  # thus compose-conversions may be exectued in different order and since 
  # compose-conversions is non-commutative the result can be different
  # refer to get-all-conversions tests
end

fun get-all-conversions(cc :: Table) -> ConversionMap:
  doc: ```given a table of individual conversions find all possible composed conversions```
  initial-map = cc.all-rows().foldl({(row, conversion-map):
      from-c = row.get-value("from-c")
      to-c = row.get-value("to-c")
      conv-rate = some(row.get-value("conv-rate"))
      # add conversion to map
      updated-map = try-set(conversion-map, from-c, to-c, conv-rate)
      # add inversion conversion to map
      try-set(updated-map, to-c, from-c, try-inverse(conv-rate))
    }, [string-dict: ])
  
  # repeat a number of times equal to the number of currencies
  range(0, initial-map.keys().to-list().length()).foldl({(_, conversion-map):
      relax-conversions(conversion-map)}, 
    initial-map)
where:
  test-table-empty = table: from-c, to-c, conv-rate
  end
  get-all-conversions(test-table-empty) is [string-dict: ]
  
  
  test-table-single = table: from-c, to-c, conv-rate
    row: "a", "b", 2
  end
  get-all-conversions(test-table-single) is [string-dict:
    "a", [string-dict: "a", some(1), "b", some(2)],
    "b", [string-dict: "a", some(1 / 2), "b", some(1)]]
  
  test-table-multiple = table: from-c, to-c, conv-rate
    row: "a", "b", 2
    row: "b", "a", 1 / 2
    row: "a", "c", 3
    row: "a", "d", 5
  end
  get-all-conversions(test-table-multiple) is [string-dict:
    "a", [string-dict: "a", some(1), "b", some(2), "c", some(3), "d", some(5)],
    "b", [string-dict: "a", some(1 / 2), "b", some(1), "c", some(3 / 2), "d", some(5 / 2)],
    "c", [string-dict: "a", some(1 / 3), "b", some(2 / 3), "c", some(1), "d", some(5 / 3)],
    "d", [string-dict: "a", some(1 / 5), "b", some(2 / 5), "c", some(3 / 5), "d", some(1)]]
  
  test-table-contradiction = table: from-c, to-c, conv-rate
    row: "a", "b", 2
    row: "b", "c", 3
    row: "a", "c", 4
    row: "a", "d", 5
    row: "e", "f", 6
  end
  get-all-conversions(test-table-contradiction) is [string-dict:
    "a", [string-dict: "a", none, "b", none, "c", none, "d", none],
    "b", [string-dict: "a", none, "b", none, "c", none, "d", none],
    "c", [string-dict: "a", none, "b", none, "c", none, "d", none],
    "d", [string-dict: "a", none, "b", none, "c", none, "d", none],
    "e", [string-dict: "e", some(1), "f", some(6)], 
    "f", [string-dict: "e", some(1 / 6), "f", some(1)]]
end

fun only-one<T>(li :: List<T>) -> Option<T>:
  doc: ```if there is exactly one element in the list
       return that element. Otherwise, return none```
  cases (List) li:
    | empty => none
    | link(f, r) => 
      cases (List) r:
        | empty => some(f)
        | link(_, _) => none
      end
  end
where:
  only-one(empty) is none
  only-one([list: 1]) is some(1)
  only-one([list: 1, 2]) is none
  only-one([list: "", "", "", "", "", ""]) is none
end

fun get-art-in-4(art :: Table, cc :: Table, art-id :: Number, currency :: String) -> Number:
  doc: ```get art with composed currency conversions. 
       if there are mutliple paths which disagree throw an error```
  conversion-map = get-all-conversions(cc)
  art-row-option = only-one(art.all-rows().filter({(row): row.get-value("id") == art-id}))
  cases (Option) art-row-option:
    | none => raise("duplicate or missing entry in art lookup")
    | some(art-row) => 
      cost = art-row.get-value("cost")
      from-c = art-row.get-value("currency")
      ask:
        | conversion-map.has-key(from-c) and conversion-map.get-value(from-c).has-key(currency)
          then: 
          rate-option = conversion-map.get-value(from-c).get-value(currency)
          cases (Option) rate-option:
            | none => raise("multiple or undefined rates for currency conversion")
            | some(rate) => cost * rate
          end
        | from-c == currency
          then: cost
        | otherwise: raise("no conversion exists")
      end
  end
end