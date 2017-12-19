function infostr = infosettextmatrix(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettextmatrix', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~iscell(val))
                error('infosetmatrix: val must be a cell of strings')
        endif
        if (~all(cellfun(@ischar, val)))
                error('infosetmatrix: val must be a cell of strings')
        endif

        % make infostr %<<<2
        % convert matrix into text:
        % go line per line (thus semicolons and end of lines can be managed):
        matastext = '';
        for i = 1:size(val,1)
                % for every row make a line:
                line = sprintf('"%s"; ', val{i,:});
                % join with previous lines, add indentation, add line without last semicolon and space, add end of line:
                matastext = [matastext line(1:end-2) NL];
        endfor
        % add matrix to infostr:
        infostr = set_matrix('infosettextmatrix', infostr, key, matastext, scell);
endfunction

