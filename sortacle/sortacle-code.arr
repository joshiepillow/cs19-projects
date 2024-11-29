use context essentials2021
include shared-gdrive("sortacle-definitions.arr", "1d6n7TSAQa_aTEqLyTXjHxFsdrQAt_lyq")

provide: generate-input, is-valid, oracle end

include my-gdrive("sortacle-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.

fun is-inc(li :: List<Number>) -> Boolean:
  doc: "Checks if a list of numbers is increasing"
  cases (List) li:
    | empty => true
    | link(f, r) => cases (List) r:
        | empty => true
        | link(rf, rr) => (f <= rf) and is-inc(r)
      end
  end
where:
  is-inc(empty) is true
  is-inc([list: 0]) is true
  is-inc([list: 0, 1, 2, 3, 4, 5]) is true
  is-inc([list: 1, 0]) is false
  is-inc([list: 0, 1, 2, 3, 5, 4]) is false
  is-inc([list: 0, 1, 2, 4, 3, 5]) is false
end

fun remove-first<T>(li :: List<T>, elem :: T) -> List<T>:
  doc: "Remove the first occurance of an element in a list if it exists."
  cases (List) li:
    | empty => empty
    | link(f, r) => 
      if (f == elem): 
        r
      else:
        link(f, remove-first(r, elem))
      end
  end
where:
  remove-first(empty, 0) is empty
  remove-first([list: 1], 0) is [list: 1]
  remove-first([list: 1, 2, 3], 0) is [list: 1, 2, 3]
  remove-first([list: 1, 2, 3], 1) is [list: 2, 3]
  remove-first([list: 1, 2, 3], 2) is [list: 1, 3]
  remove-first([list: 1, 2, 3], 3) is [list: 1, 2]
  remove-first([list: 0, 1, 2, 1, 3, 1], 1) is [list: 0, 2, 1, 3, 1]
end

fun same-contents<T>(l1 :: List<T>, l2 :: List<T>) -> Boolean:
  doc: "Checks if two lists contain the same elements with the same repetitions"
  l1.foldl(lam(t, acc):
      cases (Option) acc:
        | none => none
        | some(li) =>
          if (li.member(t)):
            some(remove-first(li, t))
          else:
            none
          end
      end
    end, some(l2)) == some(empty)
where:
  same-contents(empty, empty) is true
  same-contents([list: 1], empty) is false
  same-contents(empty, [list: 1]) is false
  same-contents([list: 1], [list: 1]) is true
  same-contents([list: 1], [list: 1, 1]) is false
  same-contents([list: 1, 1], [list: 1]) is false
  same-contents([list: 1, 2, 2], [list: 1, 1, 2]) is false
  same-contents([list: 1, 2, 1], [list: 1, 1, 2]) is true
end

fun flatten<T>(list-of-lists :: List<List<T>>) -> List<T>:
  doc: "Flattens a list of lists of elements into a list of elements."
  list-of-lists.foldl({(elem, acc): concat(acc, elem)}, empty)
where:
  flatten(empty) is empty
  flatten([list: empty]) is empty
  flatten([list: [list: 1]]) is [list: 1]
  flatten([list: [list: 1, 2], [list: 0], [list: 6, 7, 8]]) is [list: 1, 2, 0, 6, 7, 8]
end

fun generate-input(n :: Number) -> List<Person>:
  doc: "Generate a list of random persons of length n"
  generate-list(n, lam(_):
      person(string-from-code-points(generate-list(num-random(10), lam(_): 
              num-random(65536) 
            end)), num-random(100))
    end)
end

fun is-valid(original :: List<Person>, sorted :: List<Person>) -> Boolean: 
  doc: "Checks if a list of persons is a sorted version of another list of persons"
  same-contents(original, sorted) and is-inc(sorted.map({(pers): pers.age}))
end

fun oracle(sorter :: (List<Person> -> List<Person>)) -> Boolean:
  doc: "Checks if a given sort function is correct on an array of tests"
  fixed-cases = [list:
    # check edge cases
    empty,
    [list: person("", 0)],
    [list: person("a", 0)],
    [list: person("a", 0), person("a", 0)],
    [list: person("a", 0), person("A", 0)],
    
    # check varying order and capitalization  
    [list: person("a", 1), person("A", 0)],
    [list: person("a", 0), person("A", 1)],
    [list: person("A", 1), person("a", 0)],
    [list: person("A", 0), person("a", 1)],
    [list: person("a", 1), person("A", 0), person("a", 0), person("A", 1)],
    [list: person("aa", 1), person("ab", 0), person("ba", 0)],
    [list: person("ab", 0), person("ba", 0), person("aa", 1)],
    
    # check varying name length
    [list: person("asdf", 10), person("a", 11)],
    [list: person("a", 11), person("asdf", 10)],
    [list: person("asdf", 11), person("a", 10)],
    [list: person("a", 10), person("asdf", 11)],
    
    # check long names and non natural number ages
    [list: person("ba", 7.928), person("aa", 100000), person("", -5.4444), person("a a a a a a a a a a a a a a a a a a a a ba ba ba ba ba ba ba ba ba ba ba", 67), person("hi", -10), person("hi", 10), person("!@#$%^&*()1234567890QWERTYUIOPASDFGHJKL:ZXCVBNM<>?:\"{}|~", 65), person("", 65.5), person("John John", 65)]
  ]
  test-cases = concat(fixed-cases, generate-list(100, {(n): generate-input(n)}))
  test-cases.map({(test): is-valid(test, sorter(test))}).foldl(
    {(b1, b2): b1 and b2}, true)
end