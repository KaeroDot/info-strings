function tmatrix = infogettimematrix(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettimematrix', varargin{:});
        if printusage
                print_usage()
        endif

        % get matrix %<<<2
        infostr = get_matrix('infogetmatrix', infostr, key, scell);
        % parse csv:
        smat = csv2cell(infostr);

        % convert to time data:
        for i = 1:size(smat, 1)
                for j = 1:size(smat, 2)
                        s = strtrim(smat{i, j});
                        tmatrix(i, j) = mktime(strptime(s, '%Y-%m-%dT%H:%M:%S'));
                        if ~isempty(tmatrix(i, j))
                                % I do not know how to read fractions of second by strptime, so this line fix it:
                                tmatrix(i, j) = tmatrix(i,j) + str2num(s(20:end));
                        endif
                        % ISO 8601
                        % %Y-%m-%dT%H:%M:%S%20u
                        % 2013-12-11T22:59:30.15648946
                endfor
        endfor
endfunction

