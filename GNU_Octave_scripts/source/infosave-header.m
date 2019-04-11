## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} infosave (@var{infostr}, @var{filename})
## @deftypefnx {Function File}  infosave (@var{infostr}, @var{filename}, @var{autoextension})
## @deftypefnx {Function File}  infosave (@var{infostr}, @var{filename}, @var{autoextension}, @var{overwrite})
## Save info string @var{infostr} into file `@var{filename}.info` as text. Extension `.info`
## is added automatically if missing, this can be prevented by setting @var{autoextension}
## to zero. If @var{overwrite} is set, existing file is overwritten.
##
## Example:
## @example
## infosave('key:: val', 'test_file')
## infosave('key:: val', 'test_file_with_other_extension.txt', 0)
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 4.1
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: no
##   Checks inputs: yes
##   Contains tests: no
##   Contains demo: no
##   Optimized: N/A

