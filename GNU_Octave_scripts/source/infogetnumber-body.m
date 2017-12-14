function number = infogetnumber(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogetnumber', varargin{:});
        if printusage
                print_usage()
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

