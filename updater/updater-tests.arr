use context essentials2021
include shared-gdrive("updater-definitions.arr", "19r6H4ZtedGt2ARtWQo1HflN0Ok8vxixJ")

include my-gdrive("updater-common.arr")
import find-cursor, get-node-val, update, to-tree, left, right, up, down, is-Cursor
  from my-gdrive("updater-code.arr")
import my-gdrive("updater-code.arr") as code
type Cursor = code.Cursor
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here.
#These should not be tests of implementation-specific details (e.g., helper functions).

fun mt-to-n<A>(n :: Number) -> (Tree<A> -> Tree<A>): 
  rec f = lam(tree):    
    cases (Tree) tree:
      | mt => node(n, empty)
      | node(value, children) =>
        node(value, children.map(f))
    end
  end
  f
end

fun subtract-1(t :: Tree<Number>) -> Tree<Number>:
  cases (Tree) t:
    | mt => mt
    | node(value, children) =>
      node(value - 1, map(subtract-1, children))
  end
end

fun add-str-test(t :: Tree<String>) -> Tree<String>:
  cases (Tree) t:
    | mt => mt
    | node(value, children) =>
      node(value + "test", map(add-str-test, children))
  end
end

fun cut(t :: Tree<Number>) -> Tree<Number>:
  mt
end

check "find cursor":
  get-node-val(find-cursor(tree-1-num, lam(x): x == 6 end)) is some(6)
  get-node-val(find-cursor(tree-2-num, lam(x): x == 3 end)) is some(3)
  get-node-val(find-cursor(tree-2-num, lam(x): x > 5 end)) is some(6)
  get-node-val(find-cursor(tree-2-num, lam(x): x < 5 end)) is some(0)
  get-node-val(find-cursor(tree-2-num, lam(x): x < 5 end)) is some(0)
  get-node-val(find-cursor(tree-4-num-empty, lam(_): true end)) is some(0)
  get-node-val(find-cursor(tree-5-num-huge, lam(x): x < 30 end)) is some(10)
  get-node-val(find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)) is some(4)
  get-node-val(find-cursor(tree-5-num-huge, lam(x): num-modulo(x, 3) == 0 end)) is some(0)
  get-node-val(find-cursor(tree-7-num-deep, lam(x): x > 3 end)) is some(4)
end

check "find no cursor":
  find-cursor(tree-1-num, lam(x): x == 9 end) raises "Could not find node"
  find-cursor(tree-4-num-empty, lam(x): not(x == 0) end) raises "Could not find node"
  find-cursor(tree-5-num-huge, lam(x): x < 0 end) raises "Could not find node"
  find-cursor(tree-5-num-huge, lam(x): ((x * x) > 50) and (not((x * x) == 100)) end)
    raises "Could not find node"
  find-cursor(tree-7-num-deep, lam(x): x == 8 end) raises "Could not find node"
end

check "horizontal movement":
  get-node-val(left(find-cursor(tree-2-num, lam(x): x == 3 end))) is some(2)
  get-node-val(right(find-cursor(tree-2-num, lam(x): x == 3 end))) is some(6)
  get-node-val(right(find-cursor(tree-3-num-big, lam(x): x == 5 end))) is some(5)
  get-node-val(right(find-cursor(tree-3-num-big, lam(x): x == 5 end))) is some(5)
  get-node-val(right(right(find-cursor(tree-3-num-big, lam(x): x == 5 end)))) is some(5)
  get-node-val(left(left(find-cursor(tree-6-num-big, lam(x): x == 20 end)))) is some(5)
  get-node-val(left(right(find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end))))
    is some(4)
  get-node-val(right(left(find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end))))
    is some(4)
  get-node-val(left(right(right(left(
            find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end))))))
    is some(4)
  get-node-val(left(left(right(right(find-cursor(tree-5-num-huge, lam(x): x < 10 end))))))
    is some(0)
  get-node-val(left(left(right(right(
            find-cursor(tree-5-num-huge, lam(x): x < 10 end))))))
    is some(0)
end

check "vertical movement":
  get-node-val(up(find-cursor(tree-1-num, lam(x): x == 6 end))) is some(5)
  get-node-val(down(up(find-cursor(tree-1-num, lam(x): x == 6 end)), 0)) is some(6)
  get-node-val(up(find-cursor(tree-7-num-deep, lam(x): x > 3 end))) is some(3)
  get-node-val(up(up(find-cursor(tree-7-num-deep, lam(x): x > 3 end)))) is some(2)
  get-node-val(up(up(up(find-cursor(tree-7-num-deep, lam(x): x > 3 end))))) is some(1)
  get-node-val(down(up(up(up(find-cursor(tree-7-num-deep, lam(x): x > 3 end)))),0)) is some(2)
  get-node-val(down(down(up(up(up(find-cursor(tree-7-num-deep, lam(x): x > 3 end)))),0),0))
    is some(3)
  get-node-val(down(down(down(up(up(up(find-cursor(tree-7-num-deep, lam(x): x > 3 end)))),0),0),0))
    is some(4)
  get-node-val(up(find-cursor(tree-7-num-deep, lam(x): x == 2 end))) is some(1)
  get-node-val(down(find-cursor(tree-1-num, lam(_): true end), 0)) is some(6)
end

check "mixed movement":
  get-node-val(down(right(
        find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)), 0))
    is some(5)
  get-node-val(down(right(
        find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)), 1))
    is some(5)
  get-node-val(down(down(right(
          find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)), 2), 0))
    is some(6)
  get-node-val(down(down(right(left(right(
              find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)))), 2), 0))
    is some(6)
  get-node-val(down(up(up(down(down(right(left(right(
                    find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)
                    ))), 2), 0))), 2))
    is some(5)
  get-node-val(down(right(right(find-cursor(tree-3-num-big, lam(x): x == 5 end))), 0)) is some(6)
end

check "invalid horizontal movements":
  left(find-cursor(tree-1-num, lam(_): true end)) raises "Invalid movement"
  right(find-cursor(tree-1-num, lam(_): true end)) raises "Invalid movement"
  left(find-cursor(tree-1-num, lam(x): x == 6 end)) raises "Invalid movement"
  right(find-cursor(tree-1-num, lam(x): x == 6 end)) raises "Invalid movement"
  right(right(find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)))
    raises "Invalid movement"
  right(find-cursor(tree-4-num-empty, lam(_): true end)) raises "Invalid movement"
end

check "invalid vertical movements":
  up(find-cursor(tree-1-num, lam(_): true end)) raises "Invalid movement"
  down(find-cursor(tree-1-num, lam(x): x == 6 end), 0) raises "Invalid movement"
  down(find-cursor(tree-1-num, lam(_): true end), 1) raises "Invalid movement"
  up(find-cursor(tree-4-num-empty, lam(_): true end)) raises "Invalid movement"
  down(find-cursor(tree-4-num-empty, lam(_): true end), 0) raises "Invalid movement"
  up(up(find-cursor(tree-7-num-deep, lam(x): x == 2 end))) raises "Invalid movement"
  up(up(up(find-cursor(tree-7-num-deep, lam(x): x < 4 end)))) raises "Invalid movement"
end

check "invalid mixed movements":
  right(down(down(right(
          find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)), 2), 0))
    raises "Invalid movement"
  down(down(down(right(
          find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)), 2), 0), 0)
    raises "Invalid movement"
  down(down(down(right(
          find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)), 2), 0), 1)
    raises "Invalid movement"
  down(update(find-cursor(tree-7-num-deep,
        lam(x): x > 3 end), cut), 0) raises "Invalid movement"
end

check "updating sub tree once":
  get-node-val(down(up(update(find-cursor(tree-1-num, lam(x): x == 6 end), 
          lam(_): mt end)), 0)) is none
  get-node-val(down(update(up(update(find-cursor(tree-1-num, lam(x): x == 6 end), 
            lam(_): mt end)), mt-to-n(1)), 0)) is some(1)
  get-node-val(down(update(find-cursor(tree-1-num, lam(x): x == 6 end), 
        lam(_): tree-1-num end), 0)) is some(6)
  get-node-val(update(find-cursor(tree-7-num-deep,
        lam(x): x > 3 end), lam(x): node(x.value - 1, x.children) end))
    is some(3)
  get-node-val(down(update(find-cursor(tree-7-num-deep,
          lam(x): x > 3 end), subtract-1), 0))
    is some(4)
  get-node-val(update(
      find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
      subtract-1)) is some(3)
  get-node-val(up(down(update(
          find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
          subtract-1),0))) is some(3)
  get-node-val(update(
      find-cursor(tree-5-num-huge, lam(x): x < 10 end),
      subtract-1)) is some(-1)
  get-node-val(down(update(
        find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
        subtract-1), 0)) is some(4)
  get-node-val(down(down(update(
          find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
          subtract-1), 0), 0)) is some(-1)
  get-node-val(down(down(update(
          find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
          subtract-1), 0), 1)) is some(0)
  get-node-val(down(down(update(
          find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
          subtract-1), 0), 5)) is some(3)
  get-node-val(update(find-cursor(tree-1-str, lam(x): x == "a" end), add-str-test)) is some("atest")
  get-node-val(down(update(find-cursor(tree-1-str, lam(x): x == "a" end), add-str-test), 5))
    is some("gtest")
  get-node-val(update(find-cursor(tree-7-num-deep, lam(x): x > 3 end), cut))
    is none
  get-node-val(update(find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end), cut))
      is none
end

check "updating sub tree multiple times":
  get-node-val(update(down(update(find-cursor(tree-7-num-deep,
            lam(x): x > 3 end), subtract-1), 0), subtract-1))
    is some(3)
  get-node-val(down(update(down(update(find-cursor(tree-7-num-deep,
              lam(x): x > 3 end), subtract-1), 0), subtract-1),0))
    is some(4)
  get-node-val(up(update(down(update(find-cursor(tree-7-num-deep,
              lam(x): x > 3 end), subtract-1), 0), subtract-1)))
    is some(3)
  get-node-val(down(update(down(update(
            find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
            subtract-1), 0), subtract-1), 0)) is some(-2)
  get-node-val(update(down(down(update(
            find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
            subtract-1), 0), 1), subtract-1)) is some(-1)
  get-node-val(down(down(update(update(
            find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
            subtract-1), subtract-1), 0), 5)) is some(2)
end

check "update not affect upper tree":
  get-node-val(up(update(find-cursor(tree-1-num, lam(x): x == 6 end), 
        lam(_): mt end))) is some(5)
  get-node-val(up(update(find-cursor(tree-7-num-deep,
          lam(x): x > 3 end), subtract-1)))
    is some(3)
  get-node-val(up(update(update(
          find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end),
          subtract-1), subtract-1))) is some(10)
end

check "to tree no updating":
  to-tree(find-cursor(tree-1-num, lam(_): true end)) is tree-1-num
  to-tree(find-cursor(tree-2-num, lam(x): x < 5 end)) is tree-2-num
  to-tree(find-cursor(tree-2-num, lam(x): x < 5 end)) is tree-2-num
  to-tree(find-cursor(tree-4-num-empty, lam(_): true end)) is tree-4-num-empty
  to-tree(find-cursor(tree-5-num-huge, lam(x): x < 30 end)) is tree-5-num-huge
  to-tree(find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)) is tree-5-num-huge
  to-tree(find-cursor(tree-5-num-huge, lam(x): num-modulo(x, 3) == 0 end)) is tree-5-num-huge
  to-tree(find-cursor(tree-7-num-deep, lam(x): x > 3 end)) is tree-7-num-deep
end

check "to tree with updating":
  to-tree(update(find-cursor(tree-1-num, lam(_): true end), subtract-1)) is tree-1-num-updated
  to-tree(update(down(update(
          find-cursor(tree-1-num, lam(_): true end),
          subtract-1), 0), subtract-1)) is tree-1-num-updated-2
  to-tree(update(
      find-cursor(tree-1-num, lam(_): true end),
      subtract-1)) is tree-1-num-updated
  to-tree(left(left(down(update(
            find-cursor(tree-2-num, lam(_): true end),
            subtract-1), 2)))) is tree-2-num-updated
  to-tree(down(update(update(
          find-cursor(tree-2-num, lam(_): true end),
          subtract-1), subtract-1), 0)) is tree-2-num-updated-2
  to-tree(update(down(update(update(
            find-cursor(tree-2-num, lam(_): true end),
            subtract-1), subtract-1), 5), subtract-1)) is tree-2-num-updated-3
  to-tree(update(down(update(
          find-cursor(tree-1-str, lam(x): x == "a" end), add-str-test), 5), add-str-test))
    is tree-1-str-updated-2
  to-tree(update(down(
        find-cursor(tree-1-str, lam(x): x == "a" end), 5), add-str-test))
    is tree-1-str-updated
  to-tree(up(update(down(
          find-cursor(tree-1-str, lam(x): x == "a" end), 5), add-str-test)))
    is tree-1-str-updated
end

check "chaining functions":
  get-node-val(down(
      find-cursor(
        to-tree(update(find-cursor(tree-7-num-deep, lam(x): x > 3 end),
            lam(x): node(x.value - 1, x.children) end)),
        lam(x): x == 3 end), 0)) is some(3)
  to-tree(update(up(find-cursor(to-tree(update(down(
                find-cursor(tree-1-str, lam(x): x == "a" end), 5), add-str-test)),
          lam(x): string-substring(x, 1, string-length(x)) == "test" end)), add-str-test))
    is tree-1-str-updated-2
  to-tree(update(left(
        find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)
        ), cut))
    is node(10, [list: tree-3-num-big, tree-3-num-big])
  to-tree(right(right(update(left(
            find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)
            ), cut))))
    is node(10, [list: tree-3-num-big, tree-3-num-big])
  to-tree(update(right(right(update(left(
              find-cursor(tree-5-num-huge, lam(x): (x < 10) and (not(x == 0)) end)
              ), cut))), cut))
    is node(10, [list: tree-3-num-big])
end