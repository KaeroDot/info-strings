function text = infogettext(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettext', varargin{:});
        if printusage
                print_usage()
        endif

        % get text %<<<2
        text = get_key('infogettext', infostr, key, scell);
endfunction

