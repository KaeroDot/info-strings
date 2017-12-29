## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosetsection (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetsection (@var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosetsection (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetsection (@var{infostr}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosetsection (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with a section made from @var{key} and string
## @var{val} in following format:
## @example
## #startsection:: key
##      val
## #endsection:: key
##
## @end example
## If @var{scell} is set, the section is put into subsections according @var{scell}. 
## If @var{key} is not specified, last element of @var{scell} is considered as @var{key}.
##
## If @var{infostr} is set, the section is put into existing @var{infostr} 
## sections, or sections are generated if needed.
##
## Example:
## @example
## infosetsection('section key', sprintf('multi\nline\nvalue'))
## infostr = infosetsection('value', @{'section key', 'subsection key'@})
## infosetsection(infostr, 'subsubsection key', 'other value', @{'section key', 'subsection key'@})
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function infostr = infosetsection(varargin) %<<<1
        % input possibilities:
        %       key, val
        %       val, scell
        %       key, val, scell - this possibility is not permitted because it cannot be distinguished between infostr and key, one can do: '', key, val, scell
        %       infostr, key, val
        %       infostr, val, scell
        %       infostr, key, val, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % constant - number of spaces in indented section:
        INDENT_LEN = 8;

        % check inputs %<<<2
        if (nargin < 2 || nargin > 4)
                print_usage()
        endif
        % identify inputs
        if nargin == 2;
                if ~iscell(varargin{2})
                        infostr = '';
                        key = varargin{1};
                        val = varargin{2};
                        scell = {};
                else
                        infostr = '';
                        key = '';
                        val = varargin{1};
                        scell = varargin{2};
                endif
        elseif nargin == 3
                if iscell(varargin{3})
                        infostr = varargin{1};
                        key = '';
                        val = varargin{2};
                        scell = varargin{3};
                else
                        infostr = varargin{1};
                        key = varargin{2};
                        val = varargin{3};
                        scell = {};
                endif
        elseif nargin == 4
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        endif
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key) || ~ischar(val))
                error('infosetsection: infostr, key and val must be strings')
        endif
        if (~iscell(scell))
                error('infosetsection: scell must be a cell')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infosetsection: scell must be a cell of strings')
        endif

        % format inputs %<<<2
        if ~isempty(key)
                scell = [scell {key}];
        endif

        % make infostr %<<<2
        infostr = set_section('infosetsection', infostr, val, scell, true);
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
%!shared iskey, iskeysubkey, iskey2, isvalval2, isvalsubval2
%! iskey = sprintf('#startsection:: skey\n        key:: val\n#endsection:: skey');
%! iskeysubkey = sprintf('#startsection:: skey\n        #startsection:: subskey\n                key:: val\n        #endsection:: subskey\n#endsection:: skey');
%! iskey2 = sprintf('#startsection:: skey2\n        key:: val\n#endsection:: skey2');
%! isvalval2 = sprintf('#startsection:: skey\n        #startsection:: subskey\n                key:: val\n        #endsection:: subskey\n        key:: val2\n#endsection:: skey');
%! isvalsubval2 = sprintf('#startsection:: skey\n        #startsection:: subskey\n                key:: val\n                key:: val2\n        #endsection:: subskey\n#endsection:: skey');
%!assert(strcmp(infosetsection( 'skey', 'key:: val'                             ), iskey));
%!assert(strcmp(infosetsection( 'key:: val', {'skey'}                           ), iskey));
%!assert(strcmp(infosetsection( 'key:: val', {'skey', 'subskey'}                ), iskeysubkey));
%!assert(strcmp(infosetsection( iskey, 'skey2', 'key:: val'                     ), [iskey  sprintf('\n') iskey2]));
%!assert(strcmp(infosetsection( iskey, 'key:: val', {'skey2'}                   ), [iskey  sprintf('\n') iskey2]));
%!assert(strcmp(infosetsection( iskey2, 'subskey', 'key:: val', {'skey'}        ), [iskey2 sprintf('\n') iskeysubkey]));
%!assert(strcmp(infosetsection( iskeysubkey, 'key:: val2', {'skey'}             ), isvalval2));
%!assert(strcmp(infosetsection( iskeysubkey, 'subskey', 'key:: val2', {'skey'}  ), isvalsubval2));
%!error(infosetsection('a'))
%!error(infosetsection(5))
%!error(infosetsection('a', 'b', 'c', 'd'))
%!error(infosetsection('a', 'b', 'c', {5}))
