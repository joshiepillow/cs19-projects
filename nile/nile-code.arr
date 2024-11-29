use context essentials2021
include shared-gdrive("nile-definitions.arr", "1G0l8Il4LBoenLdJ6tfu4grP4vGouMN6M")
include shared-gdrive("nile-validation.arr", "1bndIyRPJsjn95JLjKpr9wviZdGU7jdzb")

provide:
  recommend, recommend-in-ok, recommend-out-ok,
  popular-pairs, popular-pairs-in-ok, popular-pairs-out-ok
end

include my-gdrive("nile-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.
data Pair<A, B>:
  | cpair(first :: A, second :: B)
end

fun list-length<T>(list-t :: List<T>) -> Number:
  doc: "Returns the length of a list."
  list-t.foldl(lam(_, acc): acc + 1 end, 0)
where:
  list-length([list: ]) is 0
  list-length([list: 1, 2, 3]) is 3
  list-length([list: "a"]) is 1
end

fun list-contains<T>(list-t :: List<T>, t :: T) -> Boolean:
  doc: "Evaluates whether a list contains a given element"
  list-length(list-t.filter(lam(elem): elem == t end)) > 0
where:
  list-contains([list: ], 1) is false
  list-contains([list: 1, 2, 3], 2) is true
  list-contains([list: 1, 2, 2], 2) is true
  list-contains([list: "a"], "a") is true
  list-contains([list: "a", "a", "b", "c"], "d") is false
end

fun concat<T>(l1 :: List<T>, l2 :: List<T>) -> List<T>:
  doc: "Concatenates two lists into a single list preserving order"
  l1.foldr(lam(elem, acc): link(elem, acc) end, l2)
where:
  concat(empty, empty) is empty
  concat(empty, [list: 1]) is [list: 1]
  concat([list: 1], empty) is [list: 1]
  concat([list: 1, 2], [list: 3, 4, 5]) is [list: 1, 2, 3, 4, 5]
end

fun flatten<T>(list-of-lists :: List<List<T>>) -> List<T>:
  doc: "Flattens a list of lists of elements into a list of elements."
  list-of-lists.foldl(lam(elem, acc): concat(acc, elem) end, empty)
where:
  flatten(empty) is empty
  flatten([list: empty]) is empty
  flatten([list: [list: 1]]) is [list: 1]
  flatten([list: [list: 1, 2], [list: 0], [list: 6, 7, 8]]) is [list: 1, 2, 0, 6, 7, 8]
end

fun increment<T>(li :: List<Pair<T, Number>>, elem :: T) -> List<Pair<T, Number>>:
  doc: "Increment the count associated with an element in an list counting occurances"
  li-contains-elem = li.foldl(lam(a-pair, acc): acc or (a-pair.first == elem) end, false)
  if (li-contains-elem):
    li.map(lam(a-pair): 
        if (a-pair.first == elem):
          cpair(a-pair.first, a-pair.second + 1)
        else:
          a-pair
        end
      end)
  else:
    link(cpair(elem, 1), li)
  end
where:
  increment(empty, "a") is [list: cpair("a", 1)]
  increment([list: cpair("a", 1)], "a") is [list: cpair("a", 2)]
  increment([list: cpair("b", 1)], "a") is [list: cpair("a", 1), cpair("b", 1)]
  increment([list: cpair("a", 1), cpair("b", 1)], "a") is [list: cpair("a", 2), cpair("b", 1)]
end

fun count<T>(li :: List<T>) -> List<Pair<T, Number>>:
  doc: "Count the number of occurances of each element in a list"
  li.foldl(lam(elem, acc): increment(acc, elem) end, empty)
where:
  count(empty) is empty
  count([list: "a"]) is [list: cpair("a", 1)]
  count([list: "a", "a"]) is [list: cpair("a", 2)] 
  count([list: "b", "a"]) is [list: cpair("a", 1), cpair("b", 1)]
  count([list: "b", "a", "a", "b", "a"]) is [list: cpair("a", 3), cpair("b", 2)]
end
  
fun pick-largest<T>(li :: List<Pair<T, Number>>) -> Recommendation<T>:
  doc: ```Takes a list of pairs of objects and their counts, 
       and creates a recommendation with the objects with highest counts```
  li.foldl(lam(a-pair, acc): 
      if (a-pair.second == acc.count):
        recommendation(a-pair.second, link(a-pair.first, acc.content))
      else if (a-pair.second > acc.count):
        recommendation(a-pair.second, [list: a-pair.first])
      else:
        acc
      end
    end, recommendation(0, empty))
where:
  pick-largest(empty) is recommendation(0, empty)
  pick-largest([list: cpair("a", 2)]) is recommendation(2, [list: "a"])
  pick-largest([list: cpair("a", 2), cpair("b", 1)]) is recommendation(2, [list: "a"])
  pick-largest([list: cpair("a", 2), cpair("b", 1), cpair("c", 2)]) is recommendation(2, [list: "a", "c"])
end

fun recommend(title :: String, book-records :: List<File>) 
  -> Recommendation<String>:
  doc: ```Takes in the title of a book and a list of files,
       and returns a recommendation of book(s) to be paired with title
       based on the files in book-records.```
  # isolate contents by removing file names and files that do not contain title
  cleaned = book-records.map(lam(a-file): a-file.content end)
    .filter(lam(content): list-contains(content, title) end)
  # create a list of all books paired with input title
  paired = flatten(cleaned).filter(lam(elem): not(elem == title) end)
  pick-largest(count(paired))
end

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

fun generate-pairs(a-file :: File) -> List<BookPair>:
  doc: "Takes a file and returns a list of all pairs of books in the file"
  flatten(a-file.content.map(lam(elem1): a-file.content
        .filter(lam(elem2): elem1 < elem2 end) # prevent double counting
        .map(lam(elem2): pair(elem1, elem2) end) end))
where:
  generate-pairs(file("a", empty)) is empty
  generate-pairs(file("a", [list: "a"])) is empty
  generate-pairs(file("a", [list: "a", "b"])) is [list: pair("a", "b")]
  generate-pairs(file("a", [list: "c", "a", "b"])) is [list: pair("a", "c"), pair("a", "b"), pair("b", "c")]
end

fun popular-pairs(records :: List<File>) -> Recommendation<BookPair>:
  doc: ```Takes in a list of files and returns a recommendation of
       the most popular pair(s) of books in records.```
  pairs = flatten(records.map(lam(a-file): generate-pairs(a-file) end))
  pick-largest(count(pairs))
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