## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettime (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettime (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds line with content "key:: value" and returns 
## the value as number of seconds since the epoch (as in function time()). Expected time format 
## is ISO 8601: %Y-%m-%dT%H:%M:%S.SSSSSS. The number of digits in fraction of seconds is not limited.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
## infostr = sprintf('T:: 2013-12-11T22:59:30.123456')
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

