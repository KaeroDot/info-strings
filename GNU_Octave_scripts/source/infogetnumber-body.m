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

