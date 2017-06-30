## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosettime (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettime (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosettime (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettime (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with key @var{key} and time @var{val} in following format:
## @example
## key:: %Y-%m-%dT%H:%M:%S.SSSSSS
##
## @end example
##
## The time is formatted as local time according ISO 8601 with six digits in microseconds.
## Expected input time system is a number of seconds since the epoch, as in
## function time().
##
## If @var{scell} is set, the key/value is enclosed by section(s) according @var{scell}.
##
## If @var{infostr} is set, the key/value is put into existing @var{infostr} 
## sections, or sections are generated if needed and properly appended/inserted 
## into @var{infostr}.
##
## Example:
## @example
## infosettime('time of start',time())
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 2.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function infostr = infosettime(varargin) %<<<1
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
        endif
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
                endif
        endif
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key))
                error('infosettime: infostr and key must be strings')
        endif
        if (~isscalar(val) || ~isnumeric(val))
                error('infosettime: val must be a numeric scalar')
        endif
        if (~iscell(scell))
                error('infosettime: scell must be a cell')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infosettime: scell must be a cell of strings')
        endif

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
                endif
                infostr = [before newline];
        else
                infostr = infosetsection(infostr, newline, scell);
        endif
endfunction

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
