## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogetnumber (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogetnumber (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds line with content "key:: value" and returns 
## the value as number
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
## infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
## infogetnumber(infostr,'A')
## infogetnumber(infostr,'C')
## infogetnumber(infostr,'C', @{'section 1', 'subsection'@})
## infogetnumber(infostr,'C', @{'section 2'@})
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2013
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function number = infogetnumber(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogetnumber', varargin{:});
        if printusage
                print_usage()
        endif

        % get number %<<<2
        % get number as text:
        try
                s = infogettext(infostr, key, scell);
        catch
                [msg, msgid] = lasterr;
                id = findstr(msg, 'infogettext: key');
                if isempty(id)
                        % unknown error
                        error(msg)
                else
                        % infogettext error change to infogetnumber error:
                        msg = ['infogetnumber' msg(12:end)];
                        error(msg)
                endif
        end_try_catch
        number = str2num(s);
        if isempty(number)
                error(['infogetnumber: key `' key '` does not contain numeric data'])
        endif
endfunction

function [printusage, infostr, key, scell] = get_id_check_inputs(functionname, varargin) %<<<1
        % function identifies and partially checks inputs used in infoget* functions 
        % if printusage is true, infoget* function should call print_usage()
        %
        % input possibilities:
        %       infostr, key,
        %       infostr, key, scell

        printusage = false;
        infostr='';
        key='';
        scell={};

        % check inputs %<<<2
        if (nargin < 2+1 || nargin > 3+1)
                printusage = true;
                return;
        endif
        infostr = varargin{1};
        key = varargin{2};
        % set default value
        % (this is because Matlab cannot assign default value in function definition)
        if nargin < 3+1
                scell = {};
        else
                scell = varargin{3};
        endif

        % check values of inputs infostr, key, scell %<<<2
        if (~ischar(infostr) || ~ischar(key))
                error('infogetmatrix: infostr and key must be strings')
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
function key = regexpescape(key) %<<<1
        % Translate all special characters (e.g., '$', '.', '?', '[') in
        % key so that they are treated as literal characters when used
        % in the regexp and regexprep functions. The translation inserts
        % an escape character ('\') before each special character.
        % additional characters are translated, this fixes error in octave
        % function regexptranslate.

        key = regexptranslate('escape', key);
        % test if octave error present:
        if strcmp(regexptranslate('escape','*(['), '*([')
                % fix octave error not replacing other special meaning characters:
                key = regexprep(key, '\*', '\*');
                key = regexprep(key, '\(', '\(');
                key = regexprep(key, '\)', '\)');
        endif
endfunction

% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: 2\n#startsection:: section 1 \n  C:: 3\n  #startsection:: subsection\n    C:: 4\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: 5\n#endsection:: section 2\n');
%!assert(infogetnumber(infostr,'A') == 1)
%!assert(infogetnumber(infostr,'C') == 2)
%!assert(infogetnumber(infostr,'C', {'section 1'}) == 3)
%!assert(infogetnumber(infostr,'C', {'section 1', 'subsection'}) == 4)
%!assert(infogetnumber(infostr,'C', {'section 2'}) == 5)
%!error(infogetnumber('', ''));
%!error(infogetnumber('', infostr));
%!error(infogetnumber(infostr, ''));
%!error(infogetnumber(infostr, 'A', {'section 1'}));
