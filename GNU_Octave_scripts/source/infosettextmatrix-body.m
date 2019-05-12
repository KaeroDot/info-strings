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
                error('infosettextmatrix: val must be a cell of strings')
        endif
        if (~all(cellfun(@ischar, val)))
                error('infosettextmatrix: val must be a cell of strings')
        endif

        % make infostr %<<<2
        % convert matrix into text:
        % go line per line (thus semicolons and end of lines can be managed):
        matastext = '';
        % shall do indentation?
        indent = true;
        % escape semicolons:
        val = strrep(val, '"', '""');
        for i = 1:size(val,1)
                % for every row make a line:
                line = sprintf('"%s"; ', val{i,:});
                % disable indenting if line contains any of newline characters
                if ~isempty(strfind(line, char(10))) || ~isempty(strfind(line, char(13))) 
                        indent = false;
                endif
                % indentation inserts spaces into cells with newline characters!
                % join with previous lines, add indentation, add line without last semicolon and space, add end of line:
                matastext = [matastext line(1:end-2) NL];
        endfor
        % remove last end of line:
        matastext = matastext(1:end-length(NL));
        % add matrix to infostr:
        infostr = set_matrix('infosettextmatrix', infostr, key, matastext, scell, indent);
endfunction

