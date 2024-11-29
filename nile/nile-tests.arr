use context essentials2021
include shared-gdrive("nile-definitions.arr", "1G0l8Il4LBoenLdJ6tfu4grP4vGouMN6M")

include my-gdrive("nile-common.arr")
import recommend, recommend-in-ok, recommend-out-ok,
       popular-pairs, popular-pairs-in-ok, popular-pairs-out-ok
from my-gdrive("nile-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

check "recommend accepts various string, file list inputs":
  {"a"; empty} satisfies recommend-in-ok
  {"a"; files1} satisfies recommend-in-ok
  {"a"; files2} satisfies recommend-in-ok
  {"a"; files3} satisfies recommend-in-ok
  {"a"; files4} satisfies recommend-in-ok
  {"a"; files5} satisfies recommend-in-ok
  {"a"; files6} satisfies recommend-in-ok
  {"a"; files8} satisfies recommend-in-ok
end

check "recommend returns default when no recommendation is found":
  recommend("a", empty) is recommendation(0, [list: ])
  recommend("c", files2) is recommendation(0, [list: ])
end

check "recommend correctly handles various quantities and contents of files":
  recommend("a", files1) is recommendation(1, [list: "b"])
  recommend("b", files1) is recommendation(1, [list: "a"])
  recommend("a", files2) is recommendation(2, [list: "b"])
  recommend("a", files3) is recommendation(2, [list: "c"])
  recommend("a", files4) is recommendation(2, [list: "b", "c"])
  recommend("b", files4) is recommendation(2, [list: "a", "c"])
  recommend("c", files5) is recommendation(2, [list: "d"])
  recommend("d", files5) is recommendation(2, [list: "a", "c"])
  recommend("b", files6) is recommendation(4, [list: "a", "c", "d"])
end

check "recommend only treats titles as the same if they are identical":
  recommend("A", files8) is recommendation(1, [list: "a", " a", "a ", "a*"])
end

check "popular-pairs accepts various file list inputs":
  empty satisfies popular-pairs-in-ok
  files1 satisfies popular-pairs-in-ok
  files2 satisfies popular-pairs-in-ok
  files3 satisfies popular-pairs-in-ok
  files4 satisfies popular-pairs-in-ok
  files5 satisfies popular-pairs-in-ok
  files6 satisfies popular-pairs-in-ok
  files7 satisfies popular-pairs-in-ok
  files8 satisfies popular-pairs-in-ok
end

check "popular-pairs returns default when no recommendation is found":
  popular-pairs(empty) is recommendation(0, [list: ])
end

check "popular-pairs correctly handles various quantities and contents of files":
  popular-pairs(files1) is recommendation(1, [list: pair("a", "b")])
  popular-pairs(files2) is recommendation(2, [list: pair("a", "b")])
  popular-pairs(files3) is recommendation(2, [list: pair("a", "c")])
  popular-pairs(files4) is recommendation(2, [list: pair("a", "b"), pair("a", "c"), pair("b", "c")])
  popular-pairs(files5) is recommendation(2, [list: pair("a", "b"), pair("a", "d"), pair("c", "d")])
  popular-pairs(files6) is recommendation(4, [list: pair("a", "b"), pair("a", "c"), pair("a", "d"), pair("b", "c"), pair("b", "d"), pair("c", "d")])
  popular-pairs(files7) is recommendation(4, [list: pair("a", "b"), pair("a", "d"), pair("b", "d")])
end

check "popular-pairs only treats titles as the same if they are identical":
  popular-pairs(files8) is recommendation(1, [list: pair("a", "A"), pair("a", "a "), pair("a", " a"), pair("a", "a*"), pair("A", "a "), pair("A", " a"), pair("A", "a*"), pair("a ", " a"), pair("a ", "a*"), pair(" a", "a*")])
end