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

        % check inputs %<<<2
        if (nargin < 2 || nargin > 4)
                print_usage()
        endif
        % identify inputs
        if nargin == 4
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        elseif nargin == 2;
                infostr = '';
                key = varargin{1};
                val = varargin{2};
                scell = {};
        else
                if iscell(varargin{3})
                        infostr = '';
                        key = varargin{1};
                        val = varargin{2};
                        scell = varargin{3};
                else
                        infostr = varargin{1};
                        key = varargin{2};
                        val = varargin{3};
                        scell = {};
                endif
        endif
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key))
                error('infosetmatrix: infostr and key must be strings')
        endif
        if (~iscell(val))
                error('infosetmatrix: val must be a cell of strings')
        endif
        if (~all(cellfun(@ischar, val)))
                error('infosetmatrix: val must be a cell of strings')
        endif
        if (~iscell(scell))
                error('infosetmatrix: scell must be a cell')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infosetmatrix: scell must be a cell of strings')
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

