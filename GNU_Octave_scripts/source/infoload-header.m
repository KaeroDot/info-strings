## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infoload (@var{filename})
## @deftypefnx {Function File} @var{infostr} = infoload (@var{filename}, @var{autoextension})
## Opens file with info string `@var{filename}.info` and loads its content as text.
## Extension `.info` is added automatically if missing, this can be prevented by
## setting @var{autoextension} to zero.
##
## Example:
## @example
## infostr = infoload('test_file')
## infostr = infoload('test_file_with_other_extension.txt', 0)
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: no
##   Checks inputs: yes
##   Contains tests: no
##   Contains demo: no
##   Optimized: N/A

