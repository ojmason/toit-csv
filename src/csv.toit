// Copyright (C) 2022  Oliver Mason.
// Use of this source code is governed by an MIT-style license that can be
// found in the package's LICENSE file.

EOL_ ::= 10
EOF_ ::= -1
COMMA_ ::= ','
QUOTE_ ::= '"'

/**
Reads the given $data as a CSV file, and returns a list of rows.

Processes a complete data set in the form of a ByteArray, as
  read by file.read-content. In case the input has a header
  (which is optional, off by default), it returns a list of hash
  tables, where each entry is a line indexed by the column header.

If there is no header, it returns a list of lists, where each
  list represents a row in the table. Even if the data contains only
  a single line, it will still be enclosed in a list.
*/
read-csv-data data/ByteArray --header/bool=false -> List:
  pos := 0
  result := []
  headers := []
  if header:
    line1 := read-csv-line_ data
    pos = line1[0]
    headers = line1[1]
  while pos < data.size:
    line := read-csv-line_ data --pos=pos
    if header:
      row := {:}
      headers.size.repeat:
        row[headers[it]] = line[1][it]
      result.add row
    else: result.add line[1]
    pos = line[0]
  return result

/**
Reads a single line of the given CSV $data.

Input is read from the provided ByteArray until either a newline
  character or the end of the buffer is reached.

If a field is surrounded by double quotes, then it can
  also contain a newline character, which is taken as part of the field.

By default it starts on the first character of the data.
If $pos is provided starts at the given position.

Returns a list of fields.
*/
read-csv-line data/ByteArray --pos/int=0 -> List:
  return (read-csv-line_ data --pos=pos)[1]

read-csv-line_ data/ByteArray --pos/int=0 -> List:
  line := []
  eol := false
  while not eol:
    next-field := read-csv-field_ data pos
    eol = next-field[0]
    pos = next-field[1] + 1
    line.add next-field[2]
  return [pos,line]

read-csv-field_ data/ByteArray pos/int -> List:
  start := pos
  end := pos
  state := 0
  new-state := 0
  clean-up := false
  char := 0
  while new-state != -1:
    char = read-next-char_ data pos
    if state == 0:
      if char == EOL_ or char == EOF_:
        return [true, pos, ""]
      if char == QUOTE_:
        start++
        new-state = 1
      else:
        if char == COMMA_:
          end = pos
          new-state = 6
        else:
          new-state = 5

    if state == 1:
      if char == QUOTE_:
        end = pos
        new-state = 2
      else:
        new-state = 1

    if state == 2:
      if char == QUOTE_:
        clean-up = true
        new-state = 1
      else:
        if char == EOF_ or char == EOL_:
          new-state = 7
        else:
          if char == COMMA_:
            new-state = 6
          else:
            throw "Unexpected char $char at position $pos: $(data.to-string-non-throwing start pos)"

    if state == 3:
      if char != QUOTE_:
        throw "Expecting quote at position $pos."
      else: new-state = 5

    // there is no state 4

    if state == 5:
      if char == EOF_ or char == EOL_:
        end = pos
        new-state = 7
      else:
        if char == COMMA_:
          end = pos
          new-state = 6
        else:
          new-state = 5

    if state == 6:
      if clean-up:
        return [false, pos - 1, remove-double-quotes_ (data.to-string start end)]
      else:
        return [false, pos - 1, data.to-string start end]

    if state == 7:
      if char == EOL_:
        new-state = 7
      else:
        if clean-up:
          return [true, pos - 1, remove-double-quotes_ (data.to-string start end)]
        else:
          return [true, pos - 1, data.to-string start end]

    pos++
    state = new-state

  throw "Illegal CSV format at position $pos"

read-next-char_ data/ByteArray pos/int -> int:
  if pos >= data.size: return EOF_
  if data[pos] == 10 or data[pos] == 13: return EOL_
  return data[pos]

remove-double-quotes_ str/string -> string:
  loc := str.index-of "\"\""
  if loc > -1:
    return (str[..loc + 1] + (remove-double-quotes_ str[loc + 2..]))
  else: return str
