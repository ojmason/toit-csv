//

EOL ::= 10
EOF ::= -1
COMMA ::= ','
QUOTE ::= '"'

/**
Process a complete data set in the form of a ByteArray, as
read by file.read_content. In case the input has a header
(which is optional, off by default), it returns a list of hash
tables, where each entry is a line indexed by the column header.
If there is no header, it returns a list of lists, where each
list represents a row in the table.
Even if the data contains only a single line, it will still be
enclosed in a list.
*/
read_csv_data data/ByteArray --header=false -> List:
  pos := 0
  result := []
  headers := []
  if header:
    line1 := read_csv_line1 data
    pos = line1[0]
    headers = line1[1]
  while pos < data.size:
    line := read_csv_line1 data --pos=pos
    if header:
      row := {:}
      headers.size.repeat:
        row[headers[it]] = line[1][it]
      result.add row
    else: result.add line[1]
    pos = line[0]
  return result        

/**
Process a single line of CSV data. Input is read from the provided
ByteArray until either a newline character or the end of the buffer
is reached. If a field is surrounded by double quotes, then it can
also contain a newline character, which is taken as part of the field.
By default it starts on the first character of the data, but as an optional
argument a different starting position can be provided.
This function returns a list of the fields.
*/
read_csv_line data/ByteArray --pos/int=0 -> List:
  return (read_csv_line1 data --pos=pos)[1]

read_csv_line1 data/ByteArray --pos/int=0 -> List:
  line := []
  eol := false
  while not eol:
    next_field := read_csv_field data pos
    eol = next_field[0]
    pos = next_field[1] + 1
    line.add next_field[2]
  return [pos,line]
  
read_csv_field data/ByteArray pos/int -> List:
  start := pos
  end := pos
  state := 0
  new_state := 0
  clean_up := false
  char := 0
  while new_state != -1:
    char = read_next_char data pos
    if state == 0:
      if char == EOL or char == EOF:
        return [true, pos, ""]
      if char == QUOTE:
        start++
        new_state = 1
      else:
        if char == COMMA:
          end = pos
          new_state = 6
        else:
          new_state = 5

    if state == 1:
      if char == QUOTE:
        end = pos
        new_state = 2
      else:
        new_state = 1

    if state == 2:
      if char == QUOTE:
        clean_up = true
        new_state = 1
      else:
        if char == EOF or char == EOL:
          new_state = 7
        else:
          if char == COMMA:
            new_state = 6
          else:
            throw "Unexpected char $char at position $pos: $(data.to_string start pos)"
           
    if state == 3:
      if char != QUOTE:
        throw "Expecting quote at position $pos."
      else: new_state = 5

    // there is no state 4
   
    if state == 5:
      if char == EOF or char == EOL:
        end = pos
        new_state = 7
      else:
        if char == COMMA:
          end = pos
          new_state = 6
        else:
          new_state = 5
    
    if state == 6:
      if clean_up:
        return [false,pos-1,remove_double_quotes (data.to_string start end)]
      else: return [false,pos-1,data.to_string start end]

    if state == 7:
      if char == EOL:
        new_state = 7
      else:
        if clean_up:
          return [true,pos-1,remove_double_quotes (data.to_string start end)]
        else: return [true,pos-1,data.to_string start end]

    pos++
    state = new_state
    
  throw "Illegal CSV format at position $pos"

read_next_char data/ByteArray pos/int -> int:
  if pos >= data.size: return EOF
  if data[pos] == 10 or data[pos] == 13: return EOL
  return data[pos]

remove_double_quotes str/string -> string:
  loc := str.index_of "\"\""
  if loc > -1:
    return (str[..loc+1] + (remove_double_quotes str[loc+2..]))
  else: return str
  