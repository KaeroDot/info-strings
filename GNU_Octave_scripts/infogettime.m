## Copyright (C) 2021 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettime (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettime (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds line with content "key:: value" and returns 
## the value as number of seconds since the epoch (as in function time()). Expected time format 
## is extended ISO 8601:
## @example
## YYYY-mm-DDTHH:MM:SS[.nS][Z|(+|-)HH:MM]
## @end example
## The number of digits in fraction of seconds
## is not limited, however in GNU Octave the best precision is in microseonds, Matlab can cope 
## with nanoseconds.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
## infostr = sprintf('T:: 2011-12-13T14:15:16.123456+00:00')
## infogettime(infostr,'T')
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2013
## Version: 5.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function time = infogettime(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettime', varargin{:});
        if printusage
                print_usage()
        endif

        % get time %<<<2
        % get time as text:
        s = get_key('infogettime', infostr, key, scell);
        % parse of time data:
        time = iso2posix_time(s);
        if isempty(time)
                error(['infogettime: key `' key '` does not contain time data'])
        endif
endfunction

function [printusage, infostr, key, scell, is_parsed] = get_id_check_inputs(functionname, varargin) %<<<1
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

        % input is parsed info string? 
        is_parsed = isstruct(infostr) && isfield(infostr,'this_is_infostring');

        % check values of inputs infostr, key, scell %<<<2
        if ~ischar(infostr) && ~is_parsed
                error([functionname ': infostr must be either string or structure generated by infoparse()'])
        endif
        if ~ischar(key) || isempty(key)
                error([functionname ': key must be non-empty string'])
        endif
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        endif
        if length(scell) == 1 && isempty(scell{1})
                % atomatically generated values of cells are often [], not '', but still the cell is
                % empty, e.g.: 
                %       clear scell; scell{2} = 'sectionB'
                % than scell{1} is [].
                % so to remove user need to bother with this, if the scell contains single empty
                % value, it is automatically replaced by empty string.
                scell = {};
        elseif (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        endif
endfunction

function [section, endposition] = get_section(functionname, infostr, scell) %<<<1
        % finds content of a section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data (raw string or parsed struct)
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % recoursive section search:
                for s = 1:numel(scell)
                
                        % look for subsection:
                        sid = find(strcmp(infostr.sec_names,scell{s}),1);
                        if isempty(sid)
                                error(sprintf('%s: subsection ''%s'' not found',functionname,scell{s}));
                        endif
                        
                        % go deeper:
                        infostr = infostr.sections{sid};
                endfor
                
                % assing result
                section = infostr;

                endposition = 0; % matlab default
                
        else
                % --- RAW INFO-STRING ---                
                section = '';
                sectionfound = 0;
                endposition = 0;
                if isempty(scell)
                        % scell is empty thus current infostr is required:
                        section = infostr;
                        sectionfound = 1;
                else
                        while (~isempty(infostr))
                                % Search sections one by one from start of infostr to end.
                                % This searching of sections one by one is 2-3 times faster than a
                                % regular expression matching all sections.
                                [S, E, TE, M, T, NM] = regexpi(infostr, make_regexp('', 'anysection'), 'once');
                                if isempty(T)
                                        % no section found
                                        section = '';
                                        break
                                else
                                        % some section found
                                        if strcmp(strtrim(T{1}), scell{1})
                                                % wanted section found
                                                if length(T) > 1
                                                        section = strtrim(T{2});
                                                else
                                                        % section was found, but content was empty
                                                        section = '';
                                                endif
                                                sectionfound = 1;
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
                        if not(sectionfound)
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
        endif        
endfunction

function [infostr] = rem_subsections(functionname, infostr) %<<<1
        % remove all other sections in infostr
        % used to prevent finding key or matrix inside of some section
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        %
        % function suppose all inputs are ok!

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        
        if ~isstruct(infostr)
                % --- only in raw text mode, ignore for parsed infostring ---
                NL = sprintf('\n');

                % remove unwanted sections:
                while (~isempty(infostr))
                        % search sections one by one from start of infostr to end
                        [S, E, TE, M, T, NM] = regexpi(infostr, make_regexp('', 'anysection'), 'once');
                        if isempty(T)
                                % no section found, quit:
                                break
                        else
                                % some section found, remove it from infostr:
                                infostr = [deblank(infostr(1:S-1)) NL fliplr(deblank(fliplr(infostr(E+1:end))))];
                                if S-1 >= E+1
                                        % danger of infinite loop! this should never happen
                                        error([functionname ': infinite loop happened!'])
                                endif
                        endif
                endwhile
        endif
endfunction

function [val] = get_key(functionname, infostr, key, scell) %<<<1
        % returns value of key as text from infostr in section/subsections according scell
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - name of key for which val is searched
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        val = '';
        % get section:
        [infostr] = get_section(functionname, infostr, scell);
        % remove unwanted subsections:
        [infostr] = rem_subsections(functionname, infostr);

        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % look for scalar item:
                sid = find(strcmp(infostr.scalar_names,key));
                if isempty(sid)
                        error(sprintf('%s: key ''%s'' not found',functionname,key));
                endif
                
                if numel(sid) > 1
                        error(sprintf('%s: key ''%s'' found multiple times',functionname,key));
                endif
                
                % return item:
                val = infostr.scalars{sid};

        else
                % --- RAW INFO-STRING ---                

                % find key:
                [S, E, TE, M, T, NM] = regexpi (infostr, make_regexp(key, 'linekey'), 'once');
                % return key if found:
                if isempty(T)
                        error([functionname ': key `' key '` not found'])
                else
                        if isscalar(T)
                                val = strtrim(T{1});
                        else
                                error([functionname ': key `' key '` found on multiple places'])
                        endif
                endif
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

function expr = make_regexp(key, type)
        % returns proper regular expression for line key, matrix and section.
        % this function is mainly to have all regular expressions at one place to increase
        % readability of the whole library.

        % GNU Octave and LabVIEW use PCRE (Pearl Compatible Regular Expressions), however Matlab
        % seems to have it's own regular expression flavor (unfortunately).

        % Matlab issues:
        % 1,
        % https://www.mathworks.com/help/matlab/ref/regexp.html#btn_p45_sep_shared-expression
                % WARNING!
                % If an expression has nested parentheses, MATLAB captures tokens that correspond
                % to the outermost set of parentheses. For example, given the search pattern
                % '(and(y|rew))', MATLAB creates a token for 'andrew' but not for 'y' or 'rew'.
        % so for Octave one can keep proper non matching group (?:), but not for Matlab.
        % 2,
        % For Matlab, \h has to be replaced by \s. But \s matches also newlines contrary to \h


        %remove leading spaces of key and escape characters:
        key = regexpescape(strtrim(key));

        % (?m) is regexp flag causing that ^ and $ match start and end of line, however $ do not match end of file

        if strcmpi(type, 'linekey')
                if isOctave
                        % SOL SP key SP :: content without EOL
                        % (?-s) is regexp flag causing that . do not match end of line
                        expr = ['(?m-s)^\h*' key '\h*::(.*)'];
                        % results: Token 1: content of key
                else
                        % \h has to be replaced by \s. But \s matches also newlines contrary to \h
                        expr = ['(?m-s)^\s*' key '\s*::(.*)'];
                endif
        elseif strcmpi(type, 'matrix')
                if isOctave
                        % SOL SP startmatrix SP :: SP key SP ( NL content NL OR NL ) SP endmatrix SP :: SP key SP EOL
                        % This is NOT greedy, i.e. finds first occurance of endmatrix.
                        expr = ['(?m)^\h*#startmatrix\h*::\h*' key '\h*(?:\n(.*?)\n|\n)^\h*#endmatrix\h*::\h*' key '\h*$'];
                        % results: Token 1: content of section OR token does not exist
                else
                        % \h has to be replaced by \s. But \s matches also newlines contrary to \h
                        expr = ['(?m)^\s*#startmatrix\s*::\s*' key '\s*(\n(.*?)\n|\n)^\s*#endmatrix\s*::\s*' key '\s*$'];
                endif
        elseif strcmpi(type, 'section')
                if isOctave
                        % SOL SP startsection SP :: SP key SP ( NL content NL OR NL ) SP endsection SP :: SP key SP EOL
                        expr = ['(?ms)^\h*#startsection\h*::\h*' key '\h*(?:\n(.*)\n|\n)^\h*#endsection\h*::\h*' key '\h*$'];
                        % results: Token 1: content of section OR token does not exist
                else
                        % \h has to be replaced by \s. But \s matches also newlines contrary to \h
                        expr = ['(?ms)^\s*#startsection\s*::\s*' key '\s*(\n(.*)\n|\n)^\s*#endsection\s*::\s*' key '\s*$'];
                endif
        elseif strcmpi(type, 'anysection')
                if isOctave
                        % SOL SP startsection SP :: SP key SP ( NL content NL OR NL ) SP endsection SP :: SP key SP EOL
                        % This is greedy, i.e. finds last occurance of endsection.
                        % For match of section key, instead of .*, that means any even line break
                        % (because of flag (?s), there is [^\n], that means any except line break,
                        % because section key cannot be across line breaks.
                        expr = ['(?ms)^\h*#startsection\h*::\h*([^\n]*)\h*(?:\n(.*)\n|\n)^\h*#endsection\h*::\h*\1\h*$'];
                        % results: Token 1: key
                        % results: Token 2: content of section OR token does not exist
                else
                        % \h has to be replaced by \s. But \s matches also newlines contrary to \h
                        expr = ['(?ms)^\s*#startsection\s*::\s*([^\n]*)\s*(\n(.*)\n|\n)^\s*#endsection\s*::\s*\1\s*$'];
                endif
        else
                error('unknown regular expression type')
        endif
endfunction

function retval = isOctave
% checks if GNU Octave or Matlab
% according https://www.gnu.org/software/octave/doc/v4.0.1/How-to-distinguish-between-Octave-and-Matlab_003f.html

  persistent cacheval;  % speeds up repeated calls

  if isempty (cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
  end

  retval = cacheval;
end

function posixnumber = iso2posix_time(isostring)
        % converts ISO8601 time to posix time both for GNU Octave and Matlab
        % posix time is number of seconds since the epoch, the epoch is referenced to 00:00:00 CUT
        % (Coordinated Universal Time) 1 Jan 1970, for example, on Monday February 17, 1997 at 07:15:06 CUT,
        % the value returned by 'time' was 856163706.)
        % ISO 8601
        % YYYY-mm-DDTHH:MM:SS[.nS][Z|(+|-)HH:MM]
        % 2011-12-13T14:15:16
        % 2011-12-13T14:15:16.123456
        % 2011-12-13T14:15:16.123456Z
        % 2011-12-13T14:15:16.123456+01:00
        % 2011-12-13T14:15:16.123456-01:00
        % 2011-12-13T14:15:16-01:00


        errormsg = 'Incorrect format of time. Please use YYYY-mm-DDTHH:MM:SS[.6S][Z][(+|-)HH:MM]';

        isostring = strtrim(isostring);
        if length(isostring) < 19
                error(errormsg)
        endif
        % get only YYYY-MM-DDTHH:MM:SS part of date, because both matlab and octave has some
        % problems reading lot of decimal places of seconds and timezone properly
        datetimepart = isostring(1:19);
        % base settings - local time, no fractions of seconds, offset irrelevant
        localt = 1;
        secfrac = [];
        offset = 0;
        if length(isostring) > 19
                rest = isostring(20:end);
                % find out if zulu time (GMT):
                idZ = strfind(rest, 'Z');
                if any(idZ)
                        % is zulu time
                        localt = 0;
                        % get fractions of seconds:
                        secfrac = sscanf(rest, '%f');
                else
                        % no zulu time
                        % needs to find if time zone offset is present
                        idOb = strfind(rest, '+');
                        idOa = strfind(rest, '-');
                        idO = min([idOa(:) idOb(:)]);
                        if isempty(idO)
                                % no time zone offset, so it is local time
                                secfrac = sscanf(rest, '%f');
                        else
                                % there is time zone offset
                                localt = 0;
                                if idO > 1
                                        % there is at least one character before time zone
                                        secfrac  = sscanf(rest(1:idO-1), '%f');
                                else
                                        secfrac = [];
                                endif
                                offsetpart = rest(idO:end);
                                mult = 1;
                                if strcmp(offsetpart(1), '-')
                                        mult = -1;
                                endif
                                offset = str2num(offsetpart(2:3))*3600;
                                % check if minutes are present in offset
                                if length(offsetpart) > 3
                                        offset = offset + str2num(offsetpart(5:6))*60;
                                endif
                                offset = offset.*mult;
                        endif
                endif
        endif
        if isempty(secfrac)
                % if sscanf scans nothing, it generates []
                secfrac = 0;
        endif
        if isOctave
                % Octave version:
                % parse of time data:
                t = strptime(isostring, '%Y-%m-%dT%H:%M:%S');
                % mktime do not use .gmtoff and .zone in time structure from strptime, but use
                % environment settings. so it has to be changed temporarily:
                if localt
                        posixnumber = mktime(t);
                else
                        setenv ('TZ', 'UTC0');
                        posixnumber = mktime(t);
                        unsetenv('TZ');
                endif
                % apply possible offset:
                % this line fixes that strptime was not created with proper time zone. convert back
                % to utc:
                posixnumber = posixnumber - offset;
        else
                % Matlab version:
                % this unfortunately requires Matlab 2014 and later
                if localt
                    tz = 'local';
                else
                    tz = '+00:00';
                end
                % As a time zone, matlab do not accept number. so just
                % create in zulu time zone and add offset later
                posixnumber = posixtime(datetime(isostring(1:19), 'TimeZone', tz, 'Format', 'yyyy-MM-dd''T''HH:mm:ss'));
                if ~localt
                    % apply possible offset:
                    % this line fixes that posixnumber was not created with
                    % proper time zone:
                    posixnumber = posixnumber - offset;
                end

        end
        % add fractions of second:
        % I do not know how to read fractions of second by datetime nor strptime in Octave, so this
        % line fix it. (It is possible to do in Matlab using SSSSS)
        posixnumber = posixnumber + secfrac;
endfunction

function isostring = posix2iso_time(posixnumber)
        % posix time to ISO8601 time both for GNU Octave and Matlab
        % posix time is number of seconds since the epoch, the epoch is referenced to 00:00:00 CUT
        % (Coordinated Universal Time) 1 Jan 1970, for example, on Monday February 17, 1997 at 07:15:06 CUT,
        % the value returned by 'time' was 856163706.)
        % ISO 8601
        % YYYY-mm-DDTHH:MM:SS.6S(+|-)HH:MM
        % 2011-12-13T14:15:16
        % 2011-12-13T14:15:16.123456
        % 2011-12-13T14:15:16.123456Z
        % 2011-12-13T14:15:16.123456+01:00
        % 2011-12-13T14:15:16.123456-01:00
        % 2011-12-13T14:15:16-01:00

        if isOctave
                % Octave version:
                isostring = strftime('%Y-%m-%dT%H:%M:%S%z', localtime(posixnumber));
                % add decimal dot and microseconds:
                isostring = [isostring(1:end-5) '.' num2str(localtime(posixnumber).usec, '%0.6d') isostring(end-5:end-2) ':' isostring(end-1:end)];
        else
                % Matlab version:
                isostring = datetime(posixnumber, 'ConvertFrom', 'posixtime', 'TimeZone', 'local', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSSxxxxx');
                isostring = strrep(char(isostring), ' ', 'T');
        endif
endfunction

% --------------------------- tests: %<<<1
%!shared infostr, ts, tzoffset
%               Basic tests
%! ts = 'A:: 1970-01-01T00:00:00+00:00';
%!assert(infogettime(ts, 'A') == 0);
%! ts = 'A:: 1970-01-01T00:00:00.0000000001+00:00';
%!assert(infogettime(ts, 'A') == 0 + 1e-10);
%! ts = 'A:: 1970-01-01T00:01:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 60 + 1e-6);
%! ts = 'A:: 1970-01-01T01:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 3600 + 1e-6);
%! ts = 'A:: 1970-01-02T00:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 86400 + 1e-6);
%! ts = 'A:: 1970-02-01T00:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 31*86400 + 1e-6);
%! ts = 'A:: 1971-01-01T00:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 365*86400 + 1e-6);
%               Time zones
%! ts = 'A:: 1970-01-01T02:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%! ts = 'A:: 1970-01-01T02:30:00.000001+00:30';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%! ts = 'A:: 1970-01-01T01:30:00.000001-00:30';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%! ts = 'A:: 1970-01-01T03:30:00.000001+01:30';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%! ts = 'A:: 1970-01-01T00:30:00.000001-01:30';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%               Local time
%! ts = 'A:: 1970-01-01T00:00:00.000001';
%! tzoffset = localtime(now).gmtoff;
%!assert(infogettime(ts, 'A') == -1*tzoffset + 1e-6);
%               Arbitrary time
%! ts = 'A:: 2011-12-13T14:15:16.17+00:00';
%!assert(infogettime(ts, 'A') == 1323785716.17)
%               Test in infostring:
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nT:: 2013-12-11T22:59:30.123456+01:00\nC:: 2\n#startsection:: section 1 \n  C:: 3\n  #startsection:: subsection\n    C:: 4\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: 5\n#endsection:: section 2\n');
%!assert(infogettime(infostr,'T') == 1386799170.123456)
%!error(infogettime('', ''));
%!error(infogettime('', infostr));
%!error(infogettime(infostr, ''));
%!error(infogettime(infostr, 'A', {'section 1'}));
