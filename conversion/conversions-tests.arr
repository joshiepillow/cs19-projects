use context essentials2021

include my-gdrive("conversions-common.arr")
import get-art-in-4
from my-gdrive("conversions-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

empty-art-table = table: id, cost, currency end
art-table = table: id, cost, currency
  row: 1, 10, "A"
  row: 2, 30, "A"
  row: 3, 40, "B"
  row: 4, 40, "B"
  row: 4, 40, "B"
  row: 10, 30, "C"
  row: 100, 1, "D"
  row: 1000, 10, "Z"
end

empty-conversion = table: from-c, to-c, conv-rate end
contradictory-conversion = table: from-c, to-c, conv-rate
  row: "A", "B", 2
  row: "B", "A", 3
  row: "A", "C", 5
  row: "D", "E", 7
  row: "F", "E", 11
  row: "Z", "Y", 0
end
normal-conversion = table: from-c :: String, to-c :: String, conv-rate :: Number 
  row: "A", "B", 2
  row: "B", "A", 1 / 2
  row: "A", "C", 3.1415
  row: "A", "E", 5
  row: "G", "F", 7
  row: "G", "E", 11
  row: "H", "G", 13
  row: "H", "I", 17
end

check "raises error when mutliply conversion rates exist":
  get-art-in-4(art-table, contradictory-conversion, 1, "A") raises "multiple"
  get-art-in-4(art-table, contradictory-conversion, 1, "B") raises "multiple"
  get-art-in-4(art-table, contradictory-conversion, 1, "C") raises "multiple"
end
check "prevents division by zero conversions":
  get-art-in-4(art-table, contradictory-conversion, 1000, "Y") raises "undefined"
end
check "raises exception when duplicate art entry":
  get-art-in-4(empty-art-table, empty-conversion, 1, "A") raises "art"
  get-art-in-4(empty-art-table, normal-conversion, 1, "A") raises "art"
  get-art-in-4(art-table, normal-conversion, 4, "B") raises "art"
end
check "raises excpetion when conversion is unreachable with any composition":
  get-art-in-4(art-table, empty-conversion, 1, "B") raises "no conversion"
  get-art-in-4(art-table, normal-conversion, 100, "A") raises "no conversion"
  get-art-in-4(art-table, normal-conversion, 1, "Z") raises "no conversion"
end
check "non-contradictory rates in a conversion table with contradictions work":
  get-art-in-4(art-table, contradictory-conversion, 100, "E") is 7
  get-art-in-4(art-table, contradictory-conversion, 100, "F") is 7 / 11
end
check "accurate on direct or no conversion":
  get-art-in-4(art-table, empty-conversion, 1, "A") is 10
  get-art-in-4(art-table, normal-conversion, 1, "A") is 10
  get-art-in-4(art-table, normal-conversion, 1, "B") is 20
  get-art-in-4(art-table, normal-conversion, 3, "A") is 20
  get-art-in-4(art-table, normal-conversion, 3, "B") is 40
end
check "accurate on inverse conversions":
  get-art-in-4(art-table, normal-conversion, 10, "A") is 30 / 3.1415
end
check "accurate on long composition of both forward and inverse conversions":
  get-art-in-4(art-table, normal-conversion, 3, "I") is (40 * 5 * 17) / (2 * 11 * 13)
end
