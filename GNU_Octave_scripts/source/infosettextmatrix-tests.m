% --------------------------- tests: %<<<1
%!shared ismat, ismatsec
%! ismat = sprintf('#startmatrix:: mat\n        "a"; "b"; "c"\n        "d"; "e"; "f"\n#endmatrix:: mat');
%! ismatsec = sprintf('#startsection:: skey\n        #startmatrix:: mat\n                "a"; "b"; "c"\n                "d"; "e"; "f"\n        #endmatrix:: mat\n#endsection:: skey');
%!assert(strcmp(infosettextmatrix( 'mat', {"a", "b", "c"; "d", "e", "f"}                ), ismat));
%!assert(strcmp(infosettextmatrix( 'mat', {"a", "b", "c"; "d", "e", "f"}, {'skey'}      ), ismatsec));
%!assert(strcmp(infosettextmatrix( 'testtext', 'mat', {"a", "b", "c"; "d", "e", "f"}, {'skey'}     ), ['testtext' sprintf('\n') ismatsec]));
%!error(infosettextmatrix('a'))
%!error(infosettextmatrix({'a'}, 'a'))
%!error(infosettextmatrix('a', 'b'))
%!error(infosettextmatrix('a', {'a'}, 'd'))
%!error(infosettextmatrix('a', {'a'}, {5}))
%!error(infosettextmatrix('a', 'b', {'a'}, 'd'))
%!error(infosettextmatrix('a', 'b', {'a'}, {5}))
