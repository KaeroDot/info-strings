function tmatrix = infogettimematrix(varargin)%<<<1
% -- Function File: TEXT = infogettimematrix (INFOSTR, KEY)
% -- Function File: TEXT = infogettimematrix (INFOSTR, KEY, SCELL)
%     Parse info string INFOSTR, finds lines after line '#startmatrix::
%     key' and before '#endmatrix:: key', parse numbers from lines and
%     returns the values as number of seconds since the epoch (as in
%     function time()).  Expected time format is extended ISO 8601:
%          YYYY-mm-DDTHH:MM:SS[.nS][Z|(+|-)HH:MM]
%     The number of digits in fraction of seconds is not limited, however
%     in GNU Octave the best precision is in microseonds, Matlab can cope
%     with nanoseconds.
%
%     If SCELL is set, the key is searched in section(s) defined by
%     string(s) in cell.  If SCELL is empty or contains empty value ([]
%     or "), it is considered as SCELL is not set.
%
%     Example:
%          infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \n#startmatrix:: time matrix\n  2013-12-11T22:59:30.123456+00:00\n  2013-12-11T22:59:35.123456+00:00\n#endmatrix:: time matrix\nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
%          infogettimematrix(infostr,'time matrix')

% Copyright (C) 2021 Martin Šíra %<<<1
%

% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2013
% Version: 6.0
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: yes
%   Contains demo: no
%   Optimized: no

        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettimematrix', varargin{:});
        if printusage
                print_usage()
        end

        % get matrix %<<<2
        infostr = get_matrix('infogetmatrix', infostr, key, scell);
        % parse csv:
        smat = csv2cell(infostr);

        % convert to time data:
        for i = 1:size(smat, 1)
                for j = 1:size(smat, 2)
                        s = strtrim(smat{i, j});
                        tmatrix(i, j) = iso2posix_time(strtrim(smat{i, j}));
                end
        end
end

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
        end
        infostr = varargin{1};
        key = varargin{2};
        % set default value
        % (this is because Matlab cannot assign default value in function definition)
        if nargin < 3+1
                scell = {};
        else
                scell = varargin{3};
        end

        % input is parsed info string? 
        is_parsed = isstruct(infostr) && isfield(infostr,'this_is_infostring');

        % check values of inputs infostr, key, scell %<<<2
        if ~ischar(infostr) && ~is_parsed
                error([functionname ': infostr must be either string or structure generated by infoparse()'])
        end
        if ~ischar(key) || isempty(key)
                error([functionname ': key must be non-empty string'])
        end
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        end
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
        end
end

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
                        end
                        
                        % go deeper:
                        infostr = infostr.sections{sid};
                end
                
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
                                                end
                                                sectionfound = 1;
                                                endposition = endposition + TE(end,end);
                                                break
                                        else
                                                % found section is not the one wanted
                                                if E < 2
                                                        % danger of infinite loop! this should never happen
                                                        error([functionname ': infinite loop happened!'])
                                                end
                                                % remove previous parts of infostr to start looking for 
                                                % wanted section after the end of found section:
                                                infostr = infostr(E+1:end);
                                                % calculate correct position that will be returned to user:
                                                endposition = endposition + E;
                                        end
                                end
                        end
                        % if nothing found:
                        if not(sectionfound)
                                error([functionname ': section `' scell{1} '` not found'])
                        end
                        % some result was obtained. if subsections are required, do recursion:
                        if length(scell) > 1
                                % recursively call for subsections:
                                tmplength = length(section);
                                [section, tmppos] = get_section(functionname, section, scell(2:end));
                                endposition = endposition - (tmplength - tmppos);
                        end
                end
        end
end

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
                                end
                        end
                end
        end
end

function [val] = get_matrix(functionname, infostr, key, scell) %<<<1
        % returns content of matrix as text from infostr in section/subsections according scell
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - name of matrix for which val is searched
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        val = '';
        % get section:
        [infostr] = get_section(functionname, infostr, scell);
        % remove unwanted subsections:
        [infostr] = rem_subsections(functionname, infostr);

        % get matrix:
        % prepare regexp:
        key = strtrim(key);
        
        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % search the matrix in the parsed list:
                mid = find(strcmp(infostr.matrix_names,key),1);
                if isempty(mid)
                        error([functionname ': matrix named `' key '` not found'])
                end
                % return its content:
                val = infostr.matrix{mid};                
        else
                % --- RAW INFO-STRING --- 
                % find matrix:
                [S, E, TE, M, T, NM] = regexpi (infostr, make_regexp(key, 'matrix'), 'once');
                if isempty(M)
                        error([functionname ': matrix named `' key '` not found'])
                end
                if isempty(T)
                        val = [];
                else
                        val=strtrim(T{1});
                end
        end
end

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
        end
end

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
        % But $ will match only \n (LF), not  (CRLF).
        % \R can match OS independent new line, but is not available in Matlab.
        % Therefore to always match new line, one has to use use OS independent
        % new line (?:?\n).  But this would not match start/end of string,
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
                    % EOL = '(?:?\n)';
                    % % EOLS - End Of Line or String
                    % % OS independent end of line or end of string
                    % EOLS = '(?:?\n|$)';
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
                end
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
                end
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
                end
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
                end
        else
                error('unknown regular expression type')
        end
end

function retval = isOctave
% checks if GNU Octave or Matlab
% according https://www.gnu.org/software/octave/doc/v4.0.1/How-to-distinguish-between-Octave-and-Matlab_003f.html

  persistent cacheval;  % speeds up repeated calls

  if isempty (cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
  end

  retval = cacheval;
end

function data = csv2cell(s) %<<<1
% Reads string with csv sheet according RFC4180 (with minor modifications, see last three
% properties) and returns cell of strings.
%
% Properties:
% - quoted fields are properly parsed,
% - escaped quotes in quoted fields are properly parsed,
% - newline characters are correctly understood in quoted fields,
% - spaces in quotes are preserved,
% - works for CR, LF, CRLF, LFCR newline markers,
% - if field is not quoted, leading and trailing spaces are intentionally removed,
% - sheet delimiter is ';',
% - if not same number of fields on every row, sheet is padded by empty strings as needed.

% Script first tries to find out if quotes are used. If not, fast method is used. If yes, slower
% method is used.

CELLSEP = ';';          % separator of fields
CELLSTR = '"';          % quoted fields character
LF = char(10);          % line feed
CR = char(13);          % carriage return

if length(strtrim(s)) == 0
        % empty matrix (just white-spaces)
        data = {};
elseif isempty(strfind(s, CELLSTR)) %<<<2
% no quotes, simple method will be used

        % methods converts all end of lines to LF, split by LF,
        % and two methods to parse lines

        % replace all CRLF to LF:
        s = strrep(s, [CR LF], LF);
        % replace all LFCR to LF:
        s = strrep(s, [LF CR], LF);
        % replace all CR to LF:
        s = strrep(s, CR, LF);
        % split by LF:
        s = strsplit(s, LF);
        % remove trailing empty lines which can happen in the case of last LF
        % (this would prevent using fast cellfun method)
        if length(s) > 1 && isempty(strtrim(s{end}))
                s = s(1:end-1);
        end
        % strsplit by separators on all lines:
        s = cellfun(@strsplit, s, repmat({CELLSEP}, size(s)), 'UniformOutput', false);
        try %<<<3
                % faster method - use vertcat, only possible if all lines have the same number of fields:
                data = vertcat(s{:});
        catch %<<<3
                % slower method - build sheet line by line.
                % if number of fields on some line is larger or smaller, padding by empty string
                % occur:
                data = {};
                for i = 1:length(s)
                        c = s{i};
                        if i > 1
                                if size(c,2) < size(data,2)
                                        % new line is too short, must be padded:
                                        c = [c repmat({''}, 1, size(data,2) - size(c,2))];
                                elseif size(c,2) > size(data,2)
                                        % new line is too long, whole matrix must be padded:
                                        data = [data, repmat({''}, size(c,2) - size(data,2), 1)];
                                end
                        end
                        % add new line of sheet:
                        data = [data; c];
                end
        end
        
        % get rid of start/end whites
        data = strtrim(data);
        
else %<<<2
        % quotes are inside of sheet, very slow method will be used
        % this method parse character by character

        Field = '';             % content of currently processed field
        FieldEnd = false;       % flag if field ended by ; or some newline
        LineEnd = false;        % flag if line ended
        inQuoteField = false;   % flag if now processing inside of quoted field
        wasQuotedField = false; % flag if current field is quoted
        curChar = '';           % currently processed character
        nextChar = '';          % character next after currently processed one
        curCol = 1;             % current collumn
        curRow = 1;             % current row
        i = 0;                  % loop index
        while i < length(s)
                i = i + 1;
                % get current character:
                curChar = s(i);
                % get next character
                if i < length(s)
                        nextChar = s(i+1);
                else
                        % if at end of string, just add line feed, no harm to do this:
                        nextChar = LF;
                        % and mark all ends:
                        FieldEnd = true;
                        LineEnd = true;
                end
                if inQuoteField %<<<3
                        % we are inside quotes of field
                        if curChar == CELLSTR
                                if nextChar == CELLSTR
                                        % found escaped quotes ("")
                                        i = i + 1;      % increment counter to skip next character, which is already part of escaped "
                                        Field = [Field CELLSTR];
                                else
                                        % going out of quotes
                                        inQuoteField = false;
                                        Field = [Field curChar];
                                end
                        else
                                Field = [Field curChar];
                        end
                else %<<<3
                        % we are not inside quotes of field
                        if curChar == CELLSTR
                                inQuoteField = true;
                                wasQuotedField = true;
                                Field = [Field curChar];
                                % endif
                        elseif curChar == CELLSEP
                                % found end of field
                                FieldEnd = true;
                        elseif curChar == CR
                                % found end of line (this also ends field)
                                FieldEnd = true;
                                LineEnd = true;
                                if nextChar == LF
                                        i = i + 1;      % increment counter to skip next character, which is already part of CRLF newline
                                end
                        elseif curChar == LF
                                % found end of line (this also ends field)
                                FieldEnd = true;
                                LineEnd = true;
                                if nextChar == CR
                                        i = i + 1;      % increment counter to skip next character, which is already part of LFCR newline
                                end
                        else
                                Field = [Field curChar];
                        end
                end
                if FieldEnd == true %<<<3
                        % add field to sheet:
                        Field = strtrim(Field);
                        if wasQuotedField
                                wasQuotedField = false;
                                % remove quotes if it is first and last character (spaces are already removed)
                                % if it is not so, the field is bad (not according RFC), something like:
                                % aaa; bb"bbb"bb; ccc
                                % and whole non modified field will be returned
                                if (strcmp(Field(1), '"') && strcmp(Field(end), '"'))
                                        Field = Field(2:end-1);
                                end
                        end
                        data(curCol, curRow) = {Field};
                        Field = '';
                        FieldEnd = false;
                        if LineEnd == true;
                                curRow = curRow + 1;
                                curCol = 1;
                                LineEnd = false;
                        else
                                curCol = curCol + 1;
                        end
                end
        end
        data = data';
end

end

function posixnumber = iso2posix_time(isostring)
        % converts ISO8601 time to posix time both for GNU Octave and Matlab
        % posix time is number of seconds since the epoch, the epoch is referenced to 00:00:00 CUT
        % (Coordinated Universal Time) 1 Jan 1970, for example, on Monday February 17, 1997 at 07:15:06 CUT,
        % the value returned by 'time' was 856163706.)
        % ISO 8601
        % YYYY-mm-DDTHH:MM:SS[.nS][Z|(+|-)HH:MM]
        % 2011-12-13T14:15:16
        % 2011-12-13T14:15:16.123456
        % 2011-12-13T14:15:16.123456Z
        % 2011-12-13T14:15:16.123456+01:00
        % 2011-12-13T14:15:16.123456-01:00
        % 2011-12-13T14:15:16-01:00

        errormsg = 'Incorrect format of time. Please use YYYY-mm-DDTHH:MM:SS[.6S][Z][(+|-)HH:MM]';

        isostring = strtrim(isostring);
        if length(isostring) < 19
                error(errormsg)
        end
        % get only YYYY-MM-DDTHH:MM:SS part of date, because both matlab and octave has some
        % problems reading lot of decimal places of seconds and timezone properly
        datetimepart = isostring(1:19);
        % base settings - local time, no fractions of seconds, offset irrelevant
        localt = 1;
        secfrac = [];
        offset = 0;
        if length(isostring) > 19
                rest = isostring(20:end);
                % find out if zulu time (GMT):
                idZ = strfind(rest, 'Z');
                if any(idZ)
                        % is zulu time
                        localt = 0;
                        % get fractions of seconds:
                        secfrac = sscanf(rest, '%f');
                else
                        % no zulu time
                        % needs to find if time zone offset is present
                        idOb = strfind(rest, '+');
                        idOa = strfind(rest, '-');
                        idO = min([idOa(:) idOb(:)]);
                        if isempty(idO)
                                % no time zone offset, so it is local time
                                secfrac = sscanf(rest, '%f');
                        else
                                % there is time zone offset
                                localt = 0;
                                if idO > 1
                                        % there is at least one character before time zone
                                        secfrac  = sscanf(rest(1:idO-1), '%f');
                                else
                                        secfrac = [];
                                end
                                offsetpart = rest(idO:end);
                                mult = 1;
                                if strcmp(offsetpart(1), '-')
                                        mult = -1;
                                end
                                offset = str2num(offsetpart(2:3))*3600;
                                % check if minutes are present in offset
                                if length(offsetpart) > 3
                                        offset = offset + str2num(offsetpart(5:6))*60;
                                end
                                offset = offset.*mult;
                        end
                end
        end
        if isempty(secfrac)
                % if sscanf scans nothing, it generates []
                secfrac = 0;
        end
        if isOctave
                % Octave version:
                % parse of time data:
                t = strptime(isostring, '%Y-%m-%dT%H:%M:%S');
                % mktime do not use .gmtoff and .zone in time structure from strptime, but use
                % environment settings. so it has to be changed temporarily:
                if localt
                        posixnumber = mktime(t);
                else
                        setenv ('TZ', 'UTC0');
                        posixnumber = mktime(t);
                        unsetenv('TZ');
                end
                % apply possible offset:
                % this line fixes that strptime was not created with proper time zone. convert back
                % to utc:
                posixnumber = posixnumber - offset;
        else
                % Matlab version:
                % this unfortunately requires Matlab 2014 and later
                if localt
                    tz = 'local';
                else
                    tz = '+00:00';
                end
                % As a time zone, matlab do not accept number. so just
                % create in zulu time zone and add offset later
                posixnumber = posixtime(datetime(isostring(1:19), 'TimeZone', tz, 'Format', 'yyyy-MM-dd''T''HH:mm:ss'));
                if ~localt
                    % apply possible offset:
                    % this line fixes that posixnumber was not created with
                    % proper time zone:
                    posixnumber = posixnumber - offset;
                end

        end
        % add fractions of second:
        % I do not know how to read fractions of second by datetime nor strptime in Octave, so this
        % line fix it. (It is possible to do in Matlab using SSSSS)
        posixnumber = posixnumber + secfrac;
end

function isostring = posix2iso_time(posixnumber)
        % posix time to ISO8601 time both for GNU Octave and Matlab
        % posix time is number of seconds since the epoch, the epoch is referenced to 00:00:00 CUT
        % (Coordinated Universal Time) 1 Jan 1970, for example, on Monday February 17, 1997 at 07:15:06 CUT,
        % the value returned by 'time' was 856163706.)
        % ISO 8601
        % YYYY-mm-DDTHH:MM:SS.6S(+|-)HH:MM
        % 2011-12-13T14:15:16
        % 2011-12-13T14:15:16.123456
        % 2011-12-13T14:15:16.123456Z
        % 2011-12-13T14:15:16.123456+01:00
        % 2011-12-13T14:15:16.123456-01:00
        % 2011-12-13T14:15:16-01:00

        if isOctave
                % Octave version:
                isostring = strftime('%Y-%m-%dT%H:%M:%S%z', localtime(posixnumber));
                % add decimal dot and microseconds:
                isostring = [isostring(1:end-5) '.' num2str(localtime(posixnumber).usec, '%0.6d') isostring(end-5:end-2) ':' isostring(end-1:end)];
        else
                % Matlab version:
                isostring = datetime(posixnumber, 'ConvertFrom', 'posixtime', 'TimeZone', 'local', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSSxxxxx');
                isostring = strrep(char(isostring), ' ', 'T');
        end
end

% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \n#startmatrix:: time matrix\n  2013-12-11T22:59:30.123456+01:00\n  2013-12-11T22:59:35.123456+01:00\n#endmatrix:: time matrix\nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(all(all( abs(infogettimematrix(infostr,'time matrix') - [1386799170.12346; 1386799175.12346]) < 6e-6 )))
%!error(infogettimematrix('', ''));
%!error(infogettimematrix('', infostr));
%!error(infogettimematrix(infostr, ''));
%!error(infogettimematrix(infostr, 'A', {'section 1'}));
