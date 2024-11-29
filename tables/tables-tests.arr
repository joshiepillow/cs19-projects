use context essentials2021

include my-gdrive("tables-common.arr")
import get-art-in-1, get-art-in-2, get-art-in-3
  from my-gdrive("tables-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

check "art-table-1 is accurate on basic input":
  get-art-in-1(art-table, empty-cc-table, 1, "A") is 10
  get-art-in-1(art-table, cc-table, 1, "A") is 10
  get-art-in-1(art-table, cc-table, 1, "B") is 20
  get-art-in-1(art-table, cc-table, 3, "A") is 20
  get-art-in-1(art-table, cc-table, 3, "B") is 40
  get-art-in-1(art-table, cc-table, 1, "D") is 0
end

check "art-table-2 is accurate on basic input":
  get-art-in-2(art-table, empty-cc-table, 1, "A") is 10
  get-art-in-2(art-table, cc-table, 1, "A") is 10
  get-art-in-2(art-table, cc-table, 1, "B") is 20
  get-art-in-2(art-table, cc-table, 3, "A") is 20
  get-art-in-2(art-table, cc-table, 3, "B") is 40
  get-art-in-2(art-table, cc-table, 1, "D") is 0
end

check "art-table-2 correctly handles errors":
  get-art-in-2(empty-art-table, empty-cc-table, 1, "A") raises "art"
  get-art-in-2(empty-art-table, cc-table, 1, "A") raises "art"
  get-art-in-2(art-table, empty-cc-table, 1, "B") raises "currency"
  get-art-in-2(art-table, cc-table, 4, "B") raises "art"
  get-art-in-2(art-table, cc-table, 3, "D") raises "currency"
end

check "art-table-3 is accurate on basic input":
  get-art-in-3(art-table, empty-cc-table, 1, "A") is 10
  get-art-in-3(art-table, cc-table, 1, "A") is 10
  get-art-in-3(art-table, cc-table, 1, "B") is 20
  get-art-in-3(art-table, cc-table, 3, "A") is 20
  get-art-in-3(art-table, cc-table, 3, "B") is 40
  get-art-in-3(art-table, cc-table, 1, "D") is 0
end

check "art-table-3 correctly handles errors":
  get-art-in-3(empty-art-table, empty-cc-table, 1, "A") raises "art"
  get-art-in-3(empty-art-table, cc-table, 1, "A") raises "art"
  get-art-in-3(art-table, empty-cc-table, 1, "B") raises "currency"
  get-art-in-3(art-table, cc-table, 4, "B") raises "art"
  get-art-in-3(art-table, cc-table, 3, "D") raises "currency"
end

check "art-table-3 prevents division by zero":
  get-art-in-3(art-table, cc-table, 100, "A") raises "zero"
end

check "art-table-3 uses inverse conversions accurately":
  get-art-in-3(art-table, cc-table, 10, "A") is-roughly (30 / 3.1415)
end