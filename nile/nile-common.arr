use context essentials2021
include shared-gdrive("nile-definitions.arr", "1G0l8Il4LBoenLdJ6tfu4grP4vGouMN6M")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both nile-code.arr and nile-tests.arr
files1 = [list: file("a", [list: "a", "b"])]
files2 = [list: file("a", [list: "a", "b"]), file("b", [list: "a", "b"])]
files3 = [list: file("a", [list: "a", "b", "c"]), file("b", [list: "a", "c"])]
files4 = [list: file("a", [list: "a", "b", "c"]), file("b", [list: "a", "b", "c"])]
files5 = [list: file("a", [list: "a", "b"]), file("b", [list: "a", "b"]), file("c", [list: "a", "c", "d"]), file("d", [list: "a", "d"]), file("e", [list: "b", "c", "d"])]
files6 = [list: file("a", [list: "a", "b", "c", "d"]), file("a", [list: "a", "b", "c", "d"]), file("a", [list: "a", "b", "c", "d"]), file("a", [list: "a", "b", "c", "d"])]
files7 = [list: file("a", [list: "a", "b", "c", "d"]), file("a", [list: "a", "b", "c", "d"]), file("a", [list: "a", "b", "d"]), file("a", [list: "a", "b", "c", "d"])]
files8 = [list: file("a", [list: "a", "A", " a", "a ", "a*"])]