## Copyright (C) 2021 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} [@var{section}, @var{endposition}] = infogetsection (@var{infostr}, @var{key})
## @deftypefnx {Function File} [@var{section}, @var{endposition}]= infogetsection (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds lines after line
## '#startsection:: key' and before line '#endsection:: key' and returns them.
## 
## If @var{scell} is set, the section is searched in section(s) defined by string(s) in cell.
## If @var{scell} is empty or contains empty value ([] or ''), it is considered as @var{scell} 
## is not set.
##
## Second output argument returns the index of end of section.
##
## Example:
## @example
