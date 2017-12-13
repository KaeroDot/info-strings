## Copyright (C) 2017 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettextmatrix (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettextmatrix (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds lines after line
## '#startmatrix:: key' and before '#endmatrix:: key', parse strings from lines
## and return as matrix.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
## infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
## infogettextmatrix(infostr,'simple matrix')
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2017
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function matrix = infogettextmatrix(infostr, key, varargin) %<<<1
        % input possibilities:
        %       infostr, key,
        %       infostr, key, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % check inputs %<<<2
        if (nargin < 2 || nargin > 3)
                print_usage()
        endif
        % set default value
        % (this is because Matlab cannot assign default value in function definition)
        if nargin < 3
                scell = {};
        else
                scell = varargin{1};
        endif
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key))
                error('infogetmatrix: infostr and key must be strings')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infogetmatrix: scell must be a cell of strings')
        endif

        % find proper section and remove subsections %<<<2
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
                                error('infogetmatrix: infinite loop happened!')
                        endif
                endif
        endwhile

        % get matrix %<<<2
        % prepare matrix:
        key = strtrim(key);
        % escape characters of regular expression special meaning:
        key = regexpescape(key);
        % find matrix:
        [S, E, TE, M, T, NM] = regexpi (infostr,['#startmatrix\s*::\s*' key '(.*)' '#endmatrix\s*::\s*' key], 'once');
        if isempty(T)
                error(['infogetmatrix: matrix named `' key '` not found'])
        endif
        infostr=strtrim(T{1});

        % parse matrix %<<<2
        matrix = csv2cell(infostr);
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

if isempty(strfind(s, CELLSTR)) %<<<2
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
        endif
        % strsplit by separators on all lines:
        s = cellfun(@strsplit, s, {CELLSEP}, 'UniformOutput', false);
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
                                endif
                        endif
                        % add new line of sheet:
                        data = [data; c];
                endfor
        end_try_catch
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
                endif
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
                                endif
                        else
                                Field = [Field curChar];
                        endif
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
                                endif
                        elseif curChar == LF
                                % found end of line (this also ends field)
                                FieldEnd = true;
                                LineEnd = true;
                                if nextChar == CR
                                        i = i + 1;      % increment counter to skip next character, which is already part of LFCR newline
                                endif
                        else
                                Field = [Field curChar];
                        endif
                endif
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
                                endif
                        endif
                        data(curCol, curRow) = {Field};
                        Field = '';
                        FieldEnd = false;
                        if LineEnd == true;
                                curRow = curRow + 1;
                                curCol = 1;
                                LineEnd = false;
                        else
                                curCol = curCol + 1;
                        endif
                endif
        endwhile
        data = data';
endif

endfunction

% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"   ; "c" \n"d";"e";         "f"    \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n#startmatrix:: simple matrix \n"b";  "c"; "d" \n"e";"f";         "g"  \n#endmatrix:: simple matrix \n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(all(all(strcmp( infogettextmatrix(infostr,'simple matrix'), {"a" "b" "c"; "d" "e" "f"} ))))
%!assert(all(all(strcmp( infogettextmatrix(infostr,'simple matrix', {'section 1', 'subsection'}), {"b" "c" "d"; "e" "f" "g"} ))))
%!error(infogettextmatrix('', ''));
%!error(infogettextmatrix('', infostr));
%!error(infogettextmatrix(infostr, ''));
%!error(infogettextmatrix(infostr, 'A', {'section 1'}));
