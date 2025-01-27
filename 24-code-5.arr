use context starter2024
include string-dict
fun highest-count() -> Number:
  doc: ```Computes the highest number of configurations that compute to the same result```

  cards = [list: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] # all possible values of cards
  operation = [list: 0, 1, 2, 3] # all possible operations, 1 for add, 2 for multiply

  # diff functions for each operation, matches the index
  operation-funcs = [list: 
    lam(a :: Number, b :: Number): some(a + b) end,
    lam(a :: Number, b :: Number): some(a - b) end,
    lam(a :: Number, b :: Number): some(a * b) end,
    lam(a :: Number, b :: Number): if b == 0: none else: some(a / b) end end
    # prevents divide by 0 error by returning a large negative number that will
    # gaurantee the wrong calculation
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

  # since there are 4 cards of each number and 3 cards of each operation
  # we dont have to keep track of which ones are used up.

  # brute force using septuple loop - loop through all possible combination
  target-to-count = fold(lam(cnt, fi-c) block: # first card

      fold(lam(cnt1, fo): # first operator

          fold(lam(cnt2, se-c): # second card

              fold(lam(cnt3, so): # second operator

                  fold(lam(cnt4, th-c): # third card

                      fold(lam(cnt5, to): # third operator

                          fold(lam(cnt6, fo-c) block: # fourth card

                              try-increment(cnt6, calc(fi-c, se-c, th-c, fo-c, 
                                  fo, so, to, operation-funcs))

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

fun try-increment(a-dict :: StringDict<Number>, key-option :: Option<Number>) -> StringDict<Number>:
  doc: "increment the value in a dictionary associated with a option key, ignoring if key is none"
  cases (Option) key-option:
    | none => a-dict
    | some(result) => 
      key = num-to-string(result)
      prior = if a-dict.has-key(key): a-dict.get-value(key) else: 0 end
      a-dict.set(key, prior + 1)
  end
where:
  try-increment([string-dict: ], none) is [string-dict: ]
  try-increment([string-dict: ], some(1)) is [string-dict: "1", 1]
  try-increment([string-dict: "1", 2, "3", 4], some(1)) is [string-dict: "1", 3, "3", 4]
  try-increment([string-dict: "1", 2, "3", 4], some(5)) is [string-dict: "1", 2, "3", 4, "5", 1]
end