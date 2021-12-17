## Copyright (C) 2021 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosettimematrix (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettimematrix (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosettimematrix (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettimematrix (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with key @var{key} and matrix of times @var{val} in following format:
## @example
## #startmatrix:: key
##      YYYY-mm-DDTHH:MM:SS.6S(+|-)HH:MM; YYYY-mm-DDTHH:MM:SS.6S(+|-)HH:MM
##      YYYY-mm-DDTHH:MM:SS.6S(+|-)HH:MM; YYYY-mm-DDTHH:MM:SS.6S(+|-)HH:MM
## #endmatrix:: key
## @end example
##
## The time is formatted as local time according extended ISO 8601 with six digits in microseconds
## and explicitly expressed time zone. Expected input time system is a number of seconds since the
## epoch, as in function time().
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
## infosettimematrix('time of start', [time(); time()+5; time()+10])
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2017
## Version: 6.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

