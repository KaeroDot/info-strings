function expr = make_regexp(key, type)
        % returns proper regular expression for line key, matrix and section.
        % this function is mainly to have all regular expressions at one place to increase
        % readability of the whole library.

        %remove leading spaces of key and escape characters:
        key = regexpescape(strtrim(key));

        % (?m) is regexp flag causing that ^ and $ match start and end of line, however $ do not match end of file

        if strcmpi(type, 'linekey')
                % SOL SP key SP :: content without EOL
                % (?-s) is regexp flag causing that . do not match end of line
                expr = ['(?m-s)^\h*' key '\h*::(.*)'];
                % results: Token 1: content of key
        elseif strcmpi(type, 'matrix')
                % SOL SP startmatrix SP :: SP key SP ( NL content NL OR NL ) SP endmatrix SP :: SP key SP EOL
                % This is NOT greedy, i.e. finds first occurance of endmatrix.
                expr = ['(?m)^\h*#startmatrix\h*::\h*' key '\h*(?:\n(.*?)\n|\n)^\h*#endmatrix\h*::\h*' key '\h*$'];
                % results: Token 1: content of section OR token does not exist
        elseif strcmpi(type, 'section')
                % SOL SP startsection SP :: SP key SP ( NL content NL OR NL ) SP endsection SP :: SP key SP EOL
                expr = ['(?ms)^\h*#startsection\h*::\h*' key '\h*(?:\n(.*)\n|\n)^\h*#endsection\h*::\h*' key '\h*$'];
                % results: Token 1: content of section OR token does not exist
        elseif strcmpi(type, 'anysection')
                % SOL SP startsection SP :: SP key SP ( NL content NL OR NL ) SP endsection SP :: SP key SP EOL
                % This is greedy, i.e. finds last occurance of endsection.
                expr = ['(?ms)^\h*#startsection\h*::\h*(.*)\h*(?:\n(.*)\n|\n)^\h*#endsection\h*::\h*\1\h*$'];
                % results: Token 1: key
                % results: Token 2: content of section OR token does not exist
        else
                error('unknown regular expression type')
        endif
endfunction

