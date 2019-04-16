## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettime (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettime (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds line with content "key:: value" and returns 
## the value as number of seconds since the epoch (as in function time()). Expected time format 
## is extended ISO 8601:
## @example
## YYYY-mm-DDTHH:MM:SS[.nS][Z|(+|-)HH:MM]
## @end example
## The number of digits in fraction of seconds
## is not limited, however in GNU Octave the best precision is in microseonds, Matlab can cope 
## with nanoseconds.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
## infostr = sprintf('T:: 2011-12-13T14:15:16.123456+00:00')
## infogettime(infostr,'T')
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2013
## Version: 4.1
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

