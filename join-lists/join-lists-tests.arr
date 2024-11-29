use context essentials2021
include shared-gdrive("join-lists-definitions.arr", "1gNl8Rt88uWqpbv0Hx9Fkh6ajnNoDr164")

include my-gdrive("join-lists-common.arr")
import j-first, j-rest, j-length, j-nth, j-max, j-map, j-filter, j-reduce, j-sort
from my-gdrive("join-lists-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of
# implementation-specific details (e.g., helper functions).

check "j-first works properly":
  j-first([join-list: "a"]) is "a"
  j-first([join-list: 10, 20, 30, 40]) is 10
  j-first([join-list: 30, 10, 40, 20]) is 30
end

check "j-rest works properly":
  j-rest([join-list: "a"]) is empty-join-list
  j-rest([join-list: 10, 20]) is [join-list: 20]
  j-rest([join-list: 30, 10, 40, 20]) is [join-list: 10, 40, 20]
end

check "j-length works properly":
  j-length(empty-join-list) is 0
  j-length([join-list: 10]) is 1
  j-length([join-list: 30, 10, 40, 20]) is 4
  j-length([join-list: "gah", "grr", "ghh", "gra", 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]) is 16
end

check "j-nth works properly":
  j-nth([join-list: "a"], 0) is "a"
  j-nth([join-list: 10, 20, 30, 40], 0) is 10
  j-nth([join-list: 10, 20, 30, 40], 1) is 20
  j-nth([join-list: 10, 20, 30, 40], 2) is 30
  j-nth([join-list: 10, 20, 30, 40], 3) is 40
end

check "j-max works properly":
  max-func = {(a, b): a > b}
  min-func = {(a, b): a < b}
  length-func = {(a, b): j-length(a) > j-length(b)}
  j-max([join-list: "a"], max-func) is "a"
  j-max([join-list: "a"], min-func) is "a"
  j-max([join-list: "b", "a"], max-func) is "b"
  j-max([join-list: "b", "a"], min-func) is "a"
  j-max([join-list: 30, 10, 40, 20], max-func) is 40
  j-max([join-list: 30, 10, 40, 20], min-func) is 10
  j-max([join-list: 10, 20, 30, 40], max-func) is 40
  j-max([join-list: 40, 30, 20, 10], max-func) is 40
  j-max([join-list: 10, 10, 30, 40], max-func) is 40
  j-max([join-list: 10, 20, 40, 40], max-func) is 40
  j-max([join-list: "q", "f", "c", "r", "w", "g"], max-func) is "w"
  j-max([join-list: empty-join-list, one(1), [join-list: 3, 2, "a", "b"], [join-list: 1, 2]], 
    length-func) is [join-list: 3, 2, "a", "b"]
  
end

check "j-map works properly":
  squared-func = {(a): a * a}
  identity-func = {(a): a}
  j-map(squared-func, empty-join-list) is empty-join-list
  j-map(squared-func, [join-list: 10]) is [join-list: 100]
  j-map(squared-func, [join-list: 10, 20]) is [join-list: 100, 400]
  j-map(squared-func, [join-list: 30, 10, 40, 20]) is [join-list: 900, 100, 1600, 400]
  j-map(identity-func, [join-list: 30, 10, 40, 20]) is [join-list: 30, 10, 40, 20]
  j-map({(a): [join-list: a]}, [join-list: 10, 20, 30, 40]) 
    is [join-list: one(10), one(20), one(30), one(40)]
  j-map({(a): empty-join-list}, [join-list: 10, 20, 30, 40]) 
    is [join-list: empty-join-list, empty-join-list, empty-join-list, empty-join-list]
  j-map({(a): [list: a]}, [join-list: 10, 20, 30, 40]) 
    is [join-list: [list: 10], [list: 20], [list: 30], [list: 40]]
  j-map({(a): empty}, [join-list: 10, 20, 30, 40]) 
  is [join-list: empty, empty, empty, empty]
end

check "j-filter works properly":
  positive-func = {(a): a > 0}
  false-func = {(_): false}
  true-func = {(_): true}
  j-filter(false-func, empty-join-list) is empty-join-list
  j-filter(true-func, empty-join-list) is empty-join-list
  j-filter(false-func, [join-list: 10]) is empty-join-list
  j-filter(true-func, [join-list: 10]) is [join-list: 10]
  j-filter(positive-func, [join-list: 30, -10, -40, 20]) is [join-list: 30, 20]
  j-filter(false-func, [join-list: 30, -10, -40, 20]) is empty-join-list
  j-filter(true-func, [join-list: 30, -10, -40, 20]) is [join-list: 30, -10, -40, 20]
  j-filter({(a): j-first(a) == 10}, [join-list: one(10), one(20), one(30), one(40)]) 
    is one(one(10))
end

check "j-reduce works properly":
  sum-func = {(a, b): a + b}
  right-func = {(_, b): b}
  left-func = {(a, _): a}
  append-func = {(a, b): string-to-number(string-append(num-to-string(a), num-to-string(b))).value}
  j-reduce(sum-func, [join-list: 10]) is 10
  j-reduce(right-func, [join-list: 10]) is 10
  j-reduce(left-func, [join-list: 10]) is 10
  j-reduce(sum-func, [join-list: 30, 10, 40, 20]) is 100
  j-reduce(right-func, [join-list: 30, 10, 40, 20]) is 20
  j-reduce(left-func, [join-list: 30, 10, 40, 20]) is 30
  j-reduce({(a, b): a.join(b)}, [join-list: one(30), empty-join-list, 
      [join-list: 10, 40], one(20)]) is [join-list: 30, 10, 40, 20]
  j-reduce(append-func, [join-list: 1, 10, 1, 100, 1, 1000, 1, 10000, 1]) is 1101100110001100001
  j-reduce(append-func, j-sort({(a, b): a < b}, [join-list: 1, 10, 1, 100, 1, 1000, 1, 10000, 1]))
    is 1111110100100010000
end

check "j-sort works properly":
  less-func = {(a, b): a < b}
  greater-func = {(a, b): a > b}
  jl-func = {(a, b): j-first(a) < j-first(b)}
  j-sort(less-func, empty-join-list) is empty-join-list
  j-sort(less-func, [join-list: 10]) is [join-list: 10]
  j-sort(less-func, [join-list: 10, 20]) is [join-list: 10, 20]
  j-sort(less-func, [join-list: 20, 10]) is [join-list: 10, 20]
  j-sort(less-func, [join-list: 10, 20, 30, 40]) is [join-list: 10, 20, 30, 40]
  j-sort(less-func, [join-list: 30, 10, 40, 20]) is [join-list: 10, 20, 30, 40]
  j-sort(less-func, [join-list: 40, 30, 20, 10]) is [join-list: 10, 20, 30, 40]
  j-sort(less-func, [join-list: 30, 10, 40, 20, 30, 10, 40, 20]) 
    is [join-list: 10, 10, 20, 20, 30, 30, 40, 40]
  j-sort(greater-func, [join-list: 10, 20, 30, 40]) is [join-list: 40, 30, 20, 10]
  j-sort(greater-func, [join-list: 30, 10, 40, 20]) is [join-list: 40, 30, 20, 10]
  j-sort(greater-func, [join-list: 40, 30, 20, 10]) is [join-list: 40, 30, 20, 10]
  j-sort(greater-func, [join-list: 30, 10, 40, 20, 30, 10, 40, 20]) 
    is [join-list: 40, 40, 30, 30, 20, 20, 10, 10]
  
  possibilities = [list: [join-list: one(10), [join-list: 10, 1], [join-list: 20, 1], one(20)],
    [join-list: one(10), [join-list: 10, 1], one(20), [join-list: 20, 1]],
    [join-list: [join-list: 10, 1], one(10), [join-list: 20, 1], one(20)],
    [join-list: [join-list: 10, 1], one(10), one(20), [join-list: 20, 1]]]
  member(possibilities,
    j-sort(jl-func, [join-list: one(10), [join-list: 20, 1], [join-list: 10, 1], one(20)]))
    is true
end