## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosetsection (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetsection (@var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosetsection (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetsection (@var{infostr}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosetsection (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with a section made from @var{key} and string
## @var{val} in following format:
## @example
## #startsection:: key
##      val
## #endsection:: key
##
## @end example
## If @var{scell} is set, the section is put into subsections according @var{scell}. 
## If @var{scell} is empty or contains empty value ([] or ''), it is considered as @var{scell} 
## is not set.
## If @var{key} is not specified, last element of @var{scell} is considered as @var{key}.
##
## If @var{infostr} is set, the section is put into existing @var{infostr} 
## sections, or sections are generated if needed.
##
## Example:
## @example
## infosetsection('section key', sprintf('multi\nline\nvalue'))
## infostr = infosetsection('value', @{'section key', 'subsection key'@})
## infosetsection(infostr, 'subsubsection key', 'other value', @{'section key', 'subsection key'@})
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

