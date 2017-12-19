function infostr = infosetmatrix(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosetmatrix', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~ismatrix(val) || ~isnumeric(val))
                error('infosetmatrix: val must be a numeric matrix')
        endif

        % make infostr %<<<2
        % convert matrix into text:
        % make template without semicolon after last number:
        template = repmat('%.20G; ', 1, size(val, 2));
        template = [template(1:end-2) NL];
        % format values
        matastext = sprintf(template, val');
        % add matrix to infostr:
        infostr = set_matrix('infosetmatrix', infostr, key, matastext, scell);
endfunction

