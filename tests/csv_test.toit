//

import ..src.csv
import expect

main:
  print "simple line"
  expect.expect_list_equals
    ["aa","bb","cc"]
    read_csv_line "aa,bb,cc".to_byte_array

  print "line with quotes"
  expect.expect_list_equals
    ["aa","bb","cc"]
    read_csv_line "aa,\"bb\",cc".to_byte_array

  csv_file := """
    id,name,age
    1,Albert,9
    2,Richard,7
    3,"Hans Joachim",12
    """.to_byte_array

  print "file, no header"
  expect.expect_list_equals 
    [["id","name","age"], ["1","Albert","9"], ["2","Richard","7"],["3","Hans Joachim","12"]]
    read_csv_data csv_file

  print "file, with header"
  expect.expect_list_equals
    [{"id":"1","name":"Albert","age":"9"},
     {"id":"2","name":"Richard","age":"7"},
     {"id":"3","name":"Hans Joachim","age":"12"}]
    read_csv_data --header=true csv_file

  csv_file = """
    "aaa","b
    bb","ccc"
    "aaa","b""bb","ccc"
    """.to_byte_array

  print "multi-line, quotes"
  expect.expect_list_equals
    [["aaa","b\nbb","ccc"],
     ["aaa","b\"bb","ccc"]]
    read_csv_data csv_file

  csv_file = """
    a,b,c""".to_byte_array

  print "file without final linebreak"
  expect.expect_list_equals
    [["a","b","c"]]
    read_csv_data csv_file

  print "line with embedded quotes"
  expect.expect_list_equals
    ["zz","cc\"c","dd"]
    read_csv_line "zz,\"cc\"\"c\",dd".to_byte_array
    

  print "empty fields and spaces"
  expect.expect_list_equals
    ["a","","c","d ","  e"] 
    read_csv_line "a,,c,d ,  e".to_byte_array
    
  print "two empty fields"
  expect.expect_list_equals
    ["a","","","d",""] 
    read_csv_line "a,,,d,".to_byte_array
  
  print "double double quotes"
  expect.expect_list_equals
    ["a double \"\" quote"]
    read_csv_line "\"a double \"\"\"\" quote\"".to_byte_array
    