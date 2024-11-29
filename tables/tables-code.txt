use context essentials2021

provide: get-art-in-1, get-art-in-2, get-art-in-3 end

include my-gdrive("tables-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.
import gdrive-sheets as GS
import tables as T

fun row-match<T>(col :: String, value :: T) -> (Row -> Boolean):
  doc: "returns a predicate that tests if a row has a value in a column"
  {(row): row.get-value(col) == value}
where:
  row-match("id", 1)(art-table.row(1, 0, "")) is true
  row-match("id", 1)(art-table.row(0, 0, "")) is false
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

fun get-art-in-1(art :: Table, cc :: Table, art-id :: Number, currency :: String) -> Number:
  doc: ```get the price of an art piece with given id assuming that 
       there is exactly one entry with the art-id and exactly one entry
       with the conversion factor```
  art-row = art.filter(row-match("id", art-id)).row-n(0)

  cost = art-row.get-value("cost")
  from-c = art-row.get-value("currency")

  if (from-c == currency):
    cost
  else:
    currency-row = cc.filter(row-match("from-c", from-c))
      .filter(row-match("to-c", currency)).row-n(0)

    conv-rate = currency-row.get-value("conv-rate")

    cost * conv-rate
  end
end

fun get-art-in-2(art :: Table, cc :: Table, art-id :: Number, currency :: String) -> Number:
  doc: ```get the price of an art piece with given id and raise exceptions 
       if the necessary information is missing or duplicated```
  art-row-option = only-one(art.filter(row-match("id", art-id)).all-rows())
  cases (Option) art-row-option:
    | none => raise("duplicate or no entries in art lookup")
    | some(art-row) => 
      cost = art-row.get-value("cost")
      from-c = art-row.get-value("currency")

      if (from-c == currency):
        cost
      else:
        cur-row-option = only-one(cc
            .filter(row-match("from-c", from-c))
            .filter(row-match("to-c", currency)).all-rows())

        cases (Option) cur-row-option:
          | none => raise("duplicate or no entries in currency lookup")
          | some(cur-row) =>
            conv-rate = cur-row.get-value("conv-rate")

            cost * conv-rate
        end
      end
  end
end

fun get-art-in-3(art :: Table, cc :: Table, art-id :: Number, currency :: String) -> Number:
  doc: ```get the price of an art piece with given id and include backward
       currency conversions, raising exceptions if the necessary information 
       is missing or duplicated, or the inverse conversion requires a division
       by 0.```
  art-row-option = only-one(art.filter(row-match("id", art-id)).all-rows())
  cases (Option) art-row-option:
    | none => raise("duplicate or no entries in art lookup")
    | some(art-row) => 
      cost = art-row.get-value("cost")
      from-c = art-row.get-value("currency")

      if (from-c == currency):
        cost
      else:
        cur-row-option = only-one(cc
            .filter(row-match("from-c", from-c))
            .filter(row-match("to-c", currency)).all-rows())

        cases (Option) cur-row-option:
          | none => 
            inv-row-option = only-one(cc
                .filter(row-match("from-c", currency))
                .filter(row-match("to-c", from-c)).all-rows())
            cases (Option) inv-row-option:
              | none => raise("duplicate or no entires in currency lookup")
              | some(inv-row) =>
                inv-rate = inv-row.get-value("conv-rate")

                if (inv-rate == 0):
                  raise("division by zero error")
                else:
                  cost / inv-rate
                end
            end
          | some(cur-row) =>
            conv-rate = cur-row.get-value("conv-rate")

            cost * conv-rate
        end
      end
  end
end

# titanic helper code
data Pair<A, B>:
  | pair(first :: A, second :: B)
end

fun concat<T>(l1 :: List<T>, l2 :: List<T>) -> List<T>:
  doc: "Concatenates two lists into a single list preserving order"
  l1.foldr(lam(elem, acc): link(elem, acc) end, l2)
where:
  concat(empty, empty) is empty
  concat(empty, [list: 1]) is [list: 1]
  concat([list: 1], empty) is [list: 1]
  concat([list: 1, 2], [list: 3, 4, 5]) is [list: 1, 2, 3, 4, 5]
end

fun flatten<T>(list-of-lists :: List<List<T>>) -> List<T>:
  doc: "Flattens a list of lists of elements into a list of elements."
  list-of-lists.foldl(lam(elem, acc): concat(acc, elem) end, empty)
where:
  flatten(empty) is empty
  flatten([list: empty]) is empty
  flatten([list: [list: 1]]) is [list: 1]
  flatten([list: [list: 1, 2], [list: 0], [list: 6, 7, 8]]) is [list: 1, 2, 0, 6, 7, 8]
end

fun increment<T>(li :: List<Pair<T, Number>>, elem :: T) -> List<Pair<T, Number>>:
  doc: "Increment the count associated with an element in an list counting occurances"
  li-contains-elem = li.foldl(lam(a-pair, acc): acc or (a-pair.first == elem) end, false)
  if (li-contains-elem):
    li.map(lam(a-pair): 
        if (a-pair.first == elem):
          pair(a-pair.first, a-pair.second + 1)
        else:
          a-pair
        end
      end)
  else:
    link(pair(elem, 1), li)
  end
where:
  increment(empty, "a") is [list: pair("a", 1)]
  increment([list: pair("a", 1)], "a") is [list: pair("a", 2)]
  increment([list: pair("b", 1)], "a") is [list: pair("a", 1), pair("b", 1)]
  increment([list: pair("a", 1), pair("b", 1)], "a") is [list: pair("a", 2), pair("b", 1)]
end

fun count<T>(li :: List<T>) -> List<Pair<T, Number>>:
  doc: "Count the number of occurances of each element in a list"
  li.foldl(lam(elem, acc): increment(acc, elem) end, empty)
where:
  count(empty) is empty
  count([list: "a"]) is [list: pair("a", 1)]
  count([list: "a", "a"]) is [list: pair("a", 2)] 
  count([list: "b", "a"]) is [list: pair("a", 1), pair("b", 1)]
  count([list: "b", "a", "a", "b", "a"]) is [list: pair("a", 3), pair("b", 2)]
end

fun insert<T>(elem :: T, sorted-list :: List<T>, compare :: (T, T -> Boolean)) -> List<T>:
  doc: "insert an element into a sorted list based on a comparator"
  cases (List) sorted-list:
    | empty => [list: elem]
    | link(f, r) => 
      if (compare(elem, f)): 
        link(elem, sorted-list)
      else:
        link(f, insert(elem, r, compare))
      end
  end
where:
  insert(2, empty, {(x, y): x <= y}) is [list: 2]
  insert(2, [list: 1, 2, 3], {(x, y): x <= y}) is [list: 1, 2, 2, 3]
  insert(0, [list: 1, 2, 3], {(x, y): x <= y}) is [list: 0, 1, 2, 3]
  insert(4, [list: 1, 2, 3], {(x, y): x <= y}) is [list: 1, 2, 3, 4]
  insert(2, [list: 3, 2, 1], {(x, y): x >= y}) is [list: 3, 2, 2, 1]
end

fun sorted<T>(unsorted-list :: List<T>, compare :: (T, T -> Boolean)) -> List<T>:
  doc: "sort a list based on a comparator"
  unsorted-list.foldl({(elem, sorted-list): 
      insert(elem, sorted-list, compare)}, empty)
where:
  sorted(empty, {(x, y): x <= y}) is empty
  sorted([list: 0], {(x, y): x <= y}) is [list: 0]
  sorted([list: 2, 3, 1, 2], {(x, y): x <= y}) is [list: 1, 2, 2, 3]
  sorted([list: 2, 3, 1, 2], {(x, y): x >= y}) is [list: 3, 2, 2, 1]
end

fun strip-first-name(full-name :: String) -> String:
  doc: "obtains the first name from a passenger's full name"
  cases (List) string-split-all(full-name, " "):
    | empty => raise("invalid passenger name")
    | link(_, title-removed) => 
      cases (List) title-removed:
        | empty => raise("invalid passenger name")
        | link(first-name, _) => 
          if (string-index-of(first-name, "(") == 0):
            string-substring(first-name, 1, string-length(first-name))
          else:
            first-name
          end
      end
  end
where:
  strip-first-name("M. A B") is "A"
  strip-first-name("") raises "invalid"
  strip-first-name("M.") raises "invalid"
  strip-first-name("Abc Def Ghi") is "Def"
  strip-first-name("M. (AA BB") is "AA"
end

fun top-n<T>(sorted-list :: List<Pair<T, Number>>, n :: Number) -> List<T>:
  doc: ```takes a sorted list of pairs and a positive integer n,
       return the first n elements if they exist,
       possibly including more if there is a tie for nth place```
  if (n <= 0): 
    empty
  else:
    cases (List) sorted-list:
      | empty => empty
      | link(f, r) =>
        highest = f.second
        # accumulate a pair of tied elements List<T> and 
        # remaining elements List<Pair<T, Number>>
        tied = sorted-list.foldr(lam(elem, acc): 
            if (elem.second == highest): 
              # if tied with highest, add to tied elements in accumulator
              pair(link(elem.first, acc.first), acc.second)
            else:
              # otherwise, add to remaining elements in accumulator
              pair(acc.first, link(elem, acc.second))
            end
          end, pair(empty, empty))
        next-n = n - tied.first.length()
        concat(tied.first, top-n(tied.second, next-n))
    end
  end
where:
  top-n([list: pair("A", 0)], 1) is [list: "A"]
  top-n([list: pair("A", 0), pair("B", 0)], 1) is [list: "A", "B"]
  top-n([list: pair("A", 0), pair("C", -1)], 1) is [list: "A"]
  top-n([list: pair("A", 0), pair("B", 0), pair("C", -1)], 1) is [list: "A", "B"]
  top-n([list: pair("A", 0), pair("B", 0), pair("C", -1)], 2) is [list: "A", "B"]
  top-n([list: pair("A", 0), pair("C", -1)], 2) is [list: "A", "C"]
  top-n([list: pair("A", 0), pair("C", -1), pair("D", -1)], 2) is [list: "A", "C", "D"]
  top-n([list: pair("A", 0)], 2) is [list: "A"]
  top-n(empty, 1) is empty
  top-n(empty, -1) is empty
  top-n([list: pair("A", 0)], -1) is empty
end

fun calculate-titanic(titanic-data :: Table):
  doc: "calculate top male names, female names, and titles"
  block:
    # Find top titanic male names
    titanic-male = sieve titanic-data using sex:
      sex == "male"
    end

    titanic-male-name = titanic-male.get-column("raw-name")
      .map(strip-first-name)
    count-titanic-male = sorted(count(titanic-male-name), 
      {(pair1, pair2): pair1.second >= pair2.second})
    print(top-n(count-titanic-male, 7))

    # Find top titanic female names
    titanic-female = sieve titanic-data using sex:
      sex == "female"
    end

    titanic-female-name = titanic-female.get-column("raw-name")
      .map(strip-first-name)
    count-titanic-female = sorted(count(titanic-female-name), 
      {(pair1, pair2): pair1.second >= pair2.second})
    print(top-n(count-titanic-female, 7))

    # Find top titanic titles 
    titanic-title = titanic-data.get-column("raw-name")
      .map(lam(name): 
        cases (List) string-split-all(name, "."):
          | empty => raise("invalid passenger name")
          | link(f, _) => f
        end
      end)
    count-titanic-title = sorted(count(titanic-title), 
      {(pair1, pair2): pair1.second >= pair2.second})
    
    print(count-titanic-title)
  end
end

titanic-raw-loader = 
  GS.load-spreadsheet("1ZqZWMY_p8rvv44_z7MaKJxLUI82oaOSkClwW057lr3Q")

titanic-raw = load-table:
  survived :: Number,
  pclass :: Number,
  raw-name :: String,
  sex :: String,
  age :: Number,
  sib-sp :: Number,
  par-chil :: Number,
  fare :: Number
  source: titanic-raw-loader.sheet-by-name("titanic", true)
end

calculate-titanic(titanic-raw)