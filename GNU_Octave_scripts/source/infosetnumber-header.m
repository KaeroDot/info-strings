## Copyright (C) 2021 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosetnumber (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetnumber (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosetnumber (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetnumber (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with key @var{key} and number @var{val} in following format:
## @example
## key:: val
##
## @end example
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
## infosetnumber('key', 1)
## infostr = infosetnumber('key', 1, @{'section key', 'subsection key'@})
## infosetnumber(infostr, 'other key', 5, @{'section key', 'subsection key'@})
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 6.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

