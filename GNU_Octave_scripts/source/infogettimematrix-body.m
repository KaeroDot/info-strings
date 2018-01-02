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
                        tmatrix(i, j) = iso2posix_time(strtrim(smat{i, j}));
                endfor
        endfor
endfunction

