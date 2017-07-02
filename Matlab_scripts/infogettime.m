function time = infogettime(infostr, key, varargin)%<<<1
% -- Function File: TEXT = infogettime (INFOSTR, KEY)
% -- Function File: TEXT = infogettime (INFOSTR, KEY, SCELL)
%     Parse info string INFOSTR, finds line with content "key:: value"
%     and returns the value as number of seconds since the epoch (as in
%     function time()).  Expected time format is ISO 8601:
%     %Y-%m-%dT%H:%M:%S.SSSSSS. The number of digits in fraction of
%     seconds is not limited.
%
%     If SCELL is set, the key is searched in section(s) defined by
%     string(s) in cell.
%
%     Example:
%          infostr = sprintf('T:: 2013-12-11T22:59:30.123456')
%          infogettime(infostr,'T')

% Copyright (C) 2013 Martin Šíra %<<<1
%

% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2013
% Version: 2.0
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: yes
%   Contains demo: no
%   Optimized: no

        % input possibilities:
        %       infostr, key,
        %       infostr, key, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % check inputs %<<<2
        if (nargin < 2 || nargin > 3)
                print_usage()
        end
        % set default value
        % (this is because Matlab cannot assign default value in function definition)
        if nargin < 3
                scell = {};
        else
                scell = varargin{1};
        end
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key))
                error('infogettime: infostr and key must be strings')
        end
        if (~all(cellfun(@ischar, scell)))
                error('infogettime: scell must be a cell of strings')
        end

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
                end
        end
        % ISO 8601
        % %Y-%m-%dT%H:%M:%S%20u
        % 2013-12-11T22:59:30.15648946
        % parse of time data:
        time = mktime(strptime(s, '%Y-%m-%dT%H:%M:%S'));
        if isempty(time)
                error(['infogettime: key `' key '` does not contain time data'])
        end
        % I do not know how to read fractions of second by strptime, so this line fix it:
        time = time + str2num(s(20:end));
end

function key = regexpescape(key)
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
        end
end

% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nT:: 2013-12-11T22:59:30.123456\nC:: 2\n#startsection:: section 1 \n  C:: 3\n  #startsection:: subsection\n    C:: 4\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: 5\n#endsection:: section 2\n');
%!assert(infogettime(infostr,'T') == 1386799170.123456)
%!error(infogettime('', ''));
%!error(infogettime('', infostr));
%!error(infogettime(infostr, ''));
%!error(infogettime(infostr, 'A', {'section 1'}));

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
