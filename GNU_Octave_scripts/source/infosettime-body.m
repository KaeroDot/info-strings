function infostr = infosettime(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettime', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~isscalar(val) || ~isnumeric(val))
                error('infosettime: val must be a numeric scalar')
        endif

        % make infostr %<<<2
        % convert value to text:
        % format time:
        valastext = strftime('%Y-%m-%dT%H:%M:%S',localtime(val));
        % add decimal dot and microseconds:
        valastext = [valastext '.' num2str(localtime(val).usec, '%0.6d')];
        % add value to infostr:
        infostr = set_key('infosettime', infostr, key, valastext, scell);
endfunction

