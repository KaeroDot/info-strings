function infostr = infosettext(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

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
        % generate new line with key and val:
        newline = sprintf('%s:: %s', key, val);
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

