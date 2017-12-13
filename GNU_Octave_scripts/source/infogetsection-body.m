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

        % format inputs %<<<2
        if ~isempty(key)
                scell = [scell {key}];
        endif

        % get section %<<<2
        section = '';
        endposition = 0;
        while (~isempty(infostr))
                % search sections one by one from start of infostr to end
                [S, E, TE, M, T, NM] = regexpi(infostr, ['#startsection\s*::\s*(.*)\s*\n(.*)\n\s*#endsection\s*::\s*\1'], 'once');
                if isempty(T)
                        % no section found
                        section = '';
                        break
                else
                        % some section found
                        if strcmp(strtrim(T{1}), scell{1})
                                % wanted section found
                                section = strtrim(T{2});
                                endposition = endposition + TE(end,end);
                                break
                        else
                                % found section is not the one wanted
                                if E < 2
                                        % danger of infinite loop! this should never happen
                                        error('infogetsection: infinite loop happened!')
                                endif
                                % remove previous parts of infostr to start looking for 
                                % wanted section after the end of found section:
                                infostr = infostr(E+1:end);
                                % calculate correct position that will be returned to user:
                                endposition = endposition + E;
                        endif
                endif
        endwhile
        % if nothing found:
        if isempty(section)
                error(['infogetsection: section `' scell{1} '` not found'])
        endif
        % some result was obtained. if subsections are required, do recursion:
        if length(scell) > 1
                % recursively call for subsections:
                [tmpsection, tmppos] = infogetsection(section, scell(2:end));
                endposition = endposition - (length(section) - tmppos);
                section = tmpsection;
        endif
endfunction

