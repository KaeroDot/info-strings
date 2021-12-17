## Copyright (C) 2021 Stanislav Mašláň %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostruct} = infoparse (@var{infostr})
## @deftypefnx {Function File} @var{infostruct} = infoparse (@var{infostr}, @var{mode})
## Parse info string @var{infostr} to sections, matrices and items.
## If will go through the string and recursively parse the sections.
## Optionally it will also parse the matrices - it will extract the 
## string content of the matrix and stores it unchanged. Eventually
## it can also parse the scalar items (mode 'all').
## Note it only extracts the strings from the sections/matrices/items.
## It will not parse the content. It will just place it into lists.
## Mode of parsing @var{mode} is set to empty '', only sections will be parsed.
## If set to 'matrix', sections and matrices will be parsed. If 'all', sections,
## matrices and items will be parsed.
##
## Output @var{infostruct} is recursive structure with items:
##   all_parsed - true when mode 'all'
##   matrix_parsed - true when mode 'all' or 'matrix'
##   sec_count - number of subsections
##   sec_names - cell array of subsection names
##   sections - cell array of subsections - each cell is the same as this struct
##   scalar_count - number of scalar items in section
##   scalar_names - cell array of scalar item names
##   scalars - cell array of scalar item string contents
##   matrix_count - number of matrices in section
##   matrix_names - cell array of matrix names
##   matrix - cell array of matrix string contents
##   data - unparsed section content, note it is removed vhen mode is 'all'  
##  
## Author: Stanislav Mašláň <smaslanATcmi.cz>
## Created: 2018
## Version: 6.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: no
##   Checks inputs: yes
##   Contains tests: no
##   Contains demo: no
##   Optimized: yes
##  
