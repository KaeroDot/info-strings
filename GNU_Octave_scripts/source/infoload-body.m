function infostr = infoload(filename, varargin) %<<<1
        % input possibilities:
        %       filename
        %       filename, autoextension

        % check inputs %<<<2
        if ~(nargin==1 || nargin==2)
                print_usage()
        endif
        if nargin == 1
                autoextension = 1;
        else
                autoextension = varargin{1};
        endif
        if (~ischar(filename))
                error('infoload: filename must be string')
        endif

        % check extension %<<<2
        if autoextension
                % automatic addition of extension required
                if length(filename) < 5
                        % too short filename, therefore extension is definitely missing:
                                filename = [filename '.info'];
                else
                        if ~strcmpi(filename(end-4:end), '.info')
                                % extension .info is missing
                                filename = [filename '.info'];
                        endif
                endif
        endif
        % check if file exist:
        if ~exist(filename, 'file')
                error(['infoload: file `' filename '` not found'])
        endif

        % read file %<<<2
        fid = fopen(filename, 'r');
        if fid == -1
                error(['infoload: error opening file `' filename '`'])
        endif
        [infostr,count] = fread(fid, [1,inf], 'uint8=>char');  % s will be a character array, count has the number of bytes
        fclose(fid);
endfunction

