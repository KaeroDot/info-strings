% --------------------------- tests: %<<<1
%!shared ismat, ismatsec
%! ismat = sprintf('#startmatrix:: mat\n        1; 2; 3\n        4; 5; 6\n#endmatrix:: mat');
%! ismatsec = sprintf('#startsection:: skey\n        #startmatrix:: mat\n                1; 2; 3\n                4; 5; 6\n        #endmatrix:: mat\n#endsection:: skey');
%!assert(strcmp(infosetmatrix( 'mat', [1:3; 4:6]                          ), ismat));
%!assert(strcmp(infosetmatrix( 'mat', [1:3; 4:6], {'skey'}                ), ismatsec));
%!assert(strcmp(infosetmatrix( 'testtext', 'mat', [1:3; 4:6], {'skey'}     ), ['testtext' sprintf('\n') ismatsec]));
%!error(infosetmatrix('a'))
%!error(infosetmatrix(5, 'a'))
%!error(infosetmatrix('a', 'b'))
%!error(infosetmatrix('a', 5, 'd'))
%!error(infosetmatrix('a', 5, {5}))
%!error(infosetmatrix('a', 'b', 5, 'd'))
%!error(infosetmatrix('a', 'b', 5, {5}))
