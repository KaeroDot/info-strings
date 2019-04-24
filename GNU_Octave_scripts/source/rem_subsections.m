function [infostr] = rem_subsections(functionname, infostr) %<<<1
        % remove all other sections in infostr
        % used to prevent finding key or matrix inside of some section
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        %
        % function suppose all inputs are ok!

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        
        if ~isstruct(infostr)
                % --- only in raw text mode, ignore for parsed infostring ---
                NL = sprintf('\n');

                % remove unwanted sections:
                while (~isempty(infostr))
                        % search sections one by one from start of infostr to end
                        [S, E, TE, M, T, NM] = regexpi(infostr, ['#startsection\s*::\s*(.*)\s*\n(.*)\n\s*#endsection\s*::\s*\1'], 'once');
                        if isempty(T)
                                % no section found, quit:
                                break
                        else
                                % some section found, remove it from infostr:
                                infostr = [deblank(infostr(1:S-1)) NL fliplr(deblank(fliplr(infostr(E+1:end))))];
                                if S-1 >= E+1
                                        % danger of infinite loop! this should never happen
                                        error([functionname ': infinite loop happened!'])
                                endif
                        endif
                endwhile
        endif
endfunction

