use context starter2024
fun generate-pool<T>(alphabet :: List<T>, repeats :: Number) -> List<T>:
  doc: "generate a pool consisting of a given number of repetitions of each element in an alphabet"
  cases (List) alphabet:
    | empty => empty
    | link(f, r) => repeat(repeats, f).append(generate-pool(r, repeats))
  end
where:
  generate-pool(empty, 0) is empty
  generate-pool(empty, 10) is empty
  generate-pool(range(0, 10), 0) is empty
  generate-pool(range(1, 6), 1) is [list: 1, 2, 3, 4, 5]
  generate-pool(range(1, 4), 3) is [list: 1, 1, 1, 2, 2, 2, 3, 3, 3]
end

fun remove-one<T>(pool :: List<T>, element :: T) -> List<T>:
  doc: "remove one occurance of an element from a list"
  cases (List) pool:
    | empty => empty
    | link(f, r) => 
      if (f == element):
        r
      else:
        link(f, remove-one(r, element))
      end
  end
where:
  remove-one(empty, 1) is empty
  remove-one([list: 0], 1) is [list: 0]
  remove-one([list: 1], 1) is empty
  remove-one([list: 0, 1, 2], 1) is [list: 0, 2]
  remove-one([list: 1, 1, 1], 1) is [list: 1, 1]
end

fun generate-permutations<T>(pool :: List<T>, perm-length :: T) -> List<List<T>>:
  doc: "generate all distinct permutations of a given length of elements from a pool"
  if (perm-length > 0): 
    distinct(pool).map({(elem): 
        generate-permutations(remove-one(pool, elem), perm-length - 1)
          .map({(perm):
            link(elem, perm)})})
      .foldl(append, empty)
  else:
    [list: empty]
  end
where:
  generate-permutations(empty, 0) is [list: empty]
  generate-permutations(empty, 1) is empty
  generate-permutations([list: 1], 0) is [list: empty]
  generate-permutations([list: 1], 1) is [list: [list: 1]]
  generate-permutations([list: 1, 1, 2, 2], 2) is [list: 
    [list: 2, 2,], [list: 2, 1], [list: 1, 2], [list: 1, 1]]
end

data Operation:
  | add
  | sub
  | mul
  | div
end

fun evaluate-permutation(num-perm :: List<Number>, op-perm :: List<Operation>) -> Option<Number>:
  doc: ```calculate the value of a configuration made of n numbers and n - 1 operations, 
       given in two seperate lists```
  cases (List) op-perm:
    | empty => cases (List) num-perm:
        | empty => none
        | link(f-num, r-num) => some(f-num)
      end
    | link(f-op, r-op) => cases (List) num-perm:
        | empty => none
        | link(f-num, r-num) => 
          rest-option = evaluate-permutation(r-num, r-op)
          cases (Option) rest-option:
            | none => none
            | some(rest-result) => 
              cases (Operation) f-op:
                | add => some(f-num + rest-result)
                | sub => some(f-num - rest-result)
                | mul => some(f-num * rest-result)
                | div => if (rest-result == 0):
                    none
                  else:
                    some(f-num / rest-result)
                    end
              end
          end
      end
  end
where:
  evaluate-permutation(empty, empty) is none
  evaluate-permutation(empty, [list: add]) is none
  evaluate-permutation([list: 1], empty) is some(1)
  evaluate-permutation([list: 1, 2], [list: add]) is some(3)
  evaluate-permutation([list: 1, 2, 3, 4, 5], [list: add, sub, mul, div]) is some(3/5)
end

fun how-many-24-5-2() -> Number:
  doc: ```calculate the number of 4 card 3 operation configurations that result in a value of 24, 
       where the cards are between 1 and 5, and the operations come from the set {add, mul}```
  number-alphabet = generate-pool(range(1, 6), 4)
  operation-alphabet = generate-pool([list: add, mul], 3)
  number-perms = generate-permutations(number-alphabet, 4)
  operation-perms = generate-permutations(operation-alphabet, 3)
  number-perms.map({(num-perm): 
      operation-perms.map({(op-perm):
          cases (Option) evaluate-permutation(num-perm, op-perm):
            | none => 0
            | some(v) => if (v == 24): 1 else: 0 end
          end})
        .foldl({(a, b): a + b}, 0)
    
    })
    .foldl({(a, b): a + b}, 0)
end