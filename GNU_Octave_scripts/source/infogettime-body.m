function time = infogettime(infostr, key, varargin) %<<<1
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
                error('infogettime: infostr and key must be strings')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infogettime: scell must be a cell of strings')
        endif

        % get time %<<<2
        % get time as text:
        try
                s = infogettext(infostr, key, scell);
        catch
                [msg, msgid] = lasterr;
                id = findstr(msg, 'infogettext: key');
                if isempty(id)
                        % unknown error
                        error(msg)
                else
                        % infogettext error change to infogettime error:
                        msg = ['infogettime' msg(12:end)];
                        error(msg)
                endif
        end_try_catch
        % ISO 8601
        % %Y-%m-%dT%H:%M:%S%20u
        % 2013-12-11T22:59:30.15648946
        % parse of time data:
        time = mktime(strptime(s, '%Y-%m-%dT%H:%M:%S'));
        if isempty(time)
                error(['infogettime: key `' key '` does not contain time data'])
        endif
        % I do not know how to read fractions of second by strptime, so this line fix it:
        time = time + str2num(s(20:end));
endfunction

