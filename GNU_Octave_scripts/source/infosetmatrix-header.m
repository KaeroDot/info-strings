## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosetmatrix (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetmatrix (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosetmatrix (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetmatrix (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with a numeric matrix formatted in following format:
## @var{val} in following format:
## @example
## #startmatrix:: key
##      val(1,1); val(1,2); val(1,3);
##      val(2,1); val(2,2); val(2,3);
## #endmatrix:: key
##
## @end example
## If @var{scell} is set, the section is put into subsections according @var{scell}. 
##
## If @var{infostr} is set, the section is put into existing @var{infostr} 
## sections, or sections are generated if needed and properly appended/inserted
## into @var{infostr}.
##
## Example:
## @example
## infosetmatrix('small matrix', [1:3; 4:6])
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

