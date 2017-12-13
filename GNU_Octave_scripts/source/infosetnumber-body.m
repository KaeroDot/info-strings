function infostr = infosetnumber(varargin) %<<<1
        % input possibilities:
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosetnumber', varargin{:}); %<<<1
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~isscalar(val) || ~isnumeric(val))
                error('infosetnumber: val must be a numeric scalar')
        endif

        % make infostr %<<<2
        % generate new line with key and val:
        newline = sprintf('%s:: %.20G', key, val);
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

