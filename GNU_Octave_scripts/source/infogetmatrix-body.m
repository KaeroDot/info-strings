function matrix = infogetmatrix(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogetmatrix', varargin{:});
        if printusage
                print_usage()
        endif

        % get matrix %<<<2
        infostr = get_matrix('infogetmatrix', infostr, key, scell);
        % parse csv:
        matrix = csv2cell(infostr);
        % convert to numbers:
        matrix = cellfun(@str2double, matrix, 'UniformOutput', false);
        matrix = cell2mat(matrix);
endfunction

