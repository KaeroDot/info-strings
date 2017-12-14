## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettext (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettext (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds line with content "key:: value" and returns 
## the value as text.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
## infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
## infogettext(infostr,'A')
## infogettext(infostr,'B([V?*.])')
## infogettext(infostr,'C')
## infogettext(infostr,'C', @{'section 1', 'subsection'@})
## infogettext(infostr,'C', @{'section 2'@})
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

function text = infogettext(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettext', varargin{:});
        if printusage
                print_usage()
        endif

        % get text %<<<2
        % find proper section(s):
        for i = 1:length(scell)
                infostr = infogetsection(infostr, scell{i});
        endfor
        % remove all other sections in infostr, to prevent finding
        % key inside of some section
        while (~isempty(infostr))
                % search sections one by one from start of infostr to end
                [S, E, TE, M, T, NM] = regexpi(infostr, ['#startsection\s*::\s*(.*)\s*\n(.*)\n\s*#endsection\s*::\s*\1'], 'once');
                if isempty(T)
                        % no section found, quit:
                        break
                else
                        % some section found, remove it from infostr:
                        infostr = [deblank(infostr(1:S-1)) NL fliplr(deblank(fliplr(infostr(E+1:end))))];
                        if S-1 >= E+1
                                % danger of infinite loop! this should never happen
                                error('infogettext: infinite loop happened!')
                        endif
                endif
        endwhile
        % find key and get value
        % regexp for rest of line after a key:
        rol = '\s*::([^\n]*)';
        %remove leading spaces of key and escape characters:
        key = regexpescape(strtrim(key));
        % find line with the key:
        % (?m) is regexp flag: ^ and $ match start and end of line
        [S, E, TE, M, T, NM] = regexpi (infostr,['(?m)^\s*' key rol]);
        % return key if found:
        if isempty(T)
                error(['infogettext: key `' key '` not found'])
        else
                if isscalar(T)
                        text = strtrim(T{1}{1});
                else
                        error(['infogettext: key `' key '` found on multiple places'])
                endif
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
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(strcmp(infogettext(infostr,'A'),'1'))
%!assert(strcmp(infogettext(infostr,'B([V?*.])'),'!$^&*()[];::,.'));
%!assert(strcmp(infogettext(infostr,'C'),'c without section'))
%!assert(strcmp(infogettext(infostr,'C', {'section 1'}),'c in section 1'))
%!assert(strcmp(infogettext(infostr,'C', {'section 1', 'subsection'}),'c in subsection'))
%!assert(strcmp(infogettext(infostr,'C', {'section 2'}),'c in section 2'))
%!error(infogettext('', ''));
%!error(infogettext('', infostr));
%!error(infogettext(infostr, ''));
%!error(infogettext(infostr, 'A', {'section 1'}));



% NOVY TESTOVACI INFOSTR:
% 
% infostr = "A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n"


% A:: 1
% some note
% B([V?*.])::    !$^&*()[];::,.
% #startmatrix:: simple matrix 
% 1;  2; 3; 
% 4;5;         6;  
% #endmatrix:: simple matrix 
% C:: c without section
% #startsection:: section 1 
  % C:: c in section 1 
  % #startsection:: subsection
    % C:: c in subsection
  % #endsection:: subsection
% #endsection:: section 1
% #startsection:: section 2
  % C:: c in section 2
% #endsection:: section 2
