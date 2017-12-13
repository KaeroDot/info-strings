## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogetmatrix (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogetmatrix (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds lines after line
## '#startmatrix:: key' and before '#endmatrix:: key', parse numbers from lines
## and return as matrix.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
