## Copyright (C) 2017 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosettextmatrix (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettextmatrix (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosettextmatrix (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettextmatrix (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with a text matrix formatted in following format:
## @example
## #startmatrix:: key
##      "val(1,1)"; "val(1,2)"; "val(1,3)";
##      "val(2,1)"; "val(2,2)"; "val(2,3)";
## #endmatrix:: key
##
## @end example
## If @var{scell} is set, the section is put into subsections according @var{scell}. 
##
## If @var{infostr} is set, the section is put into existing @var{infostr} 
## sections, or sections are generated if needed and properly appended/inserted
## into @var{infostr}.
##
## Example:
## @example
## infosettextmatrix('colours', @{'black'; 'blue'@})
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2017
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function infostr = infosettextmatrix(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettextmatrix', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~iscell(val))
                error('infosetmatrix: val must be a cell of strings')
        endif
        if (~all(cellfun(@ischar, val)))
                error('infosetmatrix: val must be a cell of strings')
        endif

        % make infostr %<<<2
        % convert matrix into text:
        % go line per line (thus semicolons and end of lines can be managed):
        matastext = '';
        % shall do indentation?
        indent = true;
        for i = 1:size(val,1)
                % for every row make a line:
                line = sprintf('"%s"; ', val{i,:});
                % disable indenting if line contains any of newline characters
                if ~isempty(strfind(line, char(10))) || ~isempty(strfind(line, char(13))) 
                        indent = false;
                endif
                % indentation inserts spaces into cells with newline characters!
                % join with previous lines, add indentation, add line without last semicolon and space, add end of line:
                matastext = [matastext line(1:end-2) NL];
        endfor
        % remove last end of line:
        matastext = matastext(1:end-length(NL));
        % add matrix to infostr:
        infostr = set_matrix('infosettextmatrix', infostr, key, matastext, scell, indent);
endfunction

function [printusage, infostr, key, val, scell] = set_id_check_inputs(functionname, varargin) %<<<1
        % function identifies and partially checks inputs used in infoset* functions 
        % if printusage is true, infoset* function should call print_usage()
        %
        % input possibilities:
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        printusage = false;
        infostr='';
        key='';
        val='';
        scell={};

        % check inputs %<<<2
        % (one input is functionname - in infoset* functions is not)
        if (nargin < 2+1 || nargin > 4+1)
                printusage = true;
                return
        endif
        % identify inputs
        if nargin == 4+1
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        elseif nargin == 2+1;
                infostr = '';
                key = varargin{1};
                val = varargin{2};
                scell = {};
        else
                if iscell(varargin{3})
                        infostr = '';
                        key = varargin{1};
                        val = varargin{2};
                        scell = varargin{3};
                else
                        infostr = varargin{1};
                        key = varargin{2};
                        val = varargin{3};
                        scell = {};
                endif
        endif

        % check values of inputs infostr, key, scell %<<<2
        % input val have to be checked by infoset* function!
        if (~ischar(infostr) || ~ischar(key))
                error([functionname ': infostr and key must be strings'])
        endif
        if isempty(key)
                error([functionname ': key is empty string'])
        endif
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        endif
        if (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        endif
endfunction

function infostr = set_matrix(functionname, infostr, key, matastext, scell, indent) %<<<1
        % make info line from matastext and key and put it into a proper section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - key for a new matrix
        % matastext - matrix as a string
        % scell - cell of strings with name of section and subsections
        % indent - boolean true if shall do indentation
        %
        % function suppose all inputs are ok!

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

        % add newline to beginning and to end:
        matastext = [NL matastext NL];
        % indent lines:
        matastext = strrep(matastext, NL, [NL repmat(' ', 1, INDENT_LEN)]);
        % remove indentation from last line:
        matastext = matastext(1:end-INDENT_LEN);

        % put matrix values between keys:
        matastext = sprintf('#startmatrix:: %s%s#endmatrix:: %s', key, matastext, key);

        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                endif
                infostr = [before matastext];
        else
                infostr = set_section('infosetnumber', infostr, matastext, scell, indent);
        endif
endfunction

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
endfunction

function [section, endposition] = get_section(functionname, infostr, scell) %<<<1
        % finds content of a section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        section = '';
        endposition = 0;
        if isempty(scell)
                % scell is empty thus current infostr is required:
                section = infostr;
        else
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
                                                error([functionname ': infinite loop happened!'])
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
                        error([functionname ': section `' scell{1} '` not found'])
                endif
                % some result was obtained. if subsections are required, do recursion:
                if length(scell) > 1
                        % recursively call for subsections:
                        tmplength = length(section);
                        [section, tmppos] = get_section(functionname, section, scell(2:end));
                        endposition = endposition - (tmplength - tmppos);
                endif
        endif
endfunction

% --------------------------- tests: %<<<1
%!shared ismat, ismatsec
%! ismat = sprintf('#startmatrix:: mat\n        "a"; "b"; "c"\n        "d"; "e"; "f"\n#endmatrix:: mat');
%! ismatsec = sprintf('#startsection:: skey\n        #startmatrix:: mat\n                "a"; "b"; "c"\n                "d"; "e"; "f"\n        #endmatrix:: mat\n#endsection:: skey');
%!assert(strcmp(infosettextmatrix( 'mat', {"a", "b", "c"; "d", "e", "f"}                ), ismat));
%!assert(strcmp(infosettextmatrix( 'mat', {"a", "b", "c"; "d", "e", "f"}, {'skey'}      ), ismatsec));
%!assert(strcmp(infosettextmatrix( 'testtext', 'mat', {"a", "b", "c"; "d", "e", "f"}, {'skey'}     ), ['testtext' sprintf('\n') ismatsec]));
%!error(infosettextmatrix('a'))
%!error(infosettextmatrix({'a'}, 'a'))
%!error(infosettextmatrix('a', 'b'))
%!error(infosettextmatrix('a', {'a'}, 'd'))
%!error(infosettextmatrix('a', {'a'}, {5}))
%!error(infosettextmatrix('a', 'b', {'a'}, 'd'))
%!error(infosettextmatrix('a', 'b', {'a'}, {5}))
