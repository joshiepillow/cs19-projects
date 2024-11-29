use context essentials2021
include shared-gdrive("oracle-definitions.arr", "1VIj7v7L2Qy8FSRO7dh2uZki_a1NDTFxh")

include my-gdrive("oracle-common.arr")
import is-valid, oracle
from my-gdrive("oracle-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of
# implementation-specific details (e.g., helper functions).
import sets as sets
type Set = sets.Set

test-companies = [list: [list: 2, 1, 0], [list: 2, 0, 1], [list: 1, 2, 0]]
test-candidates = [list: [list: 1, 2, 0], [list: 2, 1, 0], [list: 2, 0, 1]]

fun evil-matcher(companies :: List<List<Number>>,
    candidates :: List<List<Number>>) -> Set<Hire>:
  doc: "calls evil-matcher-helper and converts output to set"
  sets.list-to-set(evil-matcher-helper(0, companies, candidates))
where:
  evil-matcher(test-companies, test-candidates)
    is [sets.set: hire(0, 2), hire(1, 2), hire(2, 1)]
end

fun evil-matcher-for-cands(companies :: List<List<Number>>,
    candidates :: List<List<Number>>) -> Set<Hire>:
  doc: "calls evil-matcher-helper and converts output to set"
  sets.list-to-set(evil-matcher-for-cands-helper(0, companies, candidates))
where:
  evil-matcher-for-cands(test-companies, test-candidates)
    is [sets.set: hire(2, 2), hire(2, 1), hire(1, 0)]
end

fun evil-matcher-helper(index :: Number, companies :: List<List<Number>>,
    candidates :: List<List<Number>>) -> List<Hire>:
  doc: ```assigns each company its first preference regardless if that candidate
       has already been assigned```
  cases (List) companies:
    | empty => empty
    | link(f, r) =>
      link(hire(index, f.first), evil-matcher-helper(index + 1, r, candidates))
  end
where:
  evil-matcher-helper(0, test-companies, test-candidates)
    is [list: hire(0, 2), hire(1, 2), hire(2, 1)]
end

fun evil-matcher-for-cands-helper(index :: Number, companies :: List<List<Number>>,
    candidates :: List<List<Number>>) -> List<Hire>:
  doc: ```assigns each candidate its first preference regardless if that company
       has already been assigned```
  cases (List) candidates:
    | empty => empty
    | link(f, r) =>
      link(hire(f.first, index), evil-matcher-for-cands-helper(index + 1, companies, r))
  end
where:
  evil-matcher-for-cands-helper(0, test-companies, test-candidates)
    is [list: hire(1, 0), hire(2, 1), hire(2, 2)]
end

fun dumb-matcher-helper(index :: Number, companies :: List<List<Number>>,
    candidates :: List<List<Number>>) -> List<Hire>:
  doc: "matches company 0 to candidate 0, 1 to 1, etc..."
  cases (List) companies:
    | empty => empty
    | link(f, r) =>
      link(hire(index, index), dumb-matcher-helper(index + 1, r, companies))
  end
where:
  dumb-matcher-helper(0, test-companies, test-candidates)
    is [list: hire(0, 0), hire(1, 1), hire(2, 2)]
end

fun dumb-matcher(companies :: List<List<Number>>,
    candidates :: List<List<Number>>) -> Set<Hire>:
  doc: "calls dumb-matcher-helper and converts output to set"
  sets.list-to-set(dumb-matcher-helper(0, companies, candidates))
where:
  dumb-matcher(test-companies, test-candidates)
    is [sets.set: hire(0, 0), hire(1, 1), hire(2, 2)]
end

check "is-valid accepts stable pairings":
  is-valid([list: [list: 0]], 
    [list: [list: 0]], 
    [sets.list-set: hire(0, 0)]) is true
  is-valid([list: [list: 0, 1], [list: 1, 0]],
    [list: [list: 0, 1], [list: 1, 0]],
    [sets.set: hire(0, 0), hire(1, 1)]) is true
  is-valid([list: [list: 0, 1, 2], [list: 1, 0, 2], [list: 2, 0, 1]],
    [list: [list: 2, 0, 1], [list: 0, 1, 2], [list: 1, 2, 0]],
    [sets.set: hire(0, 0), hire(1, 1), hire(2, 2)]) is true
end
check "is-valid rejects illegal matches":
  is-valid([list: [list: 1, 0], [list: 0, 1]],
    [list: [list: 1, 0], [list: 0, 1]],
    [sets.set: hire(0, 1), hire(1, 1)]) is false
end
check "is-valid rejects unstable pairings":
  is-valid([list: [list: 1, 0], [list: 0, 1]],
    [list: [list: 1, 0], [list: 0, 1]],
    [sets.set: hire(0, 0), hire(1, 1)]) is false
  is-valid([list: [list: 0, 1], [list: 1, 0]],
    [list: [list: 0, 1], [list: 1, 0]],
    [sets.set: hire(0, 1), hire(1, 0)]) is false
end

check "oracle accepts valid matchmaker":
  oracle(matchmaker) is true
end
check "oracle rejects invalid matchmakers":
  oracle(evil-matcher) is false
  oracle(evil-matcher-for-cands) is false
  oracle(dumb-matcher) is false
end