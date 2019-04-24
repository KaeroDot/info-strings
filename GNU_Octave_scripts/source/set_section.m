function infostr = set_section(functionname, infostr, content, scell, indent) %<<<1
        % put content into a proper section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % content - what to put into the section
        % scell - cell of strings with name of section and subsections
        % indent - boolean true if shall do indentation
        %
        % function suppose all inputs are ok!

        % input is parsed?
        in_is_parsed = isstruct(infostr) && isfield(infostr,'this_is_infostring');
        % new stuff is parsed? 
        new_is_parsed = isstruct(content) && isfield(content,'this_is_infostring');
        
        % check parameter compatibility
        if new_is_parsed ~= in_is_parsed
                error(sprintf('%s: input inf-string and new content must be of the same type',functionname));
        endif
        
        if in_is_parsed
                % --- PARSED INFO-STRING MODE ---
                
                % ###todo: implement recorusive insertion, so far it can just put stuff to global (not to subsections)
                
                if ~isempty(scell)
                        error(sprintf('%s: in parsed mode it can so far only insert data to global, not to subsections, sorry, too lazy...',functionname));                
                endif
                
                try
                        sections = infostr.sections;
                        sec_names = infostr.sec_names;
                catch
                        sections = {};
                        sec_names = {};
                end
                
                try
                        scalars = infostr.scalars;
                        scalar_names = infostr.scalar_names;
                catch
                        scalars = {};
                        scalar_names = {};
                end
                
                try
                        matrix = infostr.matrix;
                        matrix_names = infostr.matrix_names;
                catch
                        matrix = {};
                        matrix_names = {};
                end
                
                %    all_parsed - true when mode 'all'
                %    matrix_parsed - true when mode 'all' or 'matrix'
                %    data - unparsed section content, note it is removed vhen mode is 'all'
                
                % merge info-strings
                infostr.sections = {sections{:} content.sections{:}};  
                infostr.sec_names = {sec_names{:} content.sec_names{:}};
                infostr.sec_count = numel(infostr.sections);                
                infostr.scalars = {scalars{:} content.scalars{:}};  
                infostr.scalar_names = {scalar_names{:} content.scalar_names{:}};
                infostr.scalar_count = numel(infostr.scalars);                
                infostr.matrix = {matrix{:} content.matrix{:}};  
                infostr.matrix_names = {matrix_names{:} content.matrix_names{:}};
                infostr.matrix_count = numel(infostr.matrix);
                infostr.all_parsed = 1;
                infostr.matrix_parsed = 1;
                infostr.this_is_infostring = 1;
                
        else
                % --- RAW INFO-STRING MODE ---
                
                % Constant with OS dependent new line character:
                % (This is because of Matlab cannot translate special characters
                % in strings. GNU Octave distinguish '' and "")
                NL = sprintf('\n');

                % number of spaces in indented section:
                if indent
                        INDENT_LEN = 8;
                else
                        INDENT_LEN = 0;
                endif

                % make infostr %<<<2
                if (isempty(infostr) && length(scell) == 1)
                        % just simply generate info string
                        % add newlines to a content, indent lines by INDENT_LEN, remove indentation from last line:
                        spaces = repmat(' ', 1, INDENT_LEN);
                        content = [deblank(strrep([NL strtrim(content) NL], NL, [NL spaces])) NL];
                        % create infostr:
                        infostr = [infostr sprintf('#startsection:: %s%s#endsection:: %s', scell{end}, content, scell{end})];
                else
                        % make recursive preparation of info string
                        % find out how many sections from scell already exists in infostr:
                        position = length(infostr);
                        for i = 1:length(scell)
                                % through deeper and deeper section path
                                try
                                        % check section path scell(1:i):
                                        [tmp, position] = get_section(functionname, infostr, scell(1:i));
                                catch
                                        % error happened -> section path scell(1:i) do not exist:
                                        i = i - 1;
                                        break
                                end_try_catch
                        endfor
                        % split info string according found position:
                        infostrA = infostr(1:position);
                        infostrB = infostr(position+1:end);
                        % remove leading spaces and keep newline in part A:
                        if isempty(infostrA)
                                before = '';
                        else
                                before = [deblank(infostrA) NL];
                        endif
                        % remove leading new lines if present in part B:
                        infostrB = regexprep(infostrB, '^\n', '');
                        % create sections if needed:
                        if i < length(scell) - 1;
                                % make recursion to generate new sections:
                                toinsert = set_section(functionname, '', content, scell(i+2:end), indent);
                        else
                                % else just use content with proper indentation:
                                spaces = repmat(' ', 1, i.*INDENT_LEN);
                                toinsert = [deblank(strrep([NL strtrim(content) NL], NL, [NL spaces])) NL];
                        endif
                        % create main section if needed
                        if i < length(scell);
                                % simply generate section
                                % (here could be a line with sprintf, or subfunction can be used, but recursion 
                                % seems to be the simplest solution
                                toinsert = set_section(functionname, '', toinsert, scell(i+1), indent);
                                spaces = repmat(' ', 1, i.*INDENT_LEN);
                                toinsert = [deblank(strrep([NL strtrim(toinsert) NL], NL, [NL spaces])) NL];
                        endif
                        toinsert = regexprep(toinsert, '^\n', '');
                        % create new infostr by inserting new part at proper place of old infostr:
                        infostr = deblank([before deblank(toinsert) NL infostrB]);
                endif
        endif
endfunction

