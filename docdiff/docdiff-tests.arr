use context essentials2021

include my-gdrive("docdiff-common.arr")
include my-gdrive("docdiff-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

check "overlap accepts varying document lengths and outputs fractions":
  {[list: "1"]; [list: "1"]} satisfies overlap-in-ok
  {[list: "1"]; [list: "1", "2", "3"]} satisfies overlap-in-ok
  {[list: "1"]; [list: "123", "abc", "AbC"]} satisfies overlap-in-ok
  1 satisfies overlap-out-ok
  0 satisfies overlap-out-ok
  134/12345 satisfies overlap-out-ok
end
check "overlap works when varying document lengths and repetition":
  overlap([list: "1", "2", "3"], [list: "4", "5", "6"]) is 0
  overlap([list: "1", "2", "3"], [list: "1", "2", "3"]) is 1
  overlap([list: "1", "2", "3"], [list: "3", "1", "2"]) is 1
  overlap([list: "1", "2", "3"], [list: "1", "1"]) is 1/2
  overlap([list: "1", "2", "3"], [list: "1", "1", "4"]) is 2/5
  overlap([list: "1", "1", "2", "2", "3", "3"], [list: "1", "1", "4"]) is 1/3
  overlap([list: "3", "1", "1", "2", "3", "2"], [list: "1", "4", "1"]) is 1/3
  overlap([list: "0", "1", "2", "3", "4"], [list: "1", "4", "1"]) is 3/5
  overlap([list: "0"], [list: "0", "1", "1", "1"]) is 1/10
  overlap([list: "0", "1", "2", "3", "4", "5"], [list: "0", "1", "1", "1"]) is 2/5
  overlap([list: "0", "1", "2", "3", "4", "5", "5", "3", "2", "1", "6", "5", "4", "3", "2", "6", "7", "4", "5", "3", "2", "2", "7", "8", "5", "7", "5", "4", "7"], [list: "0", "1", "1", "1", "5", "1", "3", "6", "6", "3", "2", "7", "9"]) is 36/119
end
check "overlap works when varying capitalization":
  overlap([list: "oNe", "two", "thrEe"],  [list: "three", "oNe", "OnE"]) is 3/5
  overlap([list: "one"], [list: "one", "one", "one", "onE", "oNe", "one", "one"]) is 1/7
end