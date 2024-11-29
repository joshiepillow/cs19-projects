use context essentials2021
include shared-gdrive("mst-definitions.arr", "1BGkPeyFNhp0ND5sENwAXbL-BgQ9ZB_Nt")

include my-gdrive("mst-common.arr")
import mst-prim, mst-kruskal, generate-input, mst-cmp, sort-o-cle
from my-gdrive("mst-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of
# implementation-specific details (e.g., helper functions).
import sets as Sets
include string-dict

fun has-each-once<A>(output :: List<A>, desired :: List<A>) -> Boolean:
  doc: "check if every element desired is contained in output exactly once"
  (Sets.list-to-set(output) == Sets.list-to-set(desired)) and (length(output) == length(desired))
where:
  has-each-once(empty, empty) is true
  has-each-once([list: 1], empty) is false
  has-each-once(empty, [list: 1]) is false
  has-each-once([list: 1, 2, 3], [list: 3, 1, 2]) is true
  has-each-once([list: 1, 2, 3, 1], [list: 1, 2, 3]) is false
end

check "generate-input works on small cases":
  generate-input(0) is empty
  generate-input(1) is empty
end
check "generate-input returns a list that is possibly connected":
  length(generate-input(10)) >= 9 is true
  length(generate-input(20)) >= 19 is true
end

check "mst-kruskal works on small cases":
  mst-kruskal(empty) is empty
  mst-kruskal([list: edge("A", "B", 100)]) is [list: edge("A", "B", 100)]
  mst-kruskal([list: edge("A", "B", 10), edge("B", "C", 20), 
      edge("A", "C", 30), edge("A", "D", 40), edge("D", "B", 50)]) 
    is%(has-each-once) [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "D", 40)]
  mst-kruskal([list: edge("B", "C", 20), edge("A", "D", 40), 
      edge("D", "B", 50), edge("A", "C", 30), edge("A", "B", 10)]) 
    is%(has-each-once) [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "D", 40)]
end
check "mst-kruskal returns output of right length":
  length(mst-kruskal(generate-input(10))) is 9
  length(mst-kruskal(generate-input(20))) is 19
end
check "mst-kruskal returns a valid tree":
  graph10 = generate-input(10)
  graph20 = generate-input(20)
  is-some(length-spanning-tree(graph10, mst-kruskal(graph10))) is true
  is-some(length-spanning-tree(graph20, mst-kruskal(graph20))) is true
end

check "mst-prim works on small cases":
  mst-prim(empty) is empty
  mst-prim([list: edge("A", "B", 100)]) is [list: edge("A", "B", 100)]
  mst-prim([list: edge("A", "B", 10), edge("B", "C", 20), 
      edge("A", "C", 30), edge("A", "D", 40), edge("D", "B", 50)]) 
    is%(has-each-once) [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "D", 40)]
  mst-prim([list: edge("B", "C", 20), edge("A", "D", 40), 
      edge("D", "B", 50), edge("A", "C", 30), edge("A", "B", 10)]) 
    is%(has-each-once) [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "D", 40)]
end
check "mst-prim returns output of right length":
  length(mst-prim(generate-input(10))) is 9
  length(mst-prim(generate-input(20))) is 19
end
check "mst-prim returns a valid tree":
  graph10 = generate-input(10)
  graph20 = generate-input(20)
  is-some(length-spanning-tree(graph10, mst-prim(graph10))) is true
  is-some(length-spanning-tree(graph20, mst-prim(graph20))) is true
end

check "mst-cmp works on small cases":
  mst-cmp(empty, empty, empty) is true
  mst-cmp(empty, [list: edge("A", "B", 0)], [list: edge("A", "B", 0)]) is false
  mst-cmp(empty, empty, [list: edge("A", "B", 0)]) is false
  mst-cmp(empty, [list: edge("A", "B", 0)], empty) is false
  mst-cmp([list: edge("A", "B", 0)], empty, empty) is false
  mst-cmp([list: edge("A", "B", 0)], [list: edge("A", "B", 0)], [list: edge("A", "B", 0)]) is true
  mst-cmp([list: edge("B", "C", 20), edge("A", "D", 40), 
      edge("D", "B", 50), edge("A", "C", 30), edge("A", "B", 10)],
    [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "D", 40)],
    [list: edge("B", "C", 20), edge("A", "D", 40), edge("A", "B", 10)]) is true
  mst-cmp([list: edge("B", "C", 20), edge("A", "D", 40), 
      edge("D", "B", 50), edge("A", "C", 30), edge("A", "B", 10)],
    [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "D", 40)],
    [list: edge("B", "C", 20), edge("D", "B", 50), edge("A", "B", 10)]) is false
  mst-cmp([list: edge("B", "C", 20), edge("A", "D", 40), 
      edge("D", "B", 50), edge("A", "C", 30), edge("A", "B", 10)],
    [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "D", 40)],
    [list: edge("A", "B", 10), edge("B", "C", 30), edge("A", "D", 30)]) is false
end
check "mst-cmp prevents trees with edges not in graph":
  mst-cmp([list: edge("A", "B", 0), edge("B", "C", 0)], 
    [list: edge("A", "B", 0), edge("B", "D", 0)], 
    [list: edge("A", "B", 0), edge("B", "D", 0)]) is false 
  mst-cmp([list: edge("A", "B", 0), edge("B", "C", 0)], 
    [list: edge("A", "B", 0), edge("B", "C", 1)],
    [list: edge("A", "B", 0), edge("B", "C", 1)]) is false
end
check "mst-cmp disallows cycles":
  mst-cmp([list: edge("A", "B", 0)], 
    [list: edge("A", "B", 0), edge("A", "B", 0)],
    [list: edge("A", "B", 0), edge("A", "B", 0)]) is false
  mst-cmp([list: edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)], 
    [list: edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)],
    [list: edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)]) is false
  mst-cmp([list: edge("A", "B", 0), edge("B", "C", 0), 
      edge("A", "C", 0), edge("A", "D", 0), edge("D", "B", 0)], 
    [list: edge("D", "B", 0), edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)],
    [list: edge("D", "B", 0), edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)]) is false
end
check "mst-cmp requires mst reach every vertex":
  mst-cmp([list: edge("A", "B", 0), edge("A", "C", 0)], 
    [list: edge("A", "B", 0), edge("A", "B", 0)],
    [list: edge("A", "B", 0), edge("A", "B", 0)]) is false
  mst-cmp([list: edge("A", "B", 0), edge("A", "C", 0)], 
    [list: edge("A", "B", 0)],
    [list: edge("A", "B", 0)]) is false
  mst-cmp([list: edge("A", "B", 0), edge("B", "C", 0), 
      edge("A", "C", 0), edge("A", "D", 0), edge("D", "B", 0)], 
    [list: edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)],
    [list: edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)]) is false
  mst-cmp([list: edge("A", "B", 0), edge("B", "C", 0), 
      edge("A", "C", 0), edge("A", "D", 0), edge("D", "B", 0)], 
    [list: edge("A", "B", 0), edge("B", "C", 0)],
    [list: edge("A", "B", 0), edge("B", "C", 0)]) is false
end
check "mst-cmp allows different solutions":
  mst-cmp([list: edge("B", "C", 20), edge("A", "D", 40), 
      edge("D", "B", 30), edge("A", "C", 20), edge("A", "B", 10)],
    [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "D", 40)],
    [list: edge("B", "C", 20), edge("D", "B", 30), edge("A", "C", 20)]) is true
  mst-cmp([list: edge("B", "C", 20), edge("A", "D", 40), 
      edge("D", "B", 30), edge("A", "C", 20), edge("A", "B", 10), edge("A", "E", 100)],
    [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "D", 40), edge("A", "E", 100)],
    [list: edge("B", "C", 20), edge("A", "E", 100), edge("D", "B", 30), edge("A", "C", 20)]) is true
end
check "mst-cmp works on mst-prim and mst-kruskal":
  graph10 = generate-input(10)
  graph20 = generate-input(20)
  mst-cmp(graph10, mst-kruskal(graph10), mst-prim(graph10)) is true
  mst-cmp(graph20, mst-kruskal(graph20), mst-prim(graph20)) is true
end

check "sort-o-cle returns true for valid sorters":
  sort-o-cle(mst-prim, mst-kruskal) is true
  sort-o-cle(mst-kruskal, mst-prim) is true
  sort-o-cle(mst-prim, mst-prim) is true
  sort-o-cle(mst-kruskal, mst-kruskal) is true
end

fun greedy-tree(graph :: Graph) -> Graph:
  doc: "takes every edge it can while maintaining a tree"
  vertex-list = graph.foldl({(a-edge, a-list): 
      link(a-edge.a, link(a-edge.b, a-list))}, empty)
  map-to-element = vertex-list.foldl({(a-vertex, a-dict):
      a-dict.set(a-vertex, element(0, none))}, [string-dict: ])
  
  {answer; _} = graph.foldl({(a-edge, {a-graph; a-dict}):
      a = a-dict.get-value(a-edge.a)
      b = a-dict.get-value(a-edge.b)
      if is-in-same-set(a, b): # do not add if two vertices are already connected
        {a-graph; a-dict}
      else: # add edge if two verticies are not already connected
        joined = union(a, b)
        {link(a-edge, a-graph); a-dict.set(a-edge.a, joined).set(a-edge.b, joined)}
      end}, {empty; map-to-element})
  
  answer
end

check "sort-o-cle accepts bad algo as long as it returns valid tree":
  sort-o-cle(greedy-tree, greedy-tree) is true
end
check "but if compared against a good mst it rejects":
  sort-o-cle(greedy-tree, mst-kruskal) is false
  sort-o-cle(mst-prim, greedy-tree) is false
end
check "compared against another bad algo it also fails":
  sort-o-cle(greedy-tree, {(graph): greedy-tree(reverse(graph))}) is false
end

fun terrible-algo(graph :: Graph) -> Graph:
  doc: "takes first graph size - 1 edges"
  cases (List) graph:
    | empty => empty
    | link(_, _) =>
      vertex-list = graph.foldl({(a-edge, a-list): 
          link(a-edge.a, link(a-edge.b, a-list))}, empty)
      vertex-count = vertex-list.foldl({(a-vertex, a-dict):
          a-dict.set(a-vertex, "")}, [string-dict: ]).keys().size()
      graph.take(vertex-count - 1)
  end
end

check "really bad algos always fail though":
  sort-o-cle(terrible-algo, terrible-algo) is false
  sort-o-cle(terrible-algo, greedy-tree) is false
  sort-o-cle(terrible-algo, mst-kruskal) is false
  sort-o-cle({(graph): empty}, {(graph): empty}) is false
  sort-o-cle({(graph): [list: edge("A", "B", 0)]}, {(graph): [list: edge("A", "B", 0)]}) is false
end