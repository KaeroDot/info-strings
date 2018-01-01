## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettimematrix (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettimematrix (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds lines after line
## '#startmatrix:: key' and before '#endmatrix:: key', parse numbers from lines
## and returns the values as number of seconds since the epoch (as in function
## time()). Expected time format is ISO 8601: %Y-%m-%dT%H:%M:%S.SSSSSS. The number
## of digits in fraction of seconds is not limited.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
