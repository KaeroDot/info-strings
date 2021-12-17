function infostr = infoload(filename, varargin)%<<<1
% -- Function File: INFOSTR = infoload (FILENAME)
% -- Function File: INFOSTR = infoload (FILENAME, AUTOEXTENSION)
%     Opens file with info string 'FILENAME.info' and loads its content
%     as text.  Extension '.info' is added automatically if missing, this
%     can be prevented by setting AUTOEXTENSION to zero.
%
%     Script always converts possible Windows line endings (CRLF) to LF,
%     so infostr always contains LF line endings.  When saving using
%     infosve, OS dependent line ending is used.
%
%     Example:
%          infostr = infoload('test_file')
%          infostr = infoload('test_file_with_other_extension.txt', 0)

% Copyright (C) 2021 Martin Šíra %<<<1
%

% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2014
% Version: 6.0
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: no
%   Checks inputs: yes
%   Contains tests: no
%   Contains demo: no
%   Optimized: N/A

        % input possibilities:
        %       filename
        %       filename, autoextension

        % check inputs %<<<2
        if ~(nargin==1 || nargin==2)
                print_usage()
        end
        if nargin == 1
                autoextension = 1;
        else
                autoextension = varargin{1};
        end
        if (~ischar(filename))
                error('infoload: filename must be string')
        end

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
                        end
                end
        end
        % check if file exist:
        if ~exist(filename, 'file')
                error(['infoload: file `' filename '` not found'])
        end

        % read file %<<<2
        fid = fopen(filename, 'r');
        if fid == -1
                error(['infoload: error opening file `' filename '`'])
        end
        [infostr,count] = fread(fid, [1,inf], 'uint8=>char');  % s will be a character array, count has the number of bytes
        % convert possible CRLF line endings to LF, so inside Octave/Matlab all strings are LF only:
        infostr = strrep(infostr, [char(13) char(10)], char(10));
        fclose(fid);
end

% --------------------------- tests: %<<<1
%!shared fn, cont, cont_expected, fid, is
%! fn = 'tmp.info';
%! cont = ['delete' char(13) char(10) 'this' char(10) 'file'];
%! cont_expected = ['delete' char(10) 'this' char(10) 'file'];
%! fid = fopen(fn, 'w');
%! fprintf(fid, cont);
%! fclose(fid);
%! is = infoload(fn);
%!assert(strcmp(is, cont_expected));
%! is = infoload(fn, 0);
%!assert(strcmp(is, cont_expected));
%! is = infoload(fn(1:end-5));
%!assert(strcmp(is, cont_expected));
%! delete(fn);
%!error(infoload(fn(1:end-5), 0));
%!error(infoload(5));
