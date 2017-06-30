## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosetnumber (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetnumber (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosetnumber (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosetnumber (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with key @var{key} and number @var{val} in following format:
## @example
## key:: val
##
## @end example
## If @var{scell} is set, the key/value is enclosed by section(s) according @var{scell}.
##
## If @var{infostr} is set, the key/value is put into existing @var{infostr} 
## sections, or sections are generated if needed and properly appended/inserted 
## into @var{infostr}.
##
## Example:
## @example
## infosetnumber('key', 1)
## infostr = infosetnumber('key', 1, @{'section key', 'subsection key'@})
## infosetnumber(infostr, 'other key', 5, @{'section key', 'subsection key'@})
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

function infostr = infosetnumber(varargin) %<<<1
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
                error('infosetnumber: infostr and key must be strings')
        endif
        if (~isscalar(val) || ~isnumeric(val))
                error("infosetnumber: val must be a numeric scalar")
        endif
        if (~iscell(scell))
                error('infosetnumber: scell must be a cell')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infosetnumber: scell must be a cell of strings')
        endif

        % make infostr %<<<2
        % generate new line with key and val:
        newline = sprintf('%s:: %.20G', key, val);
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
%! istxt = 'key:: 5';
%! iskey = sprintf('#startsection:: skey\n        key:: 5\n#endsection:: skey');
%! iskeydbl = sprintf('#startsection:: skey\n        key:: 5\n        key:: 5\n#endsection:: skey');
%!assert(strcmp(infosetnumber( 'key', 5                                   ), istxt));
%!assert(strcmp(infosetnumber( 'key', 5, {'skey'}                         ), iskey));
%!assert(strcmp(infosetnumber( iskey, 'key', 5                            ), [iskey sprintf('\n') istxt]));
%!assert(strcmp(infosetnumber( iskey, 'key', 5, {'skey'}                  ), iskeydbl));
%!error(infosetnumber('a'))
%!error(infosetnumber(5, 'a'))
%!error(infosetnumber('a', 'b'))
%!error(infosetnumber('a', 5, 'd'))
%!error(infosetnumber('a', 5, {5}))
%!error(infosetnumber('a', 'b', 5, 'd'))
%!error(infosetnumber('a', 'b', 5, {5}))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
