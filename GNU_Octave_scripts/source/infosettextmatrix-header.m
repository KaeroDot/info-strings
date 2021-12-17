## Copyright (C) 2021 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosettextmatrix (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettextmatrix (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosettextmatrix (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettextmatrix (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with a text matrix formatted in following format:
## @example
## #startmatrix:: key
##      "val(1,1)"; "val(1,2)"; "val(1,3)";
##      "val(2,1)"; "val(2,2)"; "val(2,3)";
## #endmatrix:: key
##
## @end example
## If @var{scell} is set, the section is put into subsections according @var{scell}. 
## If @var{scell} is empty or contains empty value ([] or ''), it is considered as @var{scell} 
## is not set.
##
## If @var{infostr} is set, the section is put into existing @var{infostr} 
## sections, or sections are generated if needed and properly appended/inserted
## into @var{infostr}.
##
## Example:
## @example
## infosettextmatrix('colours', @{'black'; 'blue'@})
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

