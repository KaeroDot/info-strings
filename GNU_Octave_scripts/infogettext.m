## Copyright (C) 2021 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettext (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettext (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds line with content "key:: value" and returns 
## the value as text.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
## If @var{scell} is empty or contains empty value ([] or ''), it is considered as @var{scell} 
## is not set.
##
## Example:
## @example
## infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \n#startmatrix:: time matrix\n  2013-12-11T22:59:30.123456+00:00\n  2013-12-11T22:59:35.123456+00:00\n#endmatrix:: time matrix\nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
## infogettext(infostr,'A')
## infogettext(infostr,'B([V?*.])')
## infogettext(infostr,'C')
## infogettext(infostr,'C', @{'section 1', 'subsection'@})
## infogettext(infostr,'C', @{'section 2'@})
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2013
## Version: 6.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function text = infogettext(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettext', varargin{:});
        if printusage
                print_usage()
        endif

        % get text %<<<2
        text = get_key('infogettext', infostr, key, scell);
endfunction

function [printusage, infostr, key, scell, is_parsed] = get_id_check_inputs(functionname, varargin) %<<<1
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

        % input is parsed info string? 
        is_parsed = isstruct(infostr) && isfield(infostr,'this_is_infostring');

        % check values of inputs infostr, key, scell %<<<2
        if ~ischar(infostr) && ~is_parsed
                error([functionname ': infostr must be either string or structure generated by infoparse()'])
        endif
        if ~ischar(key) || isempty(key)
                error([functionname ': key must be non-empty string'])
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
        elseif (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        endif
endfunction

function [section, endposition] = get_section(functionname, infostr, scell) %<<<1
        % finds content of a section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data (raw string or parsed struct)
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % recoursive section search:
                for s = 1:numel(scell)
                
                        % look for subsection:
                        sid = find(strcmp(infostr.sec_names,scell{s}),1);
                        if isempty(sid)
                                error(sprintf('%s: subsection ''%s'' not found',functionname,scell{s}));
                        endif
                        
                        % go deeper:
                        infostr = infostr.sections{sid};
                endfor
                
                % assing result
                section = infostr;

                endposition = 0; % matlab default
                
        else
                % --- RAW INFO-STRING ---                
                section = '';
                sectionfound = 0;
                endposition = 0;
                if isempty(scell)
                        % scell is empty thus current infostr is required:
                        section = infostr;
                        sectionfound = 1;
                else
                        while (~isempty(infostr))
                                % Search sections one by one from start of infostr to end.
                                % This searching of sections one by one is 2-3 times faster than a
                                % regular expression matching all sections.
                                [S, E, TE, M, T, NM] = regexpi(infostr, make_regexp('', 'anysection'), 'once');
                                if isempty(T)
                                        % no section found
                                        section = '';
                                        break
                                else
                                        % some section found
                                        if strcmp(strtrim(T{1}), scell{1})
                                                % wanted section found
                                                if length(T) > 1
                                                        section = strtrim(T{2});
                                                else
                                                        % section was found, but content was empty
                                                        section = '';
                                                endif
                                                sectionfound = 1;
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
                        if not(sectionfound)
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
        
        if ~isstruct(infostr)
                % --- only in raw text mode, ignore for parsed infostring ---
                NL = sprintf('\n');

                % remove unwanted sections:
                while (~isempty(infostr))
                        % search sections one by one from start of infostr to end
                        [S, E, TE, M, T, NM] = regexpi(infostr, make_regexp('', 'anysection'), 'once');
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
        endif
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

        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % look for scalar item:
                sid = find(strcmp(infostr.scalar_names,key));
                if isempty(sid)
                        error(sprintf('%s: key ''%s'' not found',functionname,key));
                endif
                
                if numel(sid) > 1
                        error(sprintf('%s: key ''%s'' found multiple times',functionname,key));
                endif
                
                % return item:
                val = infostr.scalars{sid};

        else
                % --- RAW INFO-STRING ---                

                % find key:
                [S, E, TE, M, T, NM] = regexpi (infostr, make_regexp(key, 'linekey'), 'once');
                % return key if found:
                if isempty(T)
                        error([functionname ': key `' key '` not found'])
                else
                        if isscalar(T)
                                val = strtrim(T{1});
                        else
                                error([functionname ': key `' key '` found on multiple places'])
                        endif
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

function expr = make_regexp(key, type)
        % returns proper regular expression for line key, matrix and section.
        % this function is mainly to have all regular expressions at one place to increase
        % readability of the whole library.

        % GNU Octave and LabVIEW use PCRE (Pearl Compatible Regular Expressions), however Matlab
        % seems to have it's own regular expression flavor (unfortunately). The
        % goal of this script it to generate regexps that works in all target
        % softwares.

        % Matlab issues:
        % 1,
        % https://www.mathworks.com/help/matlab/ref/regexp.html#btn_p45_sep_shared-expression
                % WARNING!
                % If an expression has nested parentheses, MATLAB captures tokens that correspond
                % to the outermost set of parentheses. For example, given the search pattern
                % '(and(y|rew))', MATLAB creates a token for 'andrew' but not for 'y' or 'rew'.
        % so for Octave one can keep proper non matching group (?:), but not for Matlab.
        % 2,
        % \h is not implemented in Matlab, \h has to be replaced by \s. But \s matches also newlines (contrary to \h).
        % 3,
        % \R (end of line for both linux and windows) does not work in Matlab.

        % Notes on regexp details and tricks
        % 1,
        % (?m) is regexp flag multi line. Causes ^ and $ to match the begin/end
        % of each line (not only begin/end of string).
        % But $ will match only \n (LF), not \r\f (CRLF).
        % \R can match OS independent new line, but is not available in Matlab.
        % Therefore to always match new line, one has to use use OS independent
        % new line (?:\r?\n).  But this would not match start/end of string,
        % therefore SOLF/EOLF with switched off flag like this: (?-m), see lower.

        % (?s) is regexp flag single line. Dot (.) matches also newline characters.
                    % But CR will be matched in (.*) and part of captured group if CRLF
                    % line ending are used.
                    % (?-s) Dot (.) do NOT matches newline characters, just takes everything.

                    % % Parts to build regexps
                    % % FL - flags
                    % % flags used in regexps (reasoning see higher).
                    % FL = '(?-m)(?s)';
                    % % SP - space
                    % % zero or multiple space or tab characters:
                    % SP = '[\t ]*';
                    % % DL - infostrings delimiter:
                    % DL = '::';
                    % % SOL - Start Of Line
                    % % OS independent start of line is just simply LF, because CRLF in windows is catched in this way also
                    % SOL = '\n';
                    % % SOL - Start Of Line or String
                    % % OS independent start of line or string
                    % SOLS = '(?:\n|^)';
                    % % EOL - End Of Line
                    % % OS independent end of line (CRLF or LF)
                    % EOL = '(?:\r?\n)';
                    % % EOLS - End Of Line or String
                    % % OS independent end of line or end of string
                    % EOLS = '(?:\r?\n|$)';
                    % % % ATEOLS
                    % % % Anything Till End of Line or String
                    % % % OS independent anything till the end of line/string with capturing group
                    % % ATEOLS = '(.*)'

        % remove leading spaces of key and escape characters:
        % (e.g. if key contains '(', it will be changed to '\(' etc.
        key = regexpescape(strtrim(key));


        if strcmpi(type, 'linekey')
                            % possible future:
                            % expr = [FL SOLS SP key SP DL '(.*?)' EOLS];
                if isOctave
                        % SOL SP key SP :: content without EOL
                        % (?-s) is regexp flag causing that . do not match end of line
                        expr = ['(?m-s)^\h*' key '\h*::(.*)'];
                        % results: Token 1: content of key
                else
                        % \h has to be replaced by \s. But \s matches also newlines contrary to \h
                        expr = ['(?m-s)^\s*' key '\s*::(.*)'];
                endif
        elseif strcmpi(type, 'matrix')
                            % possible future:
                            % expr = [FL SOLS SP '#startmatrix' SP DL SP key SP EOL '(.*?)' SP '#endmatrix' SP DL SP key SP EOLS];
                if isOctave
                        % SOL SP startmatrix SP :: SP key SP ( NL content NL OR NL ) SP endmatrix SP :: SP key SP EOL
                        % This is NOT greedy, i.e. finds first occurance of endmatrix.
                        expr = ['(?m)^\h*#startmatrix\h*::\h*' key '\h*(?:\n(.*?)\n|\n)^\h*#endmatrix\h*::\h*' key '\h*$'];
                        % results: Token 1: content of section OR token does not exist
                else
                        % \h has to be replaced by \s. But \s matches also newlines contrary to \h
                        expr = ['(?m)^\s*#startmatrix\s*::\s*' key '\s*(\n(.*?)\n|\n)^\s*#endmatrix\s*::\s*' key '\s*$'];
                endif
        elseif strcmpi(type, 'section')
                            % possible future:
                            % expr = [FL SOLS SP '#startsection' SP DL SP key SP EOL '(.*?)' SP '#endsection' SP DL SP key SP EOLS];
                if isOctave
                        % SOL SP startsection SP :: SP key SP ( NL content NL OR NL ) SP endsection SP :: SP key SP EOL
                        expr = ['(?ms)^\h*#startsection\h*::\h*' key '\h*(?:\n(.*)\n|\n)^\h*#endsection\h*::\h*' key '\h*$'];
                        % results: Token 1: content of section OR token does not exist
                else
                        % \h has to be replaced by \s. But \s matches also newlines contrary to \h
                        expr = ['(?ms)^\s*#startsection\s*::\s*' key '\s*(\n(.*)\n|\n)^\s*#endsection\s*::\s*' key '\s*$'];
                endif
        elseif strcmpi(type, 'anysection')
                            % possible future:
                            % expr = [FL SOLS SP '#startsection' SP DL SP '(.*?)' SP EOL '(.*?)' SP '#endsection' SP DL SP '\1' SP EOLS];
                if isOctave
                        % SOL SP startsection SP :: SP key SP ( NL content NL OR NL ) SP endsection SP :: SP key SP EOL
                        % This is greedy, i.e. finds last occurance of endsection.
                        % For match of section key, instead of .*, that means any even line break
                        % (because of flag (?s), there is [^\n], that means any except line break,
                        % because section key cannot be across line breaks.
                        expr = ['(?ms)^\h*#startsection\h*::\h*([^\n]*)\h*(?:\n(.*)\n|\n)^\h*#endsection\h*::\h*\1\h*$'];
                        % results: Token 1: key
                        % results: Token 2: content of section OR token does not exist
                else
                        % \h has to be replaced by \s. But \s matches also newlines contrary to \h
                        expr = ['(?ms)^\s*#startsection\s*::\s*([^\n]*)\s*(\n(.*)\n|\n)^\s*#endsection\s*::\s*\1\s*$'];
                endif
        else
                error('unknown regular expression type')
        endif
endfunction

function retval = isOctave
% checks if GNU Octave or Matlab
% according https://www.gnu.org/software/octave/doc/v4.0.1/How-to-distinguish-between-Octave-and-Matlab_003f.html

  persistent cacheval;  % speeds up repeated calls

  if isempty (cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
  end

  retval = cacheval;
end

% --------------------------- tests: %<<<1
%!shared infostr
%!assert(strcmp(infogettext("A::1\nB::2",'A'),'1'))
%!assert(strcmp(infogettext("A::1\nB::2",'B'),'2'))
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
