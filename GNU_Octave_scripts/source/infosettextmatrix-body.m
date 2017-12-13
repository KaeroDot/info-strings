function infostr = infosettextmatrix(varargin) %<<<1
        % input possibilities:
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % constant - number of spaces in indented section:
        INDENT_LEN = 8;

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettextmatrix', varargin{:}); %<<<1
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
        % go line per line (thus semicolons and end of lines can be managed):
        newlines = '';
        for i = 1:size(val,1)
                % for every row make a line:
                newline = sprintf('"%s"; ', val{i,:});
                % join with previous lines, add indentation, add line without last semicolon and space, add end of line:
                newlines = [newlines repmat(' ', 1, INDENT_LEN) newline(1:end-2) NL];
        endfor

        % put matrix values between keys:
        newlines = sprintf('#startmatrix:: %s%s%s#endmatrix:: %s', key, NL, newlines, key);

        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                endif
                infostr = [before newlines];
        else
                infostr = infosetsection(infostr, newlines, scell);
        endif
endfunction

