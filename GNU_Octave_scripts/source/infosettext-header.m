## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosettext (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettext (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosettext (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettext (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with key @var{key} and text @var{val} in following format:
## @example
## key:: val
##
## @end example
## If @var{scell} is set, the key/value is enclosed by section(s) according @var{scell}.
##
## If @var{infostr} is set, the key/value is put into existing @var{infostr} 
## sections, or sections are generated if needed and properly appended/inserted 
## into @var{infostr}.
##
## Example:
## @example
## infosettext('key', 'value')
## infostr = infosettext('key', 'value', @{'section key', 'subsection key'@})
## infosettext(infostr, 'other key', 'other value', @{'section key', 'subsection key'@})
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

