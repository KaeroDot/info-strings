function isostring = posix2iso_time(posixnumber)
        % posix time to ISO8601 time both for GNU Octave and Matlab
        % posix time is number of seconds since the epoch, the epoch is referenced to 00:00:00 CUT
        % (Coordinated Universal Time) 1 Jan 1970, for example, on Monday February 17, 1997 at 07:15:06 CUT,
        % the value returned by 'time' was 856163706.)
        % ISO 8601
        % %Y-%m-%dT%H:%M:%S%20u
        % 2013-12-11T22:59:30.15648946

        if isOctave
                % Octave version:
                isostring = strftime('%Y-%m-%dT%H:%M:%S', localtime(posixnumber));
                % add decimal dot and microseconds:
                isostring = [isostring '.' num2str(localtime(posixnumber).usec, '%0.6d')];
        else
                % Matlab version:
                isostring = datestr(datetime(posixnumber, 'TimeZone', 'local', 'ConvertFrom', 'posixtime'), 'yyyy-mm-ddTHH:MM:SS');
                % add decimal dot and microseconds:
                isostring = [isostring '.' num2str(mod(posixnumber, 1), '%0.6d')];
        endif
endfunction

