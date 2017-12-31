function infostr = infosettimematrix(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettimematrix', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~ismatrix(val) || ~isnumeric(val))
                error('infosettimematrix: val must be a numeric matrix')
        endif

        % make infostr %<<<2
        matastext = '';
        for i = 1:size(val, 1)
                line = '';
                for j = 1:size(val, 2)
                        % format time:
                        valastext = strftime('%Y-%m-%dT%H:%M:%S',localtime(val(i, j)));
                        % add decimal dot and microseconds:
                        valastext = [valastext '.' num2str(localtime(val(i, j)).usec, '%0.6d')];
                        % add value to infostr:
                        line = [line valastext '; '];
                endfor
                % join with previous lines, add indentation, add line without last semicolon and space, add end of line:
                matastext = [matastext line(1:end-2) NL];
        endfor
        % remove last end of line:
        matastext = matastext(1:end-length(NL));
        % add matrix to infostr:
        infostr = set_matrix('infosetmatrix', infostr, key, matastext, scell, true);
endfunction

