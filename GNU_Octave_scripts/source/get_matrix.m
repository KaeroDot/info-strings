function [val] = get_matrix(functionname, infostr, key, scell) %<<<1
        % returns content of matrix as text from infostr in section/subsections according scell
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - name of matrix for which val is searched
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        val = '';
        % get section:
        [infostr] = get_section(functionname, infostr, scell);
        % remove unwanted subsections:
        [infostr] = rem_subsections(functionname, infostr);

        % get matrix:
        % prepare regexp:
        key = strtrim(key);
        
        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % search the matrix in the parsed list:
                mid = find(strcmp(infostr.matrix_names,key),1);
                if isempty(mid)
                        error([functionname ': matrix named `' key '` not found'])
                endif
                % return its content:
                val = infostr.matrix{mid};                
        else
                % --- RAW INFO-STRING --- 
                % find matrix:
                [S, E, TE, M, T, NM] = regexpi (infostr, make_regexp(key, 'matrix'), 'once');
                if isempty(M)
                        error([functionname ': matrix named `' key '` not found'])
                endif
                if isempty(T)
                        val = [];
                else
                        val=strtrim(T{1});
                endif
        endif
endfunction

