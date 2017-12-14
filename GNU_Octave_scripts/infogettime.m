## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettime (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettime (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds line with content "key:: value" and returns 
## the value as number of seconds since the epoch (as in function time()). Expected time format 
## is ISO 8601: %Y-%m-%dT%H:%M:%S.SSSSSS. The number of digits in fraction of seconds is not limited.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
## infostr = sprintf('T:: 2013-12-11T22:59:30.123456')
## infogettime(infostr,'T')
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

function time = infogettime(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettime', varargin{:});
        if printusage
                print_usage()
        endif

        % get time %<<<2
        % get time as text:
        try
                s = infogettext(infostr, key, scell);
        catch
                [msg, msgid] = lasterr;
                id = findstr(msg, 'infogettext: key');
                if isempty(id)
                        % unknown error
                        error(msg)
                else
                        % infogettext error change to infogettime error:
                        msg = ['infogettime' msg(12:end)];
                        error(msg)
                endif
        end_try_catch
        % ISO 8601
        % %Y-%m-%dT%H:%M:%S%20u
        % 2013-12-11T22:59:30.15648946
        % parse of time data:
        time = mktime(strptime(s, '%Y-%m-%dT%H:%M:%S'));
        if isempty(time)
                error(['infogettime: key `' key '` does not contain time data'])
        endif
        % I do not know how to read fractions of second by strptime, so this line fix it:
        time = time + str2num(s(20:end));
endfunction

function [printusage, infostr, key, scell] = get_id_check_inputs(functionname, varargin) %<<<1
        % function identifies and partially checks inputs used in infoget* functions 
        % if printusage is true, infoget* function should call print_usage()
        %
        % input possibilities:
        %       infostr, key,
        %       infostr, key, scell

        printusage = false;
        infostr='';
        key='';
        scell={};

        % check inputs %<<<2
        if (nargin < 2+1 || nargin > 3+1)
                printusage = true;
                return;
        endif
        infostr = varargin{1};
        key = varargin{2};
        % set default value
        % (this is because Matlab cannot assign default value in function definition)
        if nargin < 3+1
                scell = {};
        else
                scell = varargin{3};
        endif

        % check values of inputs infostr, key, scell %<<<2
        if (~ischar(infostr) || ~ischar(key))
                error('infogetmatrix: infostr and key must be strings')
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
function key = regexpescape(key) %<<<1
        % Translate all special characters (e.g., '$', '.', '?', '[') in
        % key so that they are treated as literal characters when used
        % in the regexp and regexprep functions. The translation inserts
        % an escape character ('\') before each special character.
        % additional characters are translated, this fixes error in octave
        % function regexptranslate.

        key = regexptranslate('escape', key);
        % test if octave error present:
        if strcmp(regexptranslate('escape','*(['), '*([')
                % fix octave error not replacing other special meaning characters:
                key = regexprep(key, '\*', '\*');
                key = regexprep(key, '\(', '\(');
                key = regexprep(key, '\)', '\)');
        endif
endfunction

% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nT:: 2013-12-11T22:59:30.123456\nC:: 2\n#startsection:: section 1 \n  C:: 3\n  #startsection:: subsection\n    C:: 4\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: 5\n#endsection:: section 2\n');
%!assert(infogettime(infostr,'T') == 1386799170.123456)
%!error(infogettime('', ''));
%!error(infogettime('', infostr));
%!error(infogettime(infostr, ''));
%!error(infogettime(infostr, 'A', {'section 1'}));
