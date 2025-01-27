use context starter2024
include string-dict

# The original code computed all 10 * 4 * 10 * 4 * 10 * 4 * 10 combinations of 4 cards and 3 
# operations. 
# However, this count includes evaluations that are repeated. For instance, if we set the 
# computation between the third and fourth cards to 1 + 1, 2 * 1, 2 / 1, etc. which all evaluate to 
# 2, subsequent evaluations involving the first and second card would be unnecessarily 
# repeated. 
# In order to avoid this, at each partial evaluation, I consolidated all computed values into a 
# StringDict, such that every dictionary key was a computed value and the corresponding dictionary
# value represented the number of ways to reach that computed value.
# Thus in the example of 1 + 1, 2 * 1, 2 / 1, etc., rather than considering the cases separately, we
# would have a single {key, value} pair consiting of {2, 16} for the 16 ways to obtain 
# a value of 2 using two cards and one operation. 
# The time save here cannot be easily represented using big O notation, as the time saved depends on
# the average number of collisions between the output of partial evaluations. However, after timing 
# both the original and new implementations with a helper function, we see an improvement from
# ~4700 to ~550, or about an 8.5x improvement. 

fun highest-count-fast() -> Number:
  doc: ```Computes the highest number of configurations that compute to the same result, quickly```

  cards = range(1, 11)

  operation-funcs = [list: 
    lam(a :: Number, b :: Number): some(a + b) end,
    lam(a :: Number, b :: Number): some(a - b) end,
    lam(a :: Number, b :: Number): some(a * b) end,
    lam(a :: Number, b :: Number): if b == 0: none else: some(a / b) end end
  ]

  one-card = apply-once(cards, [string-dict: "0", 1], [list: operation-funcs.get(0)])
  two-card = apply-once(cards, one-card, operation-funcs)
  three-card = apply-once(cards, two-card, operation-funcs)
  four-card = apply-once(cards, three-card, operation-funcs)

  max = four-card.keys().to-list().map(four-card.get-value(_)).foldl(
    lam(a, b): 
      if (a > b): a
      else: b
      end
    end, 0)
  max
  # code for computing *which* targets attain the maximum
  # four-card.keys().to-list().filter(lam(key): four-card.get-value(key) == max end)
where:
  highest-count-fast() is 9283
end

fun highest-count() -> Number:
  doc: ```Computes the highest number of configurations that compute to the same result```

  cards = [list: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] # all possible values of cards
  operation = [list: 0, 1, 2, 3] # all possible operations, 1 for add, 2 for multiply

  operation-funcs = [list: 
    lam(a :: Number, b :: Number): some(a + b) end,
    lam(a :: Number, b :: Number): some(a - b) end,
    lam(a :: Number, b :: Number): some(a * b) end,
    lam(a :: Number, b :: Number): if b == 0: none else: some(a / b) end end
  ]

  fun calc(fi-c :: Number, se-c :: Number, th-c :: Number, fo-c :: Number,
      fo :: Number, so :: Number, to :: Number, 
      funcs :: List<(Number, Number -> Option<Number>)>) -> Option<Number>:
    doc: ```Given the first, second, third, fourth card value and all 
         the operations - return the calculated value. Uses right 
         associativity```
    cases (Option) (funcs.get(to))(th-c, fo-c):
      | none => none
      | some(c34) => 
        cases (Option) (funcs.get(so))(se-c, c34):
          | none => none
          | some(c234) => 
            (funcs.get(fo))(fi-c, c234)
        end
    end
  where:
    calc(1, 1, 1, 1, 1, 1, 1, operation-funcs) is some(0)
    calc(3, 7, 5, 2, 2, 1, 2, operation-funcs) is some(-9)
    calc(7, 7, 5, 8, 2, 0, 1, operation-funcs) is some(28)
  end

  target-to-count = fold(lam(cnt, fi-c) block: # first card
      fold(lam(cnt1, fo): # first operator
          fold(lam(cnt2, se-c): # second card
              fold(lam(cnt3, so): # second operator
                  fold(lam(cnt4, th-c): # third card
                      fold(lam(cnt5, to): # third operator
                          fold(lam(cnt6, fo-c) block: # fourth card
                              try-increment(cnt6, calc(fi-c, se-c, th-c, fo-c, 
                                  fo, so, to, operation-funcs), 1)
                            end, cnt5, cards)
                        end, cnt4, operation)
                    end, cnt3, cards)
                end, cnt2, operation)
            end, cnt1, cards)
        end, cnt, operation)
    end, [string-dict: ], cards)
  
  max = target-to-count.keys().to-list().map(target-to-count.get-value(_)).foldl(
      lam(a, b): 
        if (a > b): a
        else: b
        end
      end, 0)
  max
  # code for computing *which* targets attain the maximum
  # target-to-count.keys().to-list().filter(lam(key): target-to-count.get-value(key) == max end)
where:
  highest-count() is 9283
end

fun time<T>(func :: (-> T)) -> Number:
  doc: "time a function"
  start = time-now()
  _ = func()
  time-now() - start
end

fun try-increment(a-dict :: StringDict<Number>, key-option :: Option<Number>, count :: Number) 
  -> StringDict<Number>:
  doc: "increment the value in a dictionary associated with a option key, ignoring if key is none"
  cases (Option) key-option:
    | none => a-dict
    | some(result) => 
      key = num-to-string(result)
      prior = if a-dict.has-key(key): a-dict.get-value(key) else: 0 end
      a-dict.set(key, prior + count)
  end
where:
  try-increment([string-dict: ], none, 1) is [string-dict: ]
  try-increment([string-dict: ], some(1), 1) is [string-dict: "1", 1]
  try-increment([string-dict: "1", 2, "3", 4], some(1), 5) is [string-dict: "1", 7, "3", 4]
  try-increment([string-dict: "1", 2, "3", 4], some(5), 1) is [string-dict: "1", 2, "3", 4, "5", 1]
end

fun apply-once(left-side :: List<Number>, right-side-with-count :: StringDict<Number>, 
    binary-ops :: List<(Number, Number -> Number)>) -> StringDict<Number>:
  doc: ```count the number of combinations of a left hand value, a right hand value, 
       and a binary operation, accounting for multiplicity in the right hand values```
  result-count-pairs-nested = right-side-with-count.keys().to-list().map(lam(rhs):
      binary-ops.map(lam(op):
          left-side.map(lam(lhs):
        {op(lhs, string-to-number(rhs).value); right-side-with-count.get-value(rhs)} end) end) end)
  result-count-pairs = result-count-pairs-nested.foldl(append, empty).foldl(append, empty)
  
  result-count-pairs.foldl(lam(pair, result-count-dict):
      {result; count} = pair
      try-increment(result-count-dict, result, count)
    end, [string-dict: ])
where:
  apply-once(empty, [string-dict: ], empty) is [string-dict: ]
  apply-once(empty, [string-dict: "1", 2, "3", 4], 
    [list: lam(a :: Number, b :: Number): some(a + b) end]) is [string-dict: ]
  apply-once([list: 0, 2], [string-dict: ], 
    [list: lam(a :: Number, b :: Number): some(a + b) end]) is [string-dict: ]
  apply-once([list: 0, 2], [string-dict: "1", 2, "3", 4], 
    empty) is [string-dict: ]
  apply-once([list: 0, 2], [string-dict: "1", 2, "3", 4], 
    [list: lam(a :: Number, b :: Number): some(a + b) end]) is [string-dict: "1", 2, "3", 6, "5", 4]
end

time(highest-count)
time(highest-count-fast)