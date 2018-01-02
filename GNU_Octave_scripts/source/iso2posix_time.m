function posixnumber = iso2posix_time(isostring)
        % converts ISO8601 time to posix time both for GNU Octave and Matlab
        % posix time is number of seconds since the epoch, the epoch is referenced to 00:00:00 CUT
        % (Coordinated Universal Time) 1 Jan 1970, for example, on Monday February 17, 1997 at 07:15:06 CUT,
        % the value returned by 'time' was 856163706.)
        % ISO 8601
        % %Y-%m-%dT%H:%M:%S%20u
        % 2013-12-11T22:59:30.15648946

        isostring = strtrim(isostring);
        if isOctave
                % Octave version:
                % parse of time data:
                posixnumber = mktime(strptime(isostring, '%Y-%m-%dT%H:%M:%S'));
                if ~isempty(posixnumber)
                        % I do not know how to read fractions of second by strptime, so this line fix it:
                        posixnumber = posixnumber + str2num(isostring(20:end));
                endif
        else
                % Matlab version:
                posixnumber = posixtime(datetime(isostring(1:19), 'TimeZone', 'local', 'Format', 'yyyy-MM-dd''T''HH:mm:ss'));
                % I do not know how to read fractions of second by datetime, so this line fix it:
                posixnumber = posixnumber + str2num(isostring(20:end));
        endif
endfunction

