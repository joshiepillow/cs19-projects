use context essentials2021
include shared-gdrive("mst-definitions.arr", "1BGkPeyFNhp0ND5sENwAXbL-BgQ9ZB_Nt")

provide: mst-prim, mst-kruskal, generate-input, mst-cmp, sort-o-cle end

include my-gdrive("mst-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions)
# in this file.
include pick
include string-dict

### Taken from previous year's lab (minor surgery)
data Heap:
  | mt
  | node(value :: Edge, left :: Heap, right :: Heap)
end

fun insert(elt :: Edge, h :: Heap) -> Heap:
  doc: ```Takes in a Number elt and a proper Heap h produces
       a proper Heap that has all of the elements of h and elt.```
  cases (Heap) h:
    | mt => node(elt, mt, mt)
    | node(val, lh, rh) =>
      min-val = if elt.weight < val.weight: elt else: val end
      max-val = if elt.weight < val.weight: val else: elt end
      node(min-val, insert(max-val, rh), lh)
  end
end

fun remove-min(h :: Heap%(is-node)) -> Heap:
  doc: ```Given a proper, non-empty Heap h, removes its minimum element.```
  amputated = amputate-bottom-left(h)
  top-replaced = 
    cases (Heap) amputated.heap:
      | mt => mt
      | node(val, lh, rh) =>
        node(amputated.elt, lh, rh)
    end
  reorder(rebalance(top-replaced))
end

fun rebalance(h :: Heap) -> Heap:
  doc: ```Given a Heap h, switches all children along the leftmost path```
  cases (Heap) h:
    | mt => mt
    | node(val, lh, rh) =>
      node(val, rh, rebalance(lh))
  end
end

fun get-min(h :: Heap%(is-node)) -> Edge:
  doc: ```Takes in a proper, non-empty Heap h and produces the
       minimum Number in h.```
  cases (Heap) h:
    | mt => raise("Invalid input: empty heap")
    | node(val,_,_) => val
  end
end

data Amputated:
  | elt-and-heap(elt :: Edge, heap :: Heap)
end

fun amputate-bottom-left(h :: Heap%(is-node)) -> Amputated:
  doc: ```Given a Heap h, produes an Amputated that contains the 
       bottom-left element of h, and h with the bottom-left element removed.```
  cases (Heap) h:
    | mt => raise("Invalid input: empty heap")
    | node(value, left, right) =>
      cases (Heap) left:
        | mt => elt-and-heap(value, mt)
        | node(_, _, _) => 
          rec-amputated = amputate-bottom-left(left)
          elt-and-heap(rec-amputated.elt,
            node(value, rec-amputated.heap, right))
      end
  end
end

fun reorder(h :: Heap) -> Heap:
  doc: ```Given a Heap h, where only the top node is misplaced,
       produces a Heap with the same elements but in proper order.```
  cases(Heap) h:
    | mt => mt # Do nothing (empty heap)
    | node(val, lh, rh) =>
      cases(Heap) lh:
        | mt => h # Do nothing (no children)
        | node(lval, llh, lrh) =>
          cases(Heap) rh:
            | mt => # Just left child
              ask:
                | val.weight < lval.weight then: h # Do nothing
                | otherwise: node(lval, reorder(node(val, llh, lrh)), rh) # Swap left
              end
            | node(rval, rlh, rrh) => # Both children
              ask:
                | (val.weight < lval.weight) and (val.weight < rval.weight) then: h
                | lval.weight < rval.weight then: node(lval, reorder(node(val, llh, lrh)), rh) 
                | lval.weight >= rval.weight then: node(rval, lh, reorder(node(val, rlh, rrh))) 
              end
          end
      end
  end
end

### My code
fun mst-kruskal(graph :: Graph) -> Graph:
  doc: "finds minimum spanning tree using kruskall's algorithm"
  sorted-graph = sort-by(graph, 
    {(edge1, edge2): edge1.weight < edge2.weight}, 
    {(edge1, edge2): edge1.weight == edge2.weight})
  
  vertex-list = graph.foldl({(a-edge, a-list): 
      link(a-edge.a, link(a-edge.b, a-list))}, empty)
  map-to-element = vertex-list.foldl({(a-vertex, a-dict):
      a-dict.set(a-vertex, element(0, none))}, [string-dict: ])
  
  {answer; _} = sorted-graph.foldl({(a-edge, {a-graph; a-dict}):
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

fun mst-prim(graph :: Graph) -> Graph:
  doc: "finds minimum spanning tree using prim's algorithm"
  vertex-list = graph.foldl({(a-edge, a-list): 
      link(a-edge.a, link(a-edge.b, a-list))}, empty)
  
  map-to-empty = vertex-list.foldl({(a-vertex, a-dict):
      a-dict.set(a-vertex, empty)}, [string-dict: ])
  map-to-edges = graph.foldl({(a-edge, a-dict):
      a-list = link(a-edge, a-dict.get-value(a-edge.a))
      b-list = link(a-edge, a-dict.get-value(a-edge.b))
      a-dict.set(a-edge.a, a-list).set(a-edge.b, b-list)}, 
    map-to-empty)
  
  a-pick = map-to-empty.keys().pick() # choose starting vertex
  cases (Pick) a-pick:
    | pick-none => empty # if no vertices, mst is empty
    | pick-some(a-vertex, _) => 
      initial-heap = map-to-edges.get-value(a-vertex).foldl({(b-edge, b-heap):
          insert(b-edge, b-heap)}, mt) # add all to heap
      # use string-dict to model constant-time op hashset
      initial-visited = [string-dict: a-vertex, ""] 

      # takes at most 2 * number of edges 
      {answer; _; _} = graph.append(graph).foldl({(_, {a-graph; a-heap; a-hashset}): 
          cases (Heap) a-heap:
            | mt => {a-graph; a-heap; a-hashset} # nothing left to search, we are done
            | node(_, _, _) =>
              a-edge = get-min(a-heap) # get closest edge
              rm-heap = remove-min(a-heap)
              ask:
                | a-hashset.has-key(a-edge.a) and a-hashset.has-key(a-edge.b) then:
                  {a-graph; rm-heap; a-hashset} # if vertices are already connected do nothing
                | a-hashset.has-key(a-edge.a) then:
                  next-heap = map-to-edges.get-value(a-edge.b).foldl({(b-edge, b-heap):
                      insert(b-edge, b-heap)}, rm-heap) # add all new adjacent vertices
                  {link(a-edge, a-graph); next-heap; a-hashset.set(a-edge.b, "")}
                | a-hashset.has-key(a-edge.b) then:
                  next-heap = map-to-edges.get-value(a-edge.a).foldl({(b-edge, b-heap):
                      insert(b-edge, b-heap)}, rm-heap) # add all new adjacent vertices
                  {link(a-edge, a-graph); next-heap; a-hashset.set(a-edge.a, "")}
              end
          end
        }, {empty; initial-heap; initial-visited}) 
      
      answer
  end
end

max-weight = 10000
fun generate-input(num-vertices :: Number) -> Graph:
  doc: "generate a graph with given number of vertices"
  if (num-vertices <= 1): 
    empty
  else:
    a-graph = generate-input(num-vertices - 1)
    
    range(0, 1 + num-random(num-vertices)).foldl({(_, b-graph):
        new-edge = edge(to-string(num-vertices - 1), 
          to-string(num-random(num-vertices - 1)), 
          (-1 * max-weight) + num-random((2 * max-weight) + 1))
        link(new-edge, b-graph)
      }, a-graph)
  end
end

fun mst-cmp(
    graph :: Graph,
    mst-a :: Graph,
    mst-b :: Graph)
  -> Boolean:
  doc: "verify two msts have same distance and are both valid"
  option1 = length-spanning-tree(graph, mst-a)
  option2 = length-spanning-tree(graph, mst-b)
  cases (Option) option1:
    | none => false
    | some(length1) =>
      cases (Option) option2:
        | none => false
        | some(length2) =>
          length1 == length2
      end
  end
end

small-test = 10
small-test-num = 30
largest-test = 50
fun sort-o-cle(
    mst-alg-a :: (Graph -> Graph),
    mst-alg-b :: (Graph -> Graph))
  -> Boolean:
  doc: "check if two mst algorithms return valid msts and perform as well as each other"
  fixed-tests = [list: empty, 
    # unconventional edge inputs
    [list: edge("randomname", "othername!@#$%^&*()", -1234.5678)],
    # handles double edges
    [list: edge("a", "b", 100), edge("a", "b", 50), edge("a", "b", 200)],
    # handles negative edges
    [list: edge("a", "b", -200), edge("b", "c", 50), edge("c", "a", 100)],
    # no cycles
    [list: edge("a", "b", -200), edge("b", "c", -50), edge("c", "a", -100), edge("a", "d", 100)],
    # handles multiple possible solutions
    [list: edge("B", "C", 20), edge("A", "D", 40), 
      edge("D", "B", 30), edge("A", "C", 20), edge("A", "B", 10), edge("A", "E", 100)],
    generate-input(largest-test)]
  random-tests = range(0, small-test-num).foldl({(_, tests):
      link(generate-input(1 + num-random(small-test)), tests)}, empty)
  
  inputs = fixed-tests.append(random-tests)
  inputs.map({(a-input): mst-cmp(a-input, mst-alg-a(a-input), mst-alg-b(a-input))})
    .foldl({(a, b): a and b}, true)
end
