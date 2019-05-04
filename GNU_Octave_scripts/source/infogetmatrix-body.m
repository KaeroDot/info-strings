function matrix = infogetmatrix(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell, is_parsed] = get_id_check_inputs('infogetmatrix', varargin{:});
        if printusage
                print_usage()
        endif

        % get matrix %<<<2
        infostr = get_matrix('infogetmatrix', infostr, key, scell);
        % parse csv:
        if isempty(infostr)
                % if matrix is empty, csv2cell would fail. e.g. #startmatrix::A\n#endmatrix::A
                matrix = [];
        else
                matrix = csv2cell(infostr);
                % convert to numbers:
                % uniformoutput=false not needed, because str2double() never fails, it just returns NaN
                matrix = cellfun(@str2double, matrix);
        endif
endfunction

