use context starter2024
fun how-many-24-10-4() -> Number:
  doc: ```Determine how many configurations have values of 24.
       Configuration: four cards of value 1-5, and three cards of addition
       and multiplication.```
  
  cards = [list: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] # all possible values of cards
  operation = [list: 0, 1, 2, 3] # all possible operations, 1 for add, 2 for multiply
  
  # diff functions for each operation, matches the index
  operation-funcs = [list: 
    lam(a :: Number, b :: Number): a + b end,
    lam(a :: Number, b :: Number): a - b end,
    lam(a :: Number, b :: Number): a * b end,
    lam(a :: Number, b :: Number): if b == 0: -99999999 else: a / b end end
    # prevents divide by 0 error by returning a large negative number that will
    # gaurantee the wrong calculation
  ]
  
  fun calc(fi-c :: Number, se-c :: Number, th-c :: Number, fo-c :: Number,
      fo :: Number, so :: Number, to :: Number, 
      funcs :: List<(Number, Number -> Number)>) -> Number:
    doc: ```Given the first, second, third, fourth card value and all 
         the operations - return the calculated value. Uses right 
         associativity```
    c34 = (funcs.get(to))(th-c, fo-c)
    c234 = (funcs.get(so))(se-c, c34)
    c1234 = (funcs.get(fo))(fi-c, c234)
    
    c1234
  where:
    calc(1, 1, 1, 1, 1, 1, 1, operation-funcs) is 0
    calc(3, 7, 5, 2, 2, 1, 2, operation-funcs) is -9
    calc(7, 7, 5, 8, 2, 0, 1, operation-funcs) is 28
  end
  
  # since there are 4 cards of each number and 3 cards of each operation
  # we dont have to keep track of which ones are used up.
  
  # brute force using septuple loop - loop through all possible combination
  fold(lam(cnt, fi-c) block: # first card
    
      fold(lam(cnt1, fo): # first operator

          fold(lam(cnt2, se-c): # second card

              fold(lam(cnt3, so): # second operator

                  fold(lam(cnt4, th-c): # third card

                      fold(lam(cnt5, to): # third operator
                          
                          fold(lam(cnt6, fo-c) block: # fourth card
                              
                              if calc(fi-c, se-c, th-c, fo-c, 
                                  fo, so, to, operation-funcs)
                                  == 24:
                                cnt6 + 1
                              else:
                                cnt6
                              end

                            end, cnt5, cards)
                          
                        end, cnt4, operation)
                      
                    end, cnt3, cards)

                end, cnt2, operation)
              
            end, cnt1, cards)

        end, cnt, operation)
      
    end, 0, cards)
where:
  how-many-24-10-4() is 3865
end