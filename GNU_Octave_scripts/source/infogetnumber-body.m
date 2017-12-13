function number = infogetnumber(infostr, key, varargin) %<<<1
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
                error('infogetnumber: infostr and key must be strings')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infogetnumber: scell must be a cell of strings')
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

