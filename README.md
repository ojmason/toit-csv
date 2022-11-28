# CSV

Basic functions to parse CSV files from data supplied in ByteArrays.

The implementation follows RFC 4180,
_Common Format and MIME Type for Comma-Separated Values (CSV) Files_

## Usage

There are two functions:

1. `read_csv_data data/ByteArray --header/bool=false -> List:`

This converts a ByteArray into a table, a List of rows. The rows are either
lists of fields, or, if the header flag was set as true, maps of fields
indexed by column title (with the first row of the data being treated as
the column titles).

The main application will be to process a CSV file that has been loaded using
the `file.read_content` function from the `host` package.


2. `read_csv_line data/ByteArray --pos/int -> List:`

This splits a string into fields, separated by commas. It properly handles
double quotes around fields, and empty fields, as well as quotes escaped by
duplication.



There is a test suite in the `tests` directory which gives some usage
examples.