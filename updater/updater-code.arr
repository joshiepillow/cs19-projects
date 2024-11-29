use context essentials2021
include shared-gdrive("updater-definitions.arr", "19r6H4ZtedGt2ARtWQo1HflN0Ok8vxixJ")

provide:
  find-cursor, get-node-val, update, to-tree, left, right, up, down, is-Cursor,
  type Cursor,
end

include my-gdrive("updater-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.

# You will come up with a Cursor definition, which may have more than
# one variant, and can have whatever fields you need

data Cursor<A>:
  | cursor(value :: Tree<A>, left :: List<Tree<A>>,
      right :: List<Tree<A>>, parent :: List<Cursor<A>>)
end

fun sublist<A>(a-list :: List<A>, start :: Number, stop :: Number) -> List<A>:
  doc: ```returns a sublist starting with index start and ending with index stop - 1
       assumes inputs are valid (0<= start <= stop <= length(a-list)```
  a-list.drop(start).take(stop - start)
end
check "sublist helper function":
  sublist([list: 1, 2, 3, 4, 5, 6], 0, 3) is [list: 1, 2, 3]
  sublist([list: 1, 2, 3, 4, 5, 6], 3, 5) is [list: 4, 5]
  sublist([list: "a", "b", "c", "d", "e"], 2, 4) is [list: "c", "d"]
  sublist([list: "a", "b", "c", "d", "e"], 0, 0) is [list: ]
  sublist([list: "a", "b", "c", "d", "e"], 0, 5) is [list: "a", "b", "c", "d", "e"]
  sublist([list: ], 0, 0) is [list: ]
  sublist([list: "a", "b", "c", "d", "e"], 3, 3) is [list: ]
end

fun find-cursor-helper<A>(tree :: Tree<A>, pred :: (A -> Boolean), 
    parent-option :: Option<Cursor<A>>, index :: Number) -> Option<Cursor<A>>:
  doc: "find-cursor helper that keeps track of parents"
  cases (Tree) tree:
    | mt => none
    | node(value, all-children) =>
      cur = cases (Option) parent-option:
        | none => cursor(tree, empty, empty, empty)
        | some(parent) => down(parent, index)
      end
      if (pred(value)):
        some(cur)
      else:
        succeeding-children = map_n({(child-index, child): 
            find-cursor-helper(child, pred, some(cur), child-index)}, 0, all-children)
          .filter(is-some)
        cases (List) succeeding-children:
          | empty => none
          | link(first, rest) => first
        end
      end
  end
end
##### did not write tests (test suite would be essentially the same as find-cursor)

fun find-cursor<A>(tree :: Tree<A>, pred :: (A -> Boolean)) -> Cursor<A>:
  doc: "creates a cursor to first element satisfying predicate"
  cases (Option) find-cursor-helper(tree, pred, none, 0):
    | none => raise("Could not find node matching predicate")
    | some(cur) => cur
  end
end

fun up<A>(cur :: Cursor<A>) -> Cursor<A>:
  doc: "move cursor location up a tree"
  cases (List) cur.parent:
    | empty => raise("Invalid movement")
    | link(parent, rest-parent) =>
      cases (Tree) parent.value:
        | mt => raise("Invalid state")
        | node(value, _) =>
          all-children = cur.left.reverse().append([list: cur.value]).append(cur.right)
          cursor(node(value, all-children), parent.left, parent.right, rest-parent) 
      end
  end
end

fun left<A>(cur :: Cursor<A>) -> Cursor<A>:
  doc: "move cursor location left in a tree"
  cases (List) cur.left:
    | empty => raise("Invalid movement")
    | link(first-left, rest-left) =>
      cursor(first-left, rest-left, link(cur.value, cur.right), cur.parent)
  end
end

fun right<A>(cur :: Cursor<A>) -> Cursor<A>:
  doc: "move cursor location right in a tree"
  cases (List) cur.right:
    | empty => raise("Invalid movement")
    | link(first-right, rest-right) =>
      cursor(first-right, link(cur.value, cur.left), rest-right, cur.parent)
  end
end

fun down<A>(cur :: Cursor<A>, child-index :: Number) -> Cursor<A>:
  doc: "move cursor location in a tree down to child at index"
  cases (Tree) cur.value:
    | mt => raise("Invalid movement")
    | node(value, all-children) =>
      list-length = all-children.length()
      if (child-index >= list-length):
        raise("Invalid movement")
      else:
        cursor(all-children.get(child-index), reverse(sublist(all-children, 0, child-index)), 
          sublist(all-children, child-index + 1, list-length), link(cur, cur.parent))
      end
  end
end

fun update<A>(cur :: Cursor<A>, func :: (Tree<A> -> Tree<A>)) -> Cursor<A>:
  doc: "apply function to tree at cursor"
  cursor(func(cur.value), cur.left, cur.right, cur.parent)
end

fun to-tree<A>( cur :: Cursor<A> ) -> Tree<A>:
  cases (List) cur.parent:
    | empty => cur.value
    | link(_, _) => to-tree(up(cur))
  end
end

fun get-node-val<A>(cur :: Cursor<A>) -> Option<A>: 
  cases (Tree) cur.value:
    | mt => none
    | node(value, _) => some(value)
  end
end