//

import ..src.csv
import expect

main:
  print "simple line"
  expect.expect-list-equals
    ["aa","bb","cc"]
    read-csv-line "aa,bb,cc".to-byte-array

  print "line with quotes"
  expect.expect-list-equals
    ["aa","bb","cc"]
    read-csv-line "aa,\"bb\",cc".to-byte-array

  csv-file := """
    id,name,age
    1,Albert,9
    2,Richard,7
    3,"Hans Joachim",12
    """.to-byte-array

  print "file, no header"
  expect.expect-list-equals
    [["id","name","age"], ["1","Albert","9"], ["2","Richard","7"],["3","Hans Joachim","12"]]
    read-csv-data csv-file

  print "file, with header"
  expect.expect-list-equals
    [{"id":"1","name":"Albert","age":"9"},
     {"id":"2","name":"Richard","age":"7"},
     {"id":"3","name":"Hans Joachim","age":"12"}]
    read-csv-data --header=true csv-file

  csv-file = """
    "aaa","b
    bb","ccc"
    "aaa","b""bb","ccc"
    """.to-byte-array

  print "multi-line, quotes"
  expect.expect-list-equals
    [["aaa","b\nbb","ccc"],
     ["aaa","b\"bb","ccc"]]
    read-csv-data csv-file

  csv-file = """
    a,b,c""".to-byte-array

  print "file without final linebreak"
  expect.expect-list-equals
    [["a","b","c"]]
    read-csv-data csv-file

  print "line with embedded quotes"
  expect.expect-list-equals
    ["zz","cc\"c","dd"]
    read-csv-line "zz,\"cc\"\"c\",dd".to-byte-array


  print "empty fields and spaces"
  expect.expect-list-equals
    ["a","","c","d ","  e"]
    read-csv-line "a,,c,d ,  e".to-byte-array

  print "two empty fields"
  expect.expect-list-equals
    ["a","","","d",""]
    read-csv-line "a,,,d,".to-byte-array

  print "double double quotes"
  expect.expect-list-equals
    ["a double \"\" quote"]
    read-csv-line "\"a double \"\"\"\" quote\"".to-byte-array

  print "double quote at end of line"
  expect.expect-list-equals
    ["double quote\""]
    read-csv-line "\"double quote\"\"\"".to-byte-array
