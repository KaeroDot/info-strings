function [val] = get_key(functionname, infostr, key, scell) %<<<1
        % returns value of key as text from infostr in section/subsections according scell
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - name of key for which val is searched
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        val = '';
        % get section:
        [infostr] = get_section(functionname, infostr, scell);
        % remove unwanted subsections:
        [infostr] = rem_subsections(functionname, infostr);

        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % look for scalar item:
                sid = find(strcmp(infostr.scalar_names,key));
                if isempty(sid)
                        error(sprintf('%s: key ''%s'' not found',functionname,key));
                endif
                
                if numel(sid) > 1
                        error(sprintf('%s: key ''%s'' found multiple times',functionname,key));
                endif
                
                % return item:
                val = infostr.scalars{sid};

        else
                % --- RAW INFO-STRING ---                

                % find key:
                [S, E, TE, M, T, NM] = regexpi (infostr, make_regexp(key, 'linekey'), 'once');
                % return key if found:
                if isempty(T)
                        error([functionname ': key `' key '` not found'])
                else
                        if isscalar(T)
                                val = strtrim(T{1});
                        else
                                error([functionname ': key `' key '` found on multiple places'])
                        endif
                endif
        endif
        
        
endfunction

