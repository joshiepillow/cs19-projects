use context essentials2021
include shared-gdrive("mst-definitions.arr", "1BGkPeyFNhp0ND5sENwAXbL-BgQ9ZB_Nt")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in 
# both mst-code.arr and mst-tests.arr
include string-dict

### Taken from DCIC

data Element:
  | element(val, ref parent :: Option<Element>)
end

fun is-in-same-set(e1 :: Element, e2 :: Element) -> Boolean:
  s1 = fynd(e1)
  s2 = fynd(e2)
  identical(s1, s2)
end

fun update-set-with(child :: Element, parent :: Element):
  child!{parent: some(parent)}
end

fun union(e1 :: Element, e2 :: Element):
  s1 = fynd(e1)
  s2 = fynd(e2)
  if identical(s1, s2):
    s1
  else:
    update-set-with(s1, s2)
  end
end

fun fynd(e :: Element) -> Element:
  cases (Option) e!parent block:
    | none => e
    | some(p) =>
      new-parent = fynd(p)
      e!{parent: some(new-parent)}
      new-parent
  end
end

### My code

fun length-spanning-tree(graph :: Graph, mst :: Graph) -> Option<Number>:
  doc: "return the total distance in mst if it is valid"
  # check if mst only contains edges from graph
  from-graph = mst.map({(a-edge): member(graph, a-edge)}).foldl({(a, b): a and b}, true)

  # check if mst has cycles
  vertex-list = mst.foldl({(an-edge, a-list): 
      link(an-edge.a, link(an-edge.b, a-list))}, empty)

  map-to-element = vertex-list.foldl({(a-vertex, a-dict):
      a-dict.set(a-vertex, element(0, none))}, [string-dict: ])

  no-cycles = is-some(mst.foldl({(a-edge, a-option):
        cases (Option) a-option:
          | none => none
          | some(a-dict) =>
            a = a-dict.get-value(a-edge.a)
            b = a-dict.get-value(a-edge.b)
            if is-in-same-set(a, b):
              none
            else:
              joined = union(a, b)
              some(a-dict.set(a-edge.a, joined).set(a-edge.b, joined))
            end
        end
      }, some(map-to-element)))
    
  # check if mst visits every vertex
  visit-all = graph.map({(a-edge): 
      member(vertex-list, a-edge.a) and member(vertex-list, a-edge.b)})
    .foldl({(a, b): a and b}, true)
  
  if (from-graph and no-cycles and visit-all):
    # total length
    some(mst.foldl({(a-edge, sum): sum + a-edge.weight}, 0))
  else:
    none
  end
where:
  # works on tree with no edges
  length-spanning-tree(empty, empty) is some(0)
  length-spanning-tree([list: edge("A", "B", 0)], empty) is none
  length-spanning-tree(empty, [list: edge("A", "B", 0)]) is none
  
  # flag msts that contains edges not from graph
  length-spanning-tree([list: edge("A", "B", 0), edge("B", "C", 0)], 
    [list: edge("A", "B", 0), edge("B", "D", 0)]) is none 
  length-spanning-tree([list: edge("A", "B", 0), edge("B", "C", 0)], 
    [list: edge("A", "B", 0), edge("B", "C", 1)]) is none 
  
  # flag mst with cycle
  length-spanning-tree([list: edge("A", "B", 0)], 
    [list: edge("A", "B", 0), edge("A", "B", 0)]) is none
  length-spanning-tree([list: edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)], 
    [list: edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)]) is none
  length-spanning-tree([list: edge("A", "B", 0), edge("B", "C", 0), 
      edge("A", "C", 0), edge("A", "D", 0), edge("D", "B", 0)], 
    [list: edge("D", "B", 0), edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)]) is none
  
  # flag mst that doesn't visit every vertex
  length-spanning-tree([list: edge("A", "B", 0), edge("A", "C", 0)], 
    [list: edge("A", "B", 0), edge("A", "B", 0)]) is none
  length-spanning-tree([list: edge("A", "B", 0), edge("A", "C", 0)], 
    [list: edge("A", "B", 0)]) is none
  length-spanning-tree([list: edge("A", "B", 0), edge("B", "C", 0), 
      edge("A", "C", 0), edge("A", "D", 0), edge("D", "B", 0)], 
    [list: edge("A", "B", 0), edge("B", "C", 0), edge("A", "C", 0)]) is none
  length-spanning-tree([list: edge("A", "B", 0), edge("B", "C", 0), 
      edge("A", "C", 0), edge("A", "D", 0), edge("D", "B", 0)], 
    [list: edge("A", "B", 0), edge("B", "C", 0)]) is none
  
  # find length of valid mst
  length-spanning-tree([list: edge("A", "B", 0)], [list: edge("A", "B", 0)]) is some(0)
  length-spanning-tree([list: edge("A", "B", 10)], [list: edge("A", "B", 10)]) is some(10)
  length-spanning-tree([list: edge("A", "B", 0), edge("B", "C", 0), 
      edge("A", "C", 0), edge("A", "D", 0), edge("D", "B", 0)], 
    [list: edge("A", "D", 0), edge("A", "B", 0), edge("B", "C", 0)]) is some(0)
  length-spanning-tree([list: edge("A", "B", 10), edge("B", "C", 20), 
      edge("A", "C", 30), edge("A", "D", 40), edge("D", "B", 50)], 
    [list: edge("A", "D", 40), edge("A", "B", 10), edge("B", "C", 20)]) is some(70)
end