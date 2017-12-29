function infostr = set_key(functionname, infostr, key, valastext, scell) %<<<1
        % make info line from valastext and key and put it into a proper section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - key for a newline
        % valastext - value as a string
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % make infoline %<<<2
        % generate new line with key and val:
        newline = sprintf('%s:: %s', key, valastext);
        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                endif
                infostr = [before newline];
        else
                infostr = set_section('infosetnumber', infostr, newline, scell, true);
        endif
endfunction

