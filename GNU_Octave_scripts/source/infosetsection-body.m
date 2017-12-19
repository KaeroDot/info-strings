function infostr = infosetsection(varargin) %<<<1
        % input possibilities:
        %       key, val
        %       val, scell
        %       key, val, scell - this possibility is not permitted because it cannot be distinguished between infostr and key, one can do: '', key, val, scell
        %       infostr, key, val
        %       infostr, val, scell
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
        if nargin == 2;
                if ~iscell(varargin{2})
                        infostr = '';
                        key = varargin{1};
                        val = varargin{2};
                        scell = {};
                else
                        infostr = '';
                        key = '';
                        val = varargin{1};
                        scell = varargin{2};
                endif
        elseif nargin == 3
                if iscell(varargin{3})
                        infostr = varargin{1};
                        key = '';
                        val = varargin{2};
                        scell = varargin{3};
                else
                        infostr = varargin{1};
                        key = varargin{2};
                        val = varargin{3};
                        scell = {};
                endif
        elseif nargin == 4
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        endif
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key) || ~ischar(val))
                error('infosetsection: infostr, key and val must be strings')
        endif
        if (~iscell(scell))
                error('infosetsection: scell must be a cell')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infosetsection: scell must be a cell of strings')
        endif

        % format inputs %<<<2
        if ~isempty(key)
                scell = [scell {key}];
        endif

        % make infostr %<<<2
        infostr = set_section('infosetsection', infostr, val, scell);
endfunction

