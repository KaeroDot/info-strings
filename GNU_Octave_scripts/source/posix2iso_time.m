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
                isostring = datetime(posixnumber, 'ConvertFrom', 'posixtime', 'TimeZone', 'local', 'Format', 'yyyy:MM:dd HH:mm:ss.SSSSSSxxxxx');
                isostring = strrep(char(isostring), ' ', 'T');
        endif
endfunction

