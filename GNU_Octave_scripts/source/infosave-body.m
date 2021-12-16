function succes = infosave(infostr, filename, varargin) %<<<1
        % input possibilities:
        %       infostr, filename
        %       infostr, filename, autoextension
        %       infostr, filename, autoextension, overwrite

        % check inputs %<<<2
        if (nargin<2 || nargin>4)
                print_usage()
        endif
        if nargin == 2
                autoextension = 1;
                overwrite = 0;
        elseif nargin == 3
                autoextension = varargin{1};
                overwrite = 0;
        else
                autoextension = varargin{1};
                overwrite = varargin{2};
        endif
        if (~ischar(filename) || ~ischar(infostr))
                error('infosave: infostr and filename must be strings')
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
        if ~overwrite
                if exist(filename, 'file')
                        error(['infosave: file `' filename '` already exists'])
                endif
        endif

        % write file %<<<2
        fid = fopen (filename, 'w');
        if fid == -1
                error(['infosavefile: error opening file `' filename '`'])
        endif
        % convert LF line endings to CRLF if in windows OS
        if ispc
            infostr = strrep(infostr, char(10), [char(13) char(10)]);
        end % if ispc
        fprintf(fid, '%s', infostr);
        fclose(fid);
endfunction

