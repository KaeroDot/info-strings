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
        % escape characters of regular expression special meaning:
        key = regexpescape(key);
        % find matrix:
        [S, E, TE, M, T, NM] = regexpi (infostr,['#startmatrix\s*::\s*' key '(.*)' '#endmatrix\s*::\s*' key], 'once');
        if isempty(T)
                error([functionname ': matrix named `' key '` not found'])
        endif
        val=strtrim(T{1});
endfunction

