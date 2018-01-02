function time = infogettime(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettime', varargin{:});
        if printusage
                print_usage()
        endif

        % get time %<<<2
        % get time as text:
        s = get_key('infogettime', infostr, key, scell);
        % parse of time data:
        time = iso2posix_time(s);
        if isempty(time)
                error(['infogettime: key `' key '` does not contain time data'])
        endif
endfunction

