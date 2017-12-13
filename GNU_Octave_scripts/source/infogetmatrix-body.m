function matrix = infogetmatrix(infostr, key, varargin) %<<<1
        % input possibilities:
        %       infostr, key,
        %       infostr, key, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % check inputs %<<<2
        if (nargin < 2 || nargin > 3)
                print_usage()
        endif
        % set default value
        % (this is because Matlab cannot assign default value in function definition)
        if nargin < 3
                scell = {};
        else
                scell = varargin{1};
        endif
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key))
                error('infogetmatrix: infostr and key must be strings')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infogetmatrix: scell must be a cell of strings')
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

