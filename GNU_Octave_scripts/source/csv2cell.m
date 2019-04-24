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
        endif
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
                                endif
                        endif
                        % add new line of sheet:
                        data = [data; c];
                endfor
        end_try_catch
        
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

