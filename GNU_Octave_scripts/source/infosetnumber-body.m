function infostr = infosetnumber(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosetnumber', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~isscalar(val) || ~isnumeric(val))
                error('infosetnumber: val must be a numeric scalar')
        endif

        % make infostr %<<<2
        % convert value to text:
        valastext = sprintf('%.20G', val);
        % add value to infostr:
        infostr = set_key('infosetnumber', infostr, key, valastext, scell);
endfunction

