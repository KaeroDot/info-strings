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
        if (ndims(val) > 2 || ~isnumeric(val))
                error('infosetmatrix: val must be a numeric matrix')
        endif

        % make infostr %<<<2
        % convert matrix into text:
        if numel(val) == 0
                % mat2str of empty matrix generates [], that is read by csv2cell as single NaN
                % to prevent this:
                matastext = '';
        else
                matastext = mat2str(val);
                % remove leading '[' and closing ']':
                if numel(val) > 1
                        % #fix: the [] are there only if 'val' has more than one item
                        matastext = matastext(2:end-1);
                end
                % replace semicolons to newlines and spaces to semicolons:
                matastext = strrep(matastext, ';', NL);
                matastext = strrep(matastext, ' ', '; ');
        endif

        % add matrix to infostr:
        infostr = set_matrix('infosetmatrix', infostr, key, matastext, scell, true);
endfunction

