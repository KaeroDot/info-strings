## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} infosave (@var{infostr}, @var{filename})
## @deftypefnx {Function File}  infosave (@var{infostr}, @var{filename}, @var{autoextension})
## @deftypefnx {Function File}  infosave (@var{infostr}, @var{filename}, @var{autoextension}, @var{overwrite})
## Save info string @var{infostr} into file `@var{filename}.info` as text. Extension `.info`
## is added automatically if missing, this can be prevented by setting @var{autoextension}
## to zero. If @var{overwrite} is set, existing file is overwritten.
##
## Example:
## @example
## infosave('key:: val', 'test_file')
## infosave('key:: val', 'test_file_with_other_extension.txt', 0)
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: no
##   Checks inputs: yes
##   Contains tests: no
##   Contains demo: no
##   Optimized: N/A

function succes = infosave(infostr, filename, varargin) %<<<1
        % input possibilities:
        %       infostr, filename
        %       infostr, filename, autoextension
        %       infostr, filename, autoextension, overwrite

        % check inputs %<<<2
        if (nargin<2 || nargin>4)
                print_usage()
        endif
        if nargin == 2
                autoextension = 1;
                overwrite = 0;
        elseif nargin == 3
                autoextension = varargin{1};
                overwrite = 0;
        else
                autoextension = varargin{1};
                overwrite = varargin{2};
        endif
        if (~ischar(filename) || ~ischar(infostr))
                error('infosave: infostr and filename must be strings')
        endif

        % check extension %<<<2
        if autoextension
                % automatic addition of extension required
                if length(filename) < 5
                        % too short filename, therefore extension is definitely missing:
                                filename = [filename '.info'];
                else
                        if ~strcmpi(filename(end-4:end), '.info')
                                % extension .info is missing
                                filename = [filename '.info'];
                        endif
                endif
        endif
        % check if file exist:
        if ~overwrite
                if exist(filename, 'file')
                        error(['infosave: file `' filename '` already exists'])
                endif
        endif

        % write file %<<<2
        fid = fopen (filename, 'w');
        if fid == -1
                error(['infosavefile: error opening file `' filename '`'])
        endif
        fprintf(fid, '%s', infostr);
        fclose(fid);
endfunction

% --------------------------- tests: %<<<1
%!shared fn, fne, cont
%! delete(fn);
%! delete(fne);
%! fn = 'tmp';
%! fne = [fn '.info'];
%! cont = 'delete this file';
%! infosave(cont, fn)
%!assert(exist(fne, 'file'));
%! delete(fne);
%! infosave(cont, fn, 0)
%!assert(exist(fn, 'file'));
%! delete(fn);
%!error(infosave(5));
%!error(infosave(cont, 5));
