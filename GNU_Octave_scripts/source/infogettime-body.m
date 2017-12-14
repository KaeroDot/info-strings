function time = infogettime(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettime', varargin{:});
        if printusage
                print_usage()
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

