function infostr = infosettext(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettext', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if ~ischar(val)
                error('infosettext: val must be string')
        endif

        % make infostr %<<<2
        % add value to infostr:
        infostr = set_key('infosettext', infostr, key, val, scell);
endfunction

