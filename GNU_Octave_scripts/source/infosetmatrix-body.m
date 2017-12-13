function infostr = infosetmatrix(varargin) %<<<1
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
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosetmatrix', varargin{:}); %<<<1
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~ismatrix(val) || ~isnumeric(val))
                error('infosetmatrix: val must be a numeric matrix')
        endif

        % make infostr %<<<2
        % make template without semicolon after last number:
        template = repmat('%.20G; ', 1, size(val, 2));
        template = [template(1:end-2) NL];
        % format values
        newlines = sprintf(template, val');

        % add newline to beginning:
        newlines = [NL newlines];
        % indent lines:
        newlines = strrep(newlines, NL, [NL repmat(' ', 1, INDENT_LEN)]);
        % remove indentation from last line:
        newlines = newlines(1:end-INDENT_LEN);

        % put matrix values between keys:
        newlines = sprintf('#startmatrix:: %s%s#endmatrix:: %s', key, newlines, key);

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

