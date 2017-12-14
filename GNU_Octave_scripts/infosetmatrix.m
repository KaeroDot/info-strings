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

function infostr = infosetmatrix(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % constant - number of spaces in indented section:
        INDENT_LEN = 8;

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosetmatrix', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~ismatrix(val) || ~isnumeric(val))
                error('infosetmatrix: val must be a numeric matrix')
        endif

        % make infostr %<<<2
        % make template without semicolon after last number:
        template = repmat('%.20G; ', 1, size(val, 2));
        template = [template(1:end-2) NL];
        % format values
        newlines = sprintf(template, val');

        % add newline to beginning:
        newlines = [NL newlines];
        % indent lines:
        newlines = strrep(newlines, NL, [NL repmat(' ', 1, INDENT_LEN)]);
        % remove indentation from last line:
        newlines = newlines(1:end-INDENT_LEN);

        % put matrix values between keys:
        newlines = sprintf('#startmatrix:: %s%s#endmatrix:: %s', key, newlines, key);

        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                endif
                infostr = [before newlines];
        else
                infostr = infosetsection(infostr, newlines, scell);
        endif
endfunction

function [printusage, infostr, key, val, scell] = set_id_check_inputs(functionname, varargin) %<<<1
        % function identifies and partially checks inputs used in infoset* functions 
        % if printusage is true, infoset* function should call print_usage()
        %
        % input possibilities:
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        printusage = false;
        infostr='';
        key='';
        val='';
        scell={};

        % check inputs %<<<2
        % (one input is functionname - in infoset* functions is not)
        if (nargin < 2+1 || nargin > 4+1)
                printusage = true;
                return
        endif
        % identify inputs
        if nargin == 4+1
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        elseif nargin == 2+1;
                infostr = '';
                key = varargin{1};
                val = varargin{2};
                scell = {};
        else
                if iscell(varargin{3})
                        infostr = '';
                        key = varargin{1};
                        val = varargin{2};
                        scell = varargin{3};
                else
                        infostr = varargin{1};
                        key = varargin{2};
                        val = varargin{3};
                        scell = {};
                endif
        endif

        % check values of inputs infostr, key, scell %<<<2
        % input val have to be checked by infoset* function!
        if (~ischar(infostr) || ~ischar(key))
                error([functionname ': infostr and key must be strings'])
        endif
        if isempty(key)
                error([functionname ': key is empty string'])
        endif
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        endif
        if (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        endif
endfunction
% --------------------------- tests: %<<<1
%!shared ismat, ismatsec
%! ismat = sprintf('#startmatrix:: mat\n        1; 2; 3\n        4; 5; 6\n#endmatrix:: mat');
%! ismatsec = sprintf('#startsection:: skey\n        #startmatrix:: mat\n                1; 2; 3\n                4; 5; 6\n        #endmatrix:: mat\n#endsection:: skey');
%!assert(strcmp(infosetmatrix( 'mat', [1:3; 4:6]                          ), ismat));
%!assert(strcmp(infosetmatrix( 'mat', [1:3; 4:6], {'skey'}                ), ismatsec));
%!assert(strcmp(infosetmatrix( 'testtext', 'mat', [1:3; 4:6], {'skey'}     ), ['testtext' sprintf('\n') ismatsec]));
%!error(infosetmatrix('a'))
%!error(infosetmatrix(5, 'a'))
%!error(infosetmatrix('a', 'b'))
%!error(infosetmatrix('a', 5, 'd'))
%!error(infosetmatrix('a', 5, {5}))
%!error(infosetmatrix('a', 'b', 5, 'd'))
%!error(infosetmatrix('a', 'b', 5, {5}))
