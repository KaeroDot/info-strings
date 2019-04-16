## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettimematrix (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettimematrix (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds lines after line
## '#startmatrix:: key' and before '#endmatrix:: key', parse numbers from lines
## and returns the values as number of seconds since the epoch (as in function
## time()). Expected time format is extended ISO 8601:
## @example
## YYYY-mm-DDTHH:MM:SS[.nS][Z|(+|-)HH:MM]
## @end example
## The number of digits in fraction of seconds
## is not limited, however in GNU Octave the best precision is in microseonds, Matlab can cope 
## with nanoseconds.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
## If @var{scell} is empty or contains empty value ([] or ''), it is considered as @var{scell} 
## is not set.
##
## Example:
## @example
