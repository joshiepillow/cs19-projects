use context essentials2021

include shared-gdrive("oracle-definitions.arr", "1VIj7v7L2Qy8FSRO7dh2uZki_a1NDTFxh")

provide: is-valid, oracle end

include my-gdrive("oracle-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in
# this file.
import sets as sets
type Set = sets.Set

fun is-up-to-n(alon :: List<Number>, n :: Number) -> Boolean:
  doc: "check if a list includes every number from 0 to n-1 exactly once"
  cases (List) alon:
    | empty => n == 0
    | link(f, r) =>
      min = r.foldl(num-min, f) 
      max = r.foldl(num-max, f)
      
      correct-length = alon.length() == n
      all-distinct = distinct(alon).length() == alon.length()
      
      correct-length and all-distinct and (min == 0) and (max == (n - 1))
  end
where:
  is-up-to-n(empty, 0) is true
  is-up-to-n(empty, 1) is false
  is-up-to-n([list: 0], 1) is true
  is-up-to-n([list: 1], 1) is false
  is-up-to-n([list: 3, 1, 0, 2], 4) is true
  is-up-to-n([list: 2, 3, 1, 0, 2], 4) is false
  is-up-to-n([list: 2, 3, 0, 2], 4) is false
  is-up-to-n([list: 1, 2, 3, 4], 4) is false
  is-up-to-n([list: 3, 3, 3, 3], 4) is false
end

fun get-company(matches-list :: List<Hire>, candidate :: Number) -> Number:
  doc: ```given a well formed list of hires and a valid candidate, 
       find the corresponding company to the candidate```
  # we may get(0) since we assume the input is well formed.
  match-option = matches-list.find({(a-hire): a-hire.candidate == candidate})
  cases (Option) match-option:
    | none => raise("hire list does not contain candidate")
    | some(v) => v.company
  end
where:
  get-company([list: hire(0, 0)], 0) is 0
  get-company([list: hire(0, 1), hire(1, 0)], 0) is 1
  get-company([list: hire(0, 1), hire(1, 0)], 1) is 0
  get-company([list: hire(0, 1), hire(2, 0), hire(1, 2)], 0) is 2
  get-company([list: hire(0, 1), hire(2, 0), hire(1, 2)], 1) is 0
  get-company([list: hire(0, 1), hire(2, 0), hire(1, 2)], 2) is 1
  get-company(empty, 0) raises "not contain"
  get-company([list: hire(1, 0)], 1) raises "not contain"
end

data Pair<A, B>:
  | pair(first :: A, second :: B)
end

fun pref-index(prefs :: List<Number>, n :: Number) -> Number:
  doc: "get the position of n in prefs"
  with-index = map_n({(index, elem): pair(index, elem)}, 0, prefs)
  cases (Option) with-index.find({(elem): elem.second == n}):
    | none => raise("preferences did not contain n")
    | some(v) => v.first
  end
where:
  pref-index([list: 0], 0) is 0
  pref-index([list: 1, 0, 2, 4, 3], 2) is 2
  pref-index([list: 1, 0, 2, 4, 3], 3) is 4
  pref-index(empty, 0) raises "not contain"
  pref-index([list: 0], 1) raises "not contain"
  pref-index([list: 1, 0], 1) is 0
end

fun is-better-pair(companies :: List<List<Number>>,
    candidates :: List<List<Number>>,
    company :: Number, other-candidate :: Number,
    paired-candidate :: Number, paired-other-company :: Number) -> Boolean:
  doc: ```check if a company and candidate prefer each other 
       over their current pairing```
  company-prefs = companies.get(company)
  other-candidate-prefs = candidates.get(other-candidate)

  company-prefers-other = 
    (pref-index(company-prefs, other-candidate)
        < pref-index(company-prefs, paired-candidate))
  other-prefers-company = 
    (pref-index(other-candidate-prefs, company)
        < pref-index(other-candidate-prefs, paired-other-company))

  company-prefers-other and other-prefers-company
where:
  is-better-pair([list: [list: 0, 1], [list: 1, 0]],
    [list: [list: 1, 0], [list: 0, 1]],  0, 1, 0, 1) is false
  is-better-pair([list: [list: 1, 0], [list: 1, 0]],
    [list: [list: 1, 0], [list: 0, 1]],  0, 1, 0, 1) is true
  is-better-pair([list: [list: 0, 1], [list: 1, 0]],
    [list: [list: 0, 1], [list: 1, 0]], 0, 1, 0, 1) is false
  is-better-pair([list: [list: 1, 0], [list: 1, 0]],
    [list: [list: 0, 1], [list: 1, 0]], 0, 1, 0, 1) is false
  is-better-pair([list: [list: 1, 0, 2], [list: 0, 2, 1], [list: 0, 1, 2]],
    [list: [list: 2, 0, 1], [list: 1, 0, 2], [list: 1, 2, 0]], 0, 1, 2, 2)
    is true
  is-better-pair([list: [list: 0, 1, 2], [list: 1, 0, 2], [list: 2, 0, 1]],
    [list: [list: 2, 1, 0], [list: 0, 1, 2], [list: 1, 0, 2]], 0, 2, 1, 1)
    is false
end

fun is-valid(
    companies :: List<List<Number>>,
    candidates :: List<List<Number>>,
    matches :: Set<Hire>)
  -> Boolean:
  doc: "check if a given set of matches is both well-formed and stable"
  # definitions
  num-hires = companies.length()
  matches-list = matches.to-list()
  all-companies = matches-list.map({(a-hire): a-hire.company})
  all-candidates = matches-list.map({(a-hire): a-hire.candidate})
  
  # use helper to check if matches is well-formed
  well-formed = is-up-to-n(all-companies, num-hires) and is-up-to-n(all-candidates, num-hires)
  
  if (not(well-formed)):
    false
  else:
    # loop over every company
    has-better-match = matches-list.map(lam(a-hire):
        company = a-hire.company
        paired-candidate = a-hire.candidate

        # loop over every candidate
        prefers-other = range(0, num-hires).map(lam(other-candidate):
            other-paired-company = get-company(matches-list, other-candidate)
            
            # check if they prefer each other over their current pairings
            is-better-pair(companies, candidates,
              company, other-candidate,
              paired-candidate, other-paired-company)
          end)
        prefers-other.foldl({(bool1, bool2): bool1 or bool2}, false)
      end)
    not(has-better-match.foldl({(bool1, bool2): bool1 or bool2}, false))
  end
end

fun oracle(a-matchmaker :: (List<List<Number>>, List<List<Number>> -> Set<Hire>)) -> Boolean:
  doc: ```determines if a-matchmaker produces a stable set of hires```
  companies1 = generate-input(10)
  companies2 = generate-input(20)
  companies3 = generate-input(30)
  candidates1 = generate-input(10)
  candidates2 = generate-input(20)
  candidates3 = generate-input(30)
  
  companies-equal = [list: [list: 0, 1, 2], [list: 0, 1, 2], [list: 0, 1, 2]]
  candidates-equal = [list: [list: 1, 2, 0], [list: 2, 1, 0], [list: 0, 2, 1]]
  
  companies-single = [list: [list: 0]]
  candidates-single = [list: [list: 0]]
  
  companies-double = [list: [list: 1, 0], [list: 0, 1]]
  candidates-double = [list: [list: 0, 1], [list: 0, 1]]
  
  is-valid(companies1, candidates1, 
    a-matchmaker(companies1, candidates1))
  and is-valid(companies2, candidates2, 
    a-matchmaker(companies2, candidates2))
  and is-valid(companies3, candidates3, 
    a-matchmaker(companies3, candidates3))
  and is-valid(companies-equal, candidates-equal, 
    a-matchmaker(companies-equal, candidates-equal))
  and is-valid(companies-single, candidates-single, 
    a-matchmaker(companies-single, candidates-single))
  and is-valid(companies-double, candidates-double, 
    a-matchmaker(companies-double, candidates-double))
  and is-valid(empty, empty, 
    a-matchmaker(empty, empty))
end