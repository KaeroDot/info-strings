## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} [@var{section}, @var{endposition}] = infogetsection (@var{infostr}, @var{key})
## @deftypefnx {Function File} [@var{section}, @var{endposition}]= infogetsection (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds lines after line
## '#startsection:: key' and before line '#endsection:: key' and returns them.
## 
## If @var{scell} is set, the section is searched in section(s) defined by string(s) in cell.
##
## Second output argument returns the index of end of section.
##
## Example:
## @example
## infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
## infogetsection(infostr, 'section 1')
## infogetsection(infostr, 'subsection', @{'section 1'@})
## infogetsection(infostr, @{'section 1', 'subsection'@})
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2013
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

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

        % prepare inputs %<<<2
        if ~isempty(key)
                scell = [scell {key}];
        endif

        % get section %<<<2
        section = get_section('infogetsection', infostr, scell)
endfunction

function [section] = get_section(functionname, infostr, scell) %<<<1
        % finds content of a section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        section = '';
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
                        section = get_section(functionname, section, scell(2:end));
                endif
        endif
endfunction

% --------------------------- tests: %<<<1
%!shared infostr, section1, section2, section1subsection, indx
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%! section1 = sprintf('C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection');
%! section2 = sprintf('C:: c in section 2');
%! section1subsection = sprintf('C:: c in subsection');
%!assert(strcmp(infogetsection(infostr, 'section 1'), section1))
%! [tmp, indx] = infogetsection(infostr, 'section 1');
%!assert(indx == 283)
%!assert(strcmp(infogetsection(infostr, 'section 2'), section2))
%!assert(strcmp(infogetsection(infostr, 'subsection', {'section 1'}), section1subsection))
%!assert(strcmp(infogetsection(infostr, {'section 1', 'subsection'}), section1subsection))
%!error(infogetsection(infostr, 'section 3'))
%!error(infogetsection(infostr, 'section 1', {'section 2'}))
%!error(infogetsection(infostr, 'section 2', {'section 1'}))
%!error(infogetsection(infostr, {'section 1', 'section 2'}))
%!error(infogetsection(infostr, 'section 3', {'section 1'}))
