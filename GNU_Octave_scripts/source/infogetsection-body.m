function [section, endposition] = infogetsection(varargin) %<<<1
        % input possibilities:
        % varargin = infostr, key
        % varargin = infostr, scell
        % varargin = infostr, key, scell

        % check inputs %<<<2
        if (nargin < 2 || nargin > 3)
                print_usage()
        endif
        % identify inputs
        if nargin == 2
                if iscell(varargin{2})
                        infostr = varargin{1};
                        scell = varargin{2};
                        key = '';
                else
                        infostr = varargin{1};
                        key = varargin{2};
                        scell = {};
                endif
        else
                infostr = varargin{1};
                key = varargin{2};
                scell = varargin{3};
        endif
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key))
                error('infogetsection: str and key must be strings')
        endif
        if (~iscell(scell))
                error('infogetsection: scell must be a cell')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infogetsection: scell must be a cell of strings')
        endif

        % prepare inputs %<<<2
        if ~isempty(key)
                scell = [scell {key}];
        endif

        % get section %<<<2
        [section, endposition] = get_section('infogetsection', infostr, scell);
endfunction

