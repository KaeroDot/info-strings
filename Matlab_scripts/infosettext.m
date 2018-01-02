function infostr = infosettext(varargin)%<<<1
% -- Function File: INFOSTR = infosettext (KEY, VAL)
% -- Function File: INFOSTR = infosettext (KEY, VAL, SCELL)
% -- Function File: INFOSTR = infosettext (INFOSTR, KEY, VAL)
% -- Function File: INFOSTR = infosettext (INFOSTR, KEY, VAL, SCELL)
%     Returns info string with key KEY and text VAL in following format:
%          key:: val
%
%     If SCELL is set, the key/value is enclosed by section(s) according
%     SCELL.
%
%     If INFOSTR is set, the key/value is put into existing INFOSTR
%     sections, or sections are generated if needed and properly
%     appended/inserted into INFOSTR.
%
%     Example:
%          infosettext('key', 'value')
%          infostr = infosettext('key', 'value', {'section key', 'subsection key'})
%          infosettext(infostr, 'other key', 'other value', {'section key', 'subsection key'})

% Copyright (C) 2014 Martin Šíra %<<<1
%

% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2014
% Version: 4.0
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: yes
%   Contains demo: no
%   Optimized: no

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettext', varargin{:});
        if printusage
                print_usage()
        end
        % check content of val:
        if ~ischar(val)
                error('infosettext: val must be string')
        end

        % make infostr %<<<2
        % add value to infostr:
        infostr = set_key('infosettext', infostr, key, val, scell);
end

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
        end
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
                end
        end

        % check values of inputs infostr, key, scell %<<<2
        % input val have to be checked by infoset* function!
        if (~ischar(infostr) || ~ischar(key))
                error([functionname ': infostr and key must be strings'])
        end
        if isempty(key)
                error([functionname ': key is empty string'])
        end
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        end
        if (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        end
end

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
                end
                infostr = [before newline];
        else
                infostr = set_section('infosetnumber', infostr, newline, scell, true);
        end
end

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
        end

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
                        end
                end
                % split info string according found position:
                infostrA = infostr(1:position);
                infostrB = infostr(position+1:end);
                % remove leading spaces and keep newline in part A:
                if isempty(infostrA)
                        before = '';
                else
                        before = [deblank(infostrA) NL];
                end
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
                end
                % create main section if needed
                if i < length(scell);
                        % simply generate section
                        % (here could be a line with sprintf, or subfunction can be used, but recursion 
                        % seems to be the simplest solution
                        toinsert = set_section(functionname, '', toinsert, scell(i+1), indent);
                        spaces = repmat(' ', 1, i.*INDENT_LEN);
                        toinsert = [deblank(strrep([NL strtrim(toinsert) NL], NL, [NL spaces])) NL];
                end
                toinsert = regexprep(toinsert, '^\n', '');
                % create new infostr by inserting new part at proper place of old infostr:
                infostr = deblank([before deblank(toinsert) NL infostrB]);
        end
end

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
                                        end
                                        % remove previous parts of infostr to start looking for 
                                        % wanted section after the end of found section:
                                        infostr = infostr(E+1:end);
                                        % calculate correct position that will be returned to user:
                                        endposition = endposition + E;
                                end
                        end
                end
                % if nothing found:
                if isempty(section)
                        error([functionname ': section `' scell{1} '` not found'])
                end
                % some result was obtained. if subsections are required, do recursion:
                if length(scell) > 1
                        % recursively call for subsections:
                        tmplength = length(section);
                        [section, tmppos] = get_section(functionname, section, scell(2:end));
                        endposition = endposition - (tmplength - tmppos);
                end
        end
end

% --------------------------- tests: %<<<1
%!shared istxt, iskey, iskeydbl
%! istxt = 'key:: val';
%! iskey = sprintf('#startsection:: skey\n        key:: val\n#endsection:: skey');
%! iskeydbl = sprintf('#startsection:: skey\n        key:: val\n        key:: val\n#endsection:: skey');
%!assert(strcmp(infosettext( 'key', 'val'                               ), istxt));
%!assert(strcmp(infosettext( 'key', 'val', {'skey'}                     ), iskey));
%!assert(strcmp(infosettext( iskey, 'key', 'val'                        ), [iskey sprintf('\n') istxt]));
%!assert(strcmp(infosettext( iskey, 'key', 'val', {'skey'}              ), iskeydbl));
%!error(infosettext('a'))
%!error(infosettext(5, 'a'))
%!error(infosettext('a', 5))
%!error(infosettext('a', 'b', 5))
%!error(infosettext('a', 'b', {5}))
%!error(infosettext('a', 'b', 'c', 'd'))
%!error(infosettext('a', 'b', 'c', {5}))
