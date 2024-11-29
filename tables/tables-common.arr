use context essentials2021

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both tables-code.arr and tables-tests.arr
empty-art-table = table: id :: Number, cost :: Number, currency :: String end

art-table = table: id :: Number, cost :: Number, currency :: String
  row: 1, 10, "A"
  row: 2, 30, "A"
  row: 3, 40, "B"
  row: 4, 40, "B"
  row: 4, 40, "B"
  row: 10, 30, "C"
  row: 100, 1, "D"
end

empty-cc-table = table: from-c :: String, to-c :: String, conv-rate :: Number end

cc-table = table: from-c :: String, to-c :: String, conv-rate :: Number 
  row: "A", "B", 2
  row: "B", "A", 1/2
  row: "A", "C", 3.1415
  row: "A", "D", 0
  row: "B", "C", 10
  row: "B", "C", 20
end