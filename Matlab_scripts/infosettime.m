function infostr = infosettime(varargin)%<<<1
% -- Function File: INFOSTR = infosettime (KEY, VAL)
% -- Function File: INFOSTR = infosettime (KEY, VAL, SCELL)
% -- Function File: INFOSTR = infosettime (INFOSTR, KEY, VAL)
% -- Function File: INFOSTR = infosettime (INFOSTR, KEY, VAL, SCELL)
%     Returns info string with key KEY and time VAL in following format:
%          key:: %Y-%m-%dT%H:%M:%S.SSSSSS
%
%
%     The time is formatted as local time according ISO 8601 with six
%     digits in microseconds.  Expected input time system is a number of
%     seconds since the epoch, as in function time().
%
%     If SCELL is set, the key/value is enclosed by section(s) according
%     SCELL.
%
%     If INFOSTR is set, the key/value is put into existing INFOSTR
%     sections, or sections are generated if needed and properly
%     appended/inserted into INFOSTR.
%
%     Example:
%          infosettime('time of start',time())

% Copyright (C) 2014 Martin Šíra %<<<1
%

% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2014
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
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % check inputs %<<<2
        if (nargin < 2 || nargin > 4)
                print_usage()
        end
        % identify inputs
        if nargin == 4
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        elseif nargin == 2;
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
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key))
                error('infosettime: infostr and key must be strings')
        end
        if (~isscalar(val) || ~isnumeric(val))
                error('infosettime: val must be a numeric scalar')
        end
        if (~iscell(scell))
                error('infosettime: scell must be a cell')
        end
        if (~all(cellfun(@ischar, scell)))
                error('infosettime: scell must be a cell of strings')
        end

        % make infostr %<<<2
        % format time:
        newline = strftime('%Y-%m-%dT%H:%M:%S',localtime(val));
        % add decimal dot and microseconds:
        newline = [newline '.' num2str(localtime(val).usec, '%0.6d')];
        % generate new line with key and val:
        newline = sprintf('%s:: %s', key, newline);
        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                end
                infostr = [before newline];
        else
                infostr = infosetsection(infostr, newline, scell);
        end
end

% --------------------------- tests: %<<<1
%!shared istxt, iskey, iskeydbl
%! istxt = 'T:: 2013-12-11T22:59:30.123456';
%!assert(strcmp(infosettime('T',1386799170.123456), istxt));
%!error(infosettime('a'))
%!error(infosettime(5, 'a'))
%!error(infosettime('a', 'b'))
%!error(infosettime('a', 'b', 'd'))
%!error(infosettime('a', 'b', {5}))
%!error(infosettime('a', 'b', 5, 'd'))
%!error(infosettime('a', 'b', 5, {5}))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
