function infostr = infosettime(varargin) %<<<1
        % input possibilities:
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

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
                error('infosettime: infostr and key must be strings')
        endif
        if (~isscalar(val) || ~isnumeric(val))
                error('infosettime: val must be a numeric scalar')
        endif
        if (~iscell(scell))
                error('infosettime: scell must be a cell')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infosettime: scell must be a cell of strings')
        endif

        % make infostr %<<<2
        % format time:
        newline = strftime('%Y-%m-%dT%H:%M:%S',localtime(val));
        % add decimal dot and microseconds:
        newline = [newline '.' num2str(localtime(val).usec, '%0.6d')];
        % generate new line with key and val:
        newline = sprintf('%s:: %s', key, newline);
        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                endif
                infostr = [before newline];
        else
                infostr = infosetsection(infostr, newline, scell);
        endif
endfunction

