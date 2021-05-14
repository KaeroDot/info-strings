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

