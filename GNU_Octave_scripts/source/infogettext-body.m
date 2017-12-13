function text = infogettext(infostr, key, varargin) %<<<1
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
                error('infogettext: infostr and key must be strings')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infogettext: scell must be a cell of strings')
        endif

        % get text %<<<2
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
                                error('infogettext: infinite loop happened!')
                        endif
                endif
        endwhile
        % find key and get value
        % regexp for rest of line after a key:
        rol = '\s*::([^\n]*)';
        %remove leading spaces of key and escape characters:
        key = regexpescape(strtrim(key));
        % find line with the key:
        % (?m) is regexp flag: ^ and $ match start and end of line
        [S, E, TE, M, T, NM] = regexpi (infostr,['(?m)^\s*' key rol]);
        % return key if found:
        if isempty(T)
                error(['infogettext: key `' key '` not found'])
        else
                if isscalar(T)
                        text = strtrim(T{1}{1});
                else
                        error(['infogettext: key `' key '` found on multiple places'])
                endif
        endif
endfunction

