use context essentials2021
include shared-gdrive("join-lists-definitions.arr", "1gNl8Rt88uWqpbv0Hx9Fkh6ajnNoDr164")

provide:
  j-first, j-rest, j-length, j-nth, j-max, j-map, j-filter, j-reduce, j-sort,
end

include my-gdrive("join-lists-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in
# this file.

fun j-first<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> A:
  doc: "returns the first element of a joinlist"
  cases (JoinList) jl:
    | one(elt) => elt
    | many(mjl) => mjl.rebalance-and-split({(left, _): j-first(left)})
  end
end

fun j-rest<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> JoinList<A>:
  doc: "returns the remainder of the joinlist excluding the first element"
  cases (JoinList) jl:
    | one(elt) => empty-join-list
    | many(mjl) => mjl.rebalance-and-split({(left, right): j-rest(left).join(right)})
  end
end

fun j-length<A>(jl :: JoinList<A>) -> Number:
  doc: "returns the number of elements in a joinlsit"
  cases (JoinList) jl:
    | empty-join-list => 0
    | one(elt) => 1
    | many(mjl) => mjl.rebalance-and-split({(left, right): j-length(left) + j-length(right)})
  end
end

fun j-nth<A>(jl :: JoinList<A>%(is-non-empty-jl), n :: Number) -> A:
  doc: "returns the element of a joinlist at a given index"
  cases (JoinList) jl:
    | one(elt) => elt
    | many(mjl) => mjl.rebalance-and-split(lam(left, right): 
          left-length = left.length()
          if (left-length > n):
            j-nth(left, n)
          else:
            j-nth(right, n - left-length)
          end
        end)
  end
end

fun j-max<A>(jl :: JoinList<A>%(is-non-empty-jl), cmp :: (A, A -> Boolean)) -> A:
  doc: "returns the largest element in a joinlist given a comparison function"
  cases (JoinList) jl:
    | one(elt) => elt
    | many(mjl) => mjl.rebalance-and-split(lam(left, right): 
          left-max = j-max(left, cmp)
          right-max = j-max(right, cmp)
          if cmp(left-max, right-max):
            left-max
          else:
            right-max
          end
        end)
  end
end

fun j-map<A,B>(map-fun :: (A -> B), jl :: JoinList<A>) -> JoinList<B>:
  doc: "maps each element of a joinlist given a map function"
  cases (JoinList) jl:
    | empty-join-list => empty-join-list
    | one(elt) => one(map-fun(elt))
    | many(mjl) => mjl.rebalance-and-split(lam(left, right): 
          left-map = j-map(map-fun, left)
          right-map = j-map(map-fun, right)
          left-map.join(right-map)
        end)
  end
end

fun j-filter<A>(filter-fun :: (A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  doc: "filters out elements of a joinlist given a filter function"
  cases (JoinList) jl:
    | empty-join-list => empty-join-list
    | one(elt) => 
      if filter-fun(elt):
        one(elt)
      else:
        empty-join-list
      end
    | many(mjl) => mjl.rebalance-and-split(lam(left, right): 
          left-filter = j-filter(filter-fun, left)
          right-filter = j-filter(filter-fun, right)
          left-filter.join(right-filter)
        end)
  end
end

fun j-reduce<A>(reduce-func :: (A, A -> A), jl :: JoinList<A>%(is-non-empty-jl)) -> A:
  doc: "combines the elements of a joinlist given a reduction function"
  cases (JoinList) jl:
    | one(elt) => elt
    | many(mjl) => mjl.rebalance-and-split(lam(left, right): 
          left-reduce = j-reduce(reduce-func, left)
          right-reduce = j-reduce(reduce-func, right)
          reduce-func(left-reduce, right-reduce)
        end)
  end
end

fun insert<A>(cmp-fun :: (A, A -> Boolean), elem :: A, 
    jl :: JoinList<A>%(is-non-empty-jl)) -> JoinList<A>:
  doc: "inserts an element into a sorted joinlist"
  cases (JoinList) jl:
    | one(elt) => 
      if (cmp-fun(elt, elem)):
        [join-list: elt, elem]
      else:
        [join-list: elem, elt]
      end
    | many(mjl) => mjl.rebalance-and-split(lam(left, right):
          if (cmp-fun(elem, j-first(right))):
            insert(cmp-fun, elem, left).join(right)
          else:
            left.join(insert(cmp-fun, elem, right))
          end
        end)
  end
where:
  less-func = {(a, b): a < b}
  insert(less-func, 0, [join-list: 1]) is [join-list: 0, 1]
  insert(less-func, 2, [join-list: 1]) is [join-list: 1, 2]
  insert(less-func, 0, [join-list: 1, 2, 4, 5]) is [join-list: 0, 1, 2, 4, 5]
  insert(less-func, 2, [join-list: 1, 2, 4, 5]) is [join-list: 1, 2, 2, 4, 5]
  insert(less-func, 3, [join-list: 1, 2, 4, 5]) is [join-list: 1, 2, 3, 4, 5]
  insert(less-func, 4, [join-list: 1, 2, 4, 5]) is [join-list: 1, 2, 4, 4, 5]
  insert(less-func, 6, [join-list: 1, 2, 4, 5]) is [join-list: 1, 2, 4, 5, 6]
end 

fun merge<A>(cmp-fun :: (A, A -> Boolean), first :: JoinList<A>%(is-non-empty-jl), 
    second :: JoinList<A>%(is-non-empty-jl)) -> JoinList<A>:
  doc: "merges two sorted joinlists into a sorted joinlist"
  cases (JoinList) first:
    | one(elt) => insert(cmp-fun, elt, second)
    | many(_) => merge(cmp-fun, j-rest(first), insert(cmp-fun, j-first(first), second))
  end
where:
  less-func = {(a, b): a < b}
  merge(less-func, [join-list: 0], [join-list: 1]) is [join-list: 0, 1]
  merge(less-func, [join-list: 1], [join-list: 0]) is [join-list: 0, 1]
  merge(less-func, [join-list: 0, 1], [join-list: 2, 3]) is [join-list: 0, 1, 2, 3]
  merge(less-func, [join-list: 0, 2], [join-list: 1, 3]) is [join-list: 0, 1, 2, 3]
  merge(less-func, [join-list: 0, 3], [join-list: 1, 2]) is [join-list: 0, 1, 2, 3]
  merge(less-func, [join-list: 1, 2], [join-list: 0, 3]) is [join-list: 0, 1, 2, 3]
  merge(less-func, [join-list: 1, 3], [join-list: 0, 2]) is [join-list: 0, 1, 2, 3]
end 
            
fun j-sort<A>(cmp-fun :: (A, A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  doc: "sorts a joinlist given a comparison function"
  cases (JoinList) jl: 
    | empty-join-list => empty-join-list
    | one(elt) => one(elt)
    | many(mjl) => mjl.rebalance-and-split(lam(left, right):
          merge(cmp-fun, j-sort(cmp-fun, left), j-sort(cmp-fun, right))
        end)
  end
end
