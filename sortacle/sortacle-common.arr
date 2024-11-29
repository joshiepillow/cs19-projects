use context essentials2021
include shared-gdrive("sortacle-definitions.arr", "1d6n7TSAQa_aTEqLyTXjHxFsdrQAt_lyq")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both sortacle-code.arr and sortacle-tests.arr

fun generate-list<T>(n :: Number, gen :: (Number -> T)) -> List<T>:
  doc: "Generate a list of length n given a generating function"
  if (n == 0):
    empty
  else:
    link(gen(n), generate-list(n - 1, gen))
  end
where:
  generate-list(0, {(_): 1}) is empty
  generate-list(1, {(_): 1}) is [list: 1]
  generate-list(10, {(_): 1}) is [list: 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  generate-list(3, {(n): n}) is [list: 3, 2, 1]
end

fun concat<T>(l1 :: List<T>, l2 :: List<T>) -> List<T>:
  doc: "Concatenates two lists into a single list preserving order"
  l1.foldr({(elem, acc): link(elem, acc)}, l2)
where:
  concat(empty, empty) is empty
  concat(empty, [list: 1]) is [list: 1]
  concat([list: 1], empty) is [list: 1]
  concat([list: 1, 2], [list: 3, 4, 5]) is [list: 1, 2, 3, 4, 5]
end