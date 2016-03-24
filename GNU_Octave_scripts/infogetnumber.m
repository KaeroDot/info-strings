## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogetnumber (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogetnumber (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds line with content "key:: value" and returns 
## the value as number
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
## If @var{scell} is empty or contains empty value ([] or ''), it is considered as @var{scell} 
## is not set.
##
## Example:
## @example
## infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \n#startmatrix:: time matrix\n  2013-12-11T22:59:30.123456\n  2013-12-11T22:59:35.123456\n#endmatrix:: time matrix\nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
## infogetnumber(infostr,'A')
## infogetnumber(infostr,'C')
## infogetnumber(infostr,'C', @{'section 1', 'subsection'@})
## infogetnumber(infostr,'C', @{'section 2'@})
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2013
## Version: 4.1
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
        s = get_key('infogetnumber', infostr, key, scell);
        % convert text to number:
        number = str2double(s);
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
                error([functionname ': infostr and key must be strings'])
        endif
        if isempty(key)
                error([functionname ': key is empty string'])
        endif
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        endif
        if length(scell) == 1 && isempty(scell{1})
                % atomatically generated values of cells are often [], not '', but still the cell is
                % empty, e.g.: 
                %       clear scell; scell{2} = 'sectionB'
                % than scell{1} is [].
                % so to remove user need to bother with this, if the scell contains single empty
                % value, it is automatically replaced by empty string.
                scell = {};
        endif
        if (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        endif
endfunction

function [section, endposition] = get_section(functionname, infostr, scell) %<<<1
        % finds content of a section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        section = '';
        endposition = 0;
        if isempty(scell)
                % scell is empty thus current infostr is required:
                section = infostr;
        else
                while (~isempty(infostr))
                        % search sections one by one from start of infostr to end
                        [S, E, TE, M, T, NM] = regexpi(infostr, ['#startsection\s*::\s*(.*)\s*\n(.*)\n\s*#endsection\s*::\s*\1'], 'once');
                        if isempty(T)
                                % no section found
                                section = '';
                                break
                        else
                                % some section found
                                if strcmp(strtrim(T{1}), scell{1})
                                        % wanted section found
                                        section = strtrim(T{2});
                                        endposition = endposition + TE(end,end);
                                        break
                                else
                                        % found section is not the one wanted
                                        if E < 2
                                                % danger of infinite loop! this should never happen
                                                error([functionname ': infinite loop happened!'])
                                        endif
                                        % remove previous parts of infostr to start looking for 
                                        % wanted section after the end of found section:
                                        infostr = infostr(E+1:end);
                                        % calculate correct position that will be returned to user:
                                        endposition = endposition + E;
                                endif
                        endif
                endwhile
                % if nothing found:
                if isempty(section)
                        error([functionname ': section `' scell{1} '` not found'])
                endif
                % some result was obtained. if subsections are required, do recursion:
                if length(scell) > 1
                        % recursively call for subsections:
                        tmplength = length(section);
                        [section, tmppos] = get_section(functionname, section, scell(2:end));
                        endposition = endposition - (tmplength - tmppos);
                endif
        endif
endfunction

function [infostr] = rem_subsections(functionname, infostr) %<<<1
        % remove all other sections in infostr
        % used to prevent finding key or matrix inside of some section
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        %
        % function suppose all inputs are ok!

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % remove unwanted sections:
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
                                error([functionname ': infinite loop happened!'])
                        endif
                endif
        endwhile
endfunction

function [val] = get_key(functionname, infostr, key, scell) %<<<1
        % returns value of key as text from infostr in section/subsections according scell
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - name of key for which val is searched
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        val = '';
        % get section:
        [infostr] = get_section(functionname, infostr, scell);
        % remove unwanted subsections:
        [infostr] = rem_subsections(functionname, infostr);

        % get key:
        % regexp for rest of line after a key:
        rol = '\s*::([^\n]*)';
        %remove leading spaces of key and escape characters:
        key = regexpescape(strtrim(key));
        % find line with the key:
        % (?m) is regexp flag: ^ and $ match start and end of line
        [S, E, TE, M, T, NM] = regexpi (infostr,['(?m)^\s*' key rol]);
        % return key if found:
        if isempty(T)
                error([functionname ': key `' key '` not found'])
        else
                if isscalar(T)
                        val = strtrim(T{1}{1});
                else
                        error([functionname ': key `' key '` found on multiple places'])
                endif
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
