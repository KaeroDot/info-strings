## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosettime (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettime (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosettime (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettime (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with key @var{key} and time @var{val} in following format:
## @example
## key:: YYYY-mm-DDTHH:MM:SS.6S(+|-)HH:MM
## @end example
## The time is formatted as local time according extended ISO 8601 with six digits in microseconds.
## The time is expressed in local time, the time zone offset is explicitly specified.
## Expected input time system is a number of seconds since the epoch, as in
## function time().
##
## If @var{scell} is set, the key/value is enclosed by section(s) according @var{scell}.
## If @var{scell} is empty or contains empty value ([] or ''), it is considered as @var{scell} 
## is not set.
##
## If @var{infostr} is set, the key/value is put into existing @var{infostr} 
## sections, or sections are generated if needed and properly appended/inserted 
## into @var{infostr}.
##
## Example:
## @example
## infosettime('time of start',time())
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 4.1
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

