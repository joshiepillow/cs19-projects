use context essentials2021
include shared-gdrive("updater-definitions.arr", "19r6H4ZtedGt2ARtWQo1HflN0Ok8vxixJ")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both updater-code.arr and updater-tests.arr

tree-1-num = node(5, [list: node(6, [list:])])
tree-1-num-updated = node(4, [list: node(5, [list:])])
tree-1-num-updated-2 = node(4, [list: node(4, [list:])])
tree-2-num = node(5, [list:
    node(0,[list:]), node(1,[list:]),
    node(2,[list:]), node(3,[list:]),
    node(6, [list:]), node(4,[list:])])
tree-2-num-updated = node(4, [list:
    node(-1,[list:]), node(0,[list:]),
    node(1,[list:]), node(2,[list:]),
    node(5, [list:]), node(3,[list:])])
tree-2-num-updated-2 = node(3, [list:
    node(-2,[list:]), node(-1,[list:]),
    node(0,[list:]), node(1,[list:]),
    node(4, [list:]), node(2,[list:])])
tree-2-num-updated-3 = node(3, [list:
    node(-2,[list:]), node(-1,[list:]),
    node(0,[list:]), node(1,[list:]),
    node(4, [list:]), node(1,[list:])])
tree-3-num-big = node(4, [list: tree-2-num, tree-2-num, tree-1-num])
tree-4-num-empty = node(0, [list:])
tree-5-num-huge = node(10, [list: tree-4-num-empty, tree-3-num-big, tree-3-num-big])
tree-6-num-big = node(15, [list: tree-2-num, tree-2-num, node(20, [list:])])
tree-7-num-deep =
  node(1, [list:
      node(2, [list:
          node(3, [list:
              node(4, [list:
                  node(5, [list:
                      node(6, [list: ])])])])])])

tree-1-str = node("a", [list:
    node("b",[list:]), node("c",[list:]),
    node("d",[list:]), node("e",[list:]),
    node("f", [list:]), node("g",[list:])])
tree-1-str-updated = node("a", [list:
    node("b",[list:]), node("c",[list:]),
    node("d",[list:]), node("e",[list:]),
    node("f", [list:]), node("gtest",[list:])])
tree-1-str-updated-2 = node("atest", [list:
    node("btest",[list:]), node("ctest",[list:]),
    node("dtest",[list:]), node("etest",[list:]),
    node("ftest", [list:]), node("gtesttest",[list:])])