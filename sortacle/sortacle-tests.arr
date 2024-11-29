use context essentials2021
include shared-gdrive("sortacle-definitions.arr", "1d6n7TSAQa_aTEqLyTXjHxFsdrQAt_lyq")

include my-gdrive("sortacle-common.arr")
import generate-input, is-valid, oracle
from my-gdrive("sortacle-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

fun correct-sorter(people :: List<Person>) -> List<Person>:
  doc: ```Consumes a list of people and produces a list of people
       that are sorted by age in ascending order.```
  sort-by(people,
    lam(p1, p2): p1.age < p2.age end,
    lam(p1, p2): p1.age == p2.age end)
where:
  cjordan3 = person("Connor", 18)
  cli135   = person("Danny", 65)
  kreyes7  = person("Kyle", 32)
  correct-sorter(empty) is empty
  correct-sorter([list: cli135]) is [list: cli135]
  correct-sorter([list: cli135, cjordan3]) is [list: cjordan3, cli135]
  correct-sorter([list: cjordan3, cli135]) is [list: cjordan3, cli135]
  correct-sorter([list: cjordan3, cli135, kreyes7])
    is [list: cjordan3, kreyes7, cli135]
end

fun bad-sort(people :: List<Person>) -> List<Person>:
  sort-by(people, {(p1, p2): p1.age > p2.age}, {(p1, p2): p1.age == p2.age})
end

fun bad-sort2(people :: List<Person>) -> List<Person>:
  people
end

fun bad-sort3(people :: List<Person>) -> List<Person>:
  cases (List) people:
    | empty => empty
    | link(f, r) => link(f, correct-sorter(r))
  end
end

fun bad-sort4(people :: List<Person>) -> List<Person>:
  cases (List) people:
    | empty => [list: person("", 0)]
    | link(f, r) => correct-sorter(people)
  end
end

fun bad-sort5(people :: List<Person>) -> List<Person>:
  correct-sorter(people).foldl(lam(elem, acc): 
      if acc.member(elem):
        acc
      else:
        link(elem, acc)
      end
    end, empty)
end

fun bad-sort6(people :: List<Person>) -> List<Person>:
  li = correct-sorter(people)
  cases (List) li:
    | empty => empty
    | link(f, r) => link(f, li)
  end
end

fun bad-sort7(people :: List<Person>) -> List<Person>:
  li = bad-sort5(people)
  cases (List) li:
    | empty => empty
    | link(f, r) => 
      concat(generate-list(people.length() - li.length(), {(_): f}), li)
  end
end

check "generate-input creates list of correct length":
  generate-input(0) is empty
  generate-input(1).length() is 1
  generate-input(10).length() is 10
  generate-input(100).length() is 100
end

check "is-valid works with empty lists":
  is-valid(empty, empty) is true
  is-valid([list: person("", 1)], empty) is false
  is-valid(empty, [list: person("", 1)]) is false
end

check "is-valid works when varying lengths of both inputs":
  is-valid([list: person("", 1)], [list: person("", 1)]) is true
  is-valid([list: person("", 1)], [list: person("a", 1)]) is false
  is-valid([list: person("", 1), person("a", 1)], 
    [list: person("a", 1), person("", 1)]) is true
  is-valid([list: person("", 0), person("a", 1)], 
    [list: person("a", 1), person("", 0)]) is false
  is-valid([list: person("", 0), person("a", 1)], 
    [list: person("a", 0), person("", 1)]) is false
end

check "verify that oracle works on correct sort":
  oracle(correct-sorter) is true
end

check "verify that oracle weeds out incorrect sorts":
  oracle(bad-sort) is false
  oracle(bad-sort2) is false
  oracle(bad-sort3) is false
  oracle(bad-sort4) is false
  oracle(bad-sort5) is false
  oracle(bad-sort6) is false
  oracle(bad-sort7) is false
end