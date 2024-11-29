use context essentials2021
provide: overlap end

include my-gdrive("docdiff-common.arr")
import gdrive-js("docdiff_qtm-validation.js", "11H5gJQtW9TJaiFkWw51fR4_oIibmLr7X") as Validation
provide from Validation: overlap-in-ok, overlap-out-ok end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.

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

fun count(docu :: List<String>, word :: String) -> Number:
  doc: "Count the number of occurances of a word in a document."
  list-length(docu.filter(lam(elem): elem == word end))
where:
  count([list: ], "3") is 0
  count([list: "1", "2"], "3") is 0
  count([list: "1", "2"], "1") is 1
  count([list: "1", "1"], "1") is 2
end

fun word-set(docu :: List<String>, prior-word-set :: List<String>) -> List<String>:
  doc: "Add the new words in a document to a set of words."
  cases (List) docu:
    | empty => prior-word-set
    | link(f, r) => 
      if list-contains(prior-word-set, f):
        word-set(r, prior-word-set)
      else:
        word-set(r, link(f, prior-word-set))
      end
  end
where:
  word-set([list: "1", "2", "3"], [list: ]) is [list: "3", "2", "1"]
  word-set([list: ], [list: "1", "2", "3"]) is [list: "1", "2", "3"]
  word-set([list: "1", "1", "2"], [list: "2"]) is [list: "1", "2"]
  word-set([list: ], [list: ]) is [list: ]
  word-set([list: "1", "2", "3"], [list: "2", "4"]) is [list: "3", "1", "2", "4"]
end

fun dot-prod(doc1 :: List<String>, doc2 :: List<String>) -> Number:
  doc: "Given two lists of strings, compute the dot product of their word frequencies"
  words = word-set(doc2, word-set(doc1, empty))
  words.map(lam(elem): count(doc1, elem) * count(doc2, elem) end)
    .foldl(_plus, 0)
where:
  dot-prod(empty, empty) is 0
  dot-prod(empty, [list: "1"]) is 0
  dot-prod([list: "1", "2", "3"], empty) is 0
  dot-prod([list: "1", "2", "3"], [list: "1", "1", "4"]) is 2
  dot-prod([list: "1", "1", "2", "3", "4"], [list: "1", "1", "4", "4", "5"]) is 6
end

fun overlap(doc1 :: List<String>, doc2 :: List<String>) -> Number:
  doc: "Given two documents, return a score corresponding to the similarity of their word lists ignoring capitalization."
  doc1-lower = doc1.map(string-to-lower)
  doc2-lower = doc2.map(string-to-lower)
  mag-squared1 = dot-prod(doc1-lower, doc1-lower)
  mag-squared2 = dot-prod(doc2-lower, doc2-lower)
  dot = dot-prod(doc1-lower, doc2-lower)
  if (mag-squared1 >= mag-squared2):
    dot / mag-squared1
  else:
    dot / mag-squared2
  end
end

check "overlap works when varying document lengths and repetition":
  overlap([list: "1", "2", "3"], [list: "4", "5", "6"]) is 0
  overlap([list: "1", "2", "3"], [list: "1", "2", "3"]) is 1
  overlap([list: "1", "2", "3"], [list: "3", "1", "2"]) is 1
  overlap([list: "1", "2", "3"], [list: "1", "1"]) is 1/2
  overlap([list: "1", "2", "3"], [list: "1", "1", "4"]) is 2/5
  overlap([list: "1", "1", "2", "2", "3", "3"], [list: "1", "1", "4"]) is 1/3
  overlap([list: "3", "1", "1", "2", "3", "2"], [list: "1", "4", "1"]) is 1/3
  overlap([list: "0", "1", "2", "3", "4"], [list: "1", "4", "1"]) is 3/5
  overlap([list: "0"], [list: "0", "1", "1", "1"]) is 1/10
  overlap([list: "0", "1", "2", "3", "4", "5"], [list: "0", "1", "1", "1"]) is 2/5
  overlap([list: "0", "1", "2", "3", "4", "5", "5", "3", "2", "1", "6", "5", "4", "3", "2", "6", "7", "4", "5", "3", "2", "2", "7", "8", "5", "7", "5", "4", "7"], [list: "0", "1", "1", "1", "5", "1", "3", "6", "6", "3", "2", "7", "9"]) is 36/119
end
check "overlap works when varying capitalization":
  overlap([list: "oNe", "two", "thrEe"],  [list: "three", "oNe", "OnE"]) is 3/5
  overlap([list: "one"], [list: "one", "one", "one", "onE", "oNe", "one", "one"]) is 1/7
end