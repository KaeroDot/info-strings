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

function infostr = infosettextmatrix(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettextmatrix', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~iscell(val))
                error('infosettextmatrix: val must be a cell of strings')
        endif
        if (~all(cellfun(@ischar, val)))
                error('infosettextmatrix: val must be a cell of strings')
        endif

        % make infostr %<<<2
        % convert matrix into text:
        % go line per line (thus semicolons and end of lines can be managed):
        matastext = '';
        % shall do indentation?
        indent = true;
        % escape semicolons:
        val = strrep(val, '"', '""');
        for i = 1:size(val,1)
                % for every row make a line:
                line = sprintf('"%s"; ', val{i,:});
                % disable indenting if line contains any of newline characters
                if ~isempty(strfind(line, char(10))) || ~isempty(strfind(line, char(13))) 
                        indent = false;
                endif
                % indentation inserts spaces into cells with newline characters!
                % join with previous lines, add indentation, add line without last semicolon and space, add end of line:
                matastext = [matastext line(1:end-2) NL];
        endfor
        % remove last end of line:
        matastext = matastext(1:end-length(NL));
        % add matrix to infostr:
        infostr = set_matrix('infosettextmatrix', infostr, key, matastext, scell, indent);
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

function infostr = set_matrix(functionname, infostr, key, matastext, scell, indent) %<<<1
        % make info line from matastext and key and put it into a proper section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - key for a new matrix
        % matastext - matrix as a string
        % scell - cell of strings with name of section and subsections
        % indent - boolean true if shall do indentation
        %
        % function suppose all inputs are ok!

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % number of spaces in indented section:
        if indent
                INDENT_LEN = 8;
        else
                INDENT_LEN = 0;
        endif

        % add newline to beginning and to end:
        matastext = [NL matastext NL];
        % indent lines:
        matastext = strrep(matastext, NL, [NL repmat(' ', 1, INDENT_LEN)]);
        % remove indentation from last line:
        matastext = matastext(1:end-INDENT_LEN);

        % put matrix values between keys:
        matastext = sprintf('#startmatrix:: %s%s#endmatrix:: %s', key, matastext, key);

        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                endif
                infostr = [before matastext];
        else
                infostr = set_section('infosetnumber', infostr, matastext, scell, indent);
        endif
endfunction

function infostr = set_section(functionname, infostr, content, scell, indent) %<<<1
        % put content into a proper section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % content - what to put into the section
        % scell - cell of strings with name of section and subsections
        % indent - boolean true if shall do indentation
        %
        % function suppose all inputs are ok!

        % input is parsed?
        in_is_parsed = isstruct(infostr) && isfield(infostr,'this_is_infostring');
        % new stuff is parsed? 
        new_is_parsed = isstruct(content) && isfield(content,'this_is_infostring');
        
        % check parameter compatibility
        if new_is_parsed ~= in_is_parsed
                error(sprintf('%s: input inf-string and new content must be of the same type',functionname));
        endif
        
        if in_is_parsed
                % --- PARSED INFO-STRING MODE ---
                
                % ###todo: implement recorusive insertion, so far it can just put stuff to global (not to subsections)
                
                if ~isempty(scell)
                        error(sprintf('%s: in parsed mode it can so far only insert data to global, not to subsections, sorry, too lazy...',functionname));                
                endif
                
                try
                        sections = infostr.sections;
                        sec_names = infostr.sec_names;
                catch
                        sections = {};
                        sec_names = {};
                end
                
                try
                        scalars = infostr.scalars;
                        scalar_names = infostr.scalar_names;
                catch
                        scalars = {};
                        scalar_names = {};
                end
                
                try
                        matrix = infostr.matrix;
                        matrix_names = infostr.matrix_names;
                catch
                        matrix = {};
                        matrix_names = {};
                end
                
                %    all_parsed - true when mode 'all'
                %    matrix_parsed - true when mode 'all' or 'matrix'
                %    data - unparsed section content, note it is removed vhen mode is 'all'
                
                % merge info-strings
                infostr.sections = {sections{:} content.sections{:}};  
                infostr.sec_names = {sec_names{:} content.sec_names{:}};
                infostr.sec_count = numel(infostr.sections);                
                infostr.scalars = {scalars{:} content.scalars{:}};  
                infostr.scalar_names = {scalar_names{:} content.scalar_names{:}};
                infostr.scalar_count = numel(infostr.scalars);                
                infostr.matrix = {matrix{:} content.matrix{:}};  
                infostr.matrix_names = {matrix_names{:} content.matrix_names{:}};
                infostr.matrix_count = numel(infostr.matrix);
                infostr.all_parsed = 1;
                infostr.matrix_parsed = 1;
                infostr.this_is_infostring = 1;
                
        else
                % --- RAW INFO-STRING MODE ---
                
                % Constant with OS dependent new line character:
                % (This is because of Matlab cannot translate special characters
                % in strings. GNU Octave distinguish '' and "")
                NL = sprintf('\n');

                % number of spaces in indented section:
                if indent
                        INDENT_LEN = 8;
                else
                        INDENT_LEN = 0;
                endif

                % make infostr %<<<2
                if (isempty(infostr) && length(scell) == 1)
                        % just simply generate info string
                        % add newlines to a content, indent lines by INDENT_LEN, remove indentation from last line:
                        spaces = repmat(' ', 1, INDENT_LEN);
                        content = [deblank(strrep([NL strtrim(content) NL], NL, [NL spaces])) NL];
                        % create infostr:
                        infostr = [infostr sprintf('#startsection:: %s%s#endsection:: %s', scell{end}, content, scell{end})];
                else
                        % make recursive preparation of info string
                        % find out how many sections from scell already exists in infostr:
                        position = length(infostr);
                        for i = 1:length(scell)
                                % through deeper and deeper section path
                                try
                                        %XXX try catch is not good here! in the case of
                                        %other error this will fail also! should be changed
                                        % check section path scell(1:i):
                                        [tmp, position] = get_section(functionname, infostr, scell(1:i));
                                catch
                                        % error happened -> section path scell(1:i) do not exist:
                                        i = i - 1;
                                        break
                                end_try_catch
                        endfor
                        % split info string according found position:
                        infostrA = infostr(1:position);
                        infostrB = infostr(position+1:end);
                        % remove leading spaces and keep newline in part A:
                        if isempty(infostrA)
                                before = '';
                        else
                                before = [deblank(infostrA) NL];
                        endif
                        % remove leading new lines if present in part B:
                        infostrB = regexprep(infostrB, '^\n', '');
                        % create sections if needed:
                        if i < length(scell) - 1;
                                % make recursion to generate new sections:
                                toinsert = set_section(functionname, '', content, scell(i+2:end), indent);
                        else
                                % else just use content with proper indentation:
                                spaces = repmat(' ', 1, i.*INDENT_LEN);
                                toinsert = [deblank(strrep([NL strtrim(content) NL], NL, [NL spaces])) NL];
                        endif
                        % create main section if needed
                        if i < length(scell);
                                % simply generate section
                                % (here could be a line with sprintf, or subfunction can be used, but recursion 
                                % seems to be the simplest solution
                                toinsert = set_section(functionname, '', toinsert, scell(i+1), indent);
                                spaces = repmat(' ', 1, i.*INDENT_LEN);
                                toinsert = [deblank(strrep([NL strtrim(toinsert) NL], NL, [NL spaces])) NL];
                        endif
                        toinsert = regexprep(toinsert, '^\n', '');
                        % create new infostr by inserting new part at proper place of old infostr:
                        infostr = deblank([before deblank(toinsert) NL infostrB]);
                endif
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
%!shared ismat, ismatsec
%! ismat = sprintf('#startmatrix:: mat\n        "a"; "b""b"; "c"\n        "d"; "e"; "f"\n#endmatrix:: mat');
%! ismatsec = sprintf('#startsection:: skey\n        #startmatrix:: mat\n                "a"; "b""b"; "c"\n                "d"; "e"; "f"\n        #endmatrix:: mat\n#endsection:: skey');
%!assert(strcmp(infosettextmatrix( 'mat', {'a', 'b"b', 'c'; 'd', 'e', 'f'}                ), ismat));
%!assert(strcmp(infosettextmatrix( 'mat', {'a', 'b"b', 'c'; 'd', 'e', 'f'}, {'skey'}      ), ismatsec));
%!assert(strcmp(infosettextmatrix( 'testtext', 'mat', {'a', 'b"b', 'c'; 'd', 'e', 'f'}, {'skey'}     ), ['testtext' sprintf('\n') ismatsec]));
%!error(infosettextmatrix('a'))
%!error(infosettextmatrix({'a'}, 'a'))
%!error(infosettextmatrix('a', 'b'))
%!error(infosettextmatrix('a', {'a'}, 'd'))
%!error(infosettextmatrix('a', {'a'}, {5}))
%!error(infosettextmatrix('a', 'b', {'a'}, 'd'))
%!error(infosettextmatrix('a', 'b', {'a'}, {5}))
