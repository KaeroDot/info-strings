## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosettime (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettime (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosettime (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettime (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with key @var{key} and time @var{val} in following format:
## @example
## key:: %Y-%m-%dT%H:%M:%S.SSSSSS
##
## @end example
##
## The time is formatted as local time according ISO 8601 with six digits in microseconds.
## Expected input time system is a number of seconds since the epoch, as in
## function time().
##
## If @var{scell} is set, the key/value is enclosed by section(s) according @var{scell}.
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
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

