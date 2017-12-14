function infostr = infosettime(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

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
        % format time:
        newline = strftime('%Y-%m-%dT%H:%M:%S',localtime(val));
        % add decimal dot and microseconds:
        newline = [newline '.' num2str(localtime(val).usec, '%0.6d')];
        % generate new line with key and val:
        newline = sprintf('%s:: %s', key, newline);
        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                endif
                infostr = [before newline];
        else
                infostr = infosetsection(infostr, newline, scell);
        endif
endfunction

