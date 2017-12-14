function matrix = infogetmatrix(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogetmatrix', varargin{:});
        if printusage
                print_usage()
        endif

        % find proper section and remove subsections %<<<2
        % find proper section(s):
        for i = 1:length(scell)
                infostr = infogetsection(infostr, scell{i});
        endfor
        % remove all other sections in infostr, to prevent finding
        % key inside of some section
        while (~isempty(infostr))
                % search sections one by one from start of infostr to end
                [S, E, TE, M, T, NM] = regexpi(infostr, ['#startsection\s*::\s*(.*)\s*\n(.*)\n\s*#endsection\s*::\s*\1'], 'once');
                if isempty(T)
                        % no section found, quit:
                        break
                else
                        % some section found, remove it from infostr:
                        infostr = [deblank(infostr(1:S-1)) NL fliplr(deblank(fliplr(infostr(E+1:end))))];
                        if S-1 >= E+1
                                % danger of infinite loop! this should never happen
                                error('infogetmatrix: infinite loop happened!')
                        endif
                endif
        endwhile

        % get matrix %<<<2
        % prepare matrix:
        key = strtrim(key);
        % escape characters of regular expression special meaning:
        key = regexpescape(key);
        % find matrix:
        [S, E, TE, M, T, NM] = regexpi (infostr,['#startmatrix\s*::\s*' key '(.*)' '#endmatrix\s*::\s*' key], 'once');
        if isempty(T)
                error(['infogetmatrix: matrix named `' key '` not found'])
        endif
        infostr=strtrim(T{1});

        % parse matrix %<<<2
        matrix = csv2cell(infostr);
        matrix = cellfun(@str2double, matrix, 'UniformOutput', false);
        matrix = cell2mat(matrix);
endfunction

