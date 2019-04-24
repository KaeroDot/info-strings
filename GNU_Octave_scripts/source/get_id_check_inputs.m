function [printusage, infostr, key, scell, is_parsed] = get_id_check_inputs(functionname, varargin) %<<<1
        % function identifies and partially checks inputs used in infoget* functions 
        % if printusage is true, infoget* function should call print_usage()
        %
        % input possibilities:
        %       infostr, key,
        %       infostr, key, scell

        printusage = false;
        infostr='';
        key='';
        scell={};

        % check inputs %<<<2
        if (nargin < 2+1 || nargin > 3+1)
                printusage = true;
                return;
        endif
        infostr = varargin{1};
        key = varargin{2};
        % set default value
        % (this is because Matlab cannot assign default value in function definition)
        if nargin < 3+1
                scell = {};
        else
                scell = varargin{3};
        endif

        % input is parsed info string? 
        is_parsed = isstruct(infostr) && isfield(infostr,'this_is_infostring');

        % check values of inputs infostr, key, scell %<<<2
        if ~ischar(infostr) && ~is_parsed
                error([functionname ': infostr must be either string or structure generated by infoparse()'])
        endif
        if ~ischar(key) || isempty(key)
                error([functionname ': key must be non-empty string'])
        endif
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        endif
        if length(scell) == 1 && isempty(scell{1})
                % atomatically generated values of cells are often [], not '', but still the cell is
                % empty, e.g.: 
                %       clear scell; scell{2} = 'sectionB'
                % than scell{1} is [].
                % so to remove user need to bother with this, if the scell contains single empty
                % value, it is automatically replaced by empty string.
                scell = {};
        endif
        if (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        endif
endfunction

