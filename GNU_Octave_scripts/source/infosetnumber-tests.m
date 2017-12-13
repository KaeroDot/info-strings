% --------------------------- tests: %<<<1
%!shared istxt, iskey, iskeydbl
%! istxt = 'key:: 5';
%! iskey = sprintf('#startsection:: skey\n        key:: 5\n#endsection:: skey');
%! iskeydbl = sprintf('#startsection:: skey\n        key:: 5\n        key:: 5\n#endsection:: skey');
%!assert(strcmp(infosetnumber( 'key', 5                                   ), istxt));
%!assert(strcmp(infosetnumber( 'key', 5, {'skey'}                         ), iskey));
%!assert(strcmp(infosetnumber( iskey, 'key', 5                            ), [iskey sprintf('\n') istxt]));
%!assert(strcmp(infosetnumber( iskey, 'key', 5, {'skey'}                  ), iskeydbl));
%!error(infosetnumber('a'))
%!error(infosetnumber(5, 'a'))
%!error(infosetnumber('a', 'b'))
%!error(infosetnumber('a', 5, 'd'))
%!error(infosetnumber('a', 5, {5}))
%!error(infosetnumber('a', 'b', 5, 'd'))
%!error(infosetnumber('a', 'b', 5, {5}))
