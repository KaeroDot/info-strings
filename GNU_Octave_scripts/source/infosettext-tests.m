% --------------------------- tests: %<<<1
%!shared istxt, iskey, iskeydbl
%! istxt = 'key:: val';
%! iskey = sprintf('#startsection:: skey\n        key:: val\n#endsection:: skey');
%! iskeydbl = sprintf('#startsection:: skey\n        key:: val\n        key:: val\n#endsection:: skey');
%!assert(strcmp(infosettext( 'key', 'val'                               ), istxt));
%!assert(strcmp(infosettext( 'key', 'val', {'skey'}                     ), iskey));
%!assert(strcmp(infosettext( iskey, 'key', 'val'                        ), [iskey sprintf('\n') istxt]));
%!assert(strcmp(infosettext( iskey, 'key', 'val', {'skey'}              ), iskeydbl));
%!error(infosettext('a'))
%!error(infosettext(5, 'a'))
%!error(infosettext('a', 5))
%!error(infosettext('a', 'b', 5))
%!error(infosettext('a', 'b', {5}))
%!error(infosettext('a', 'b', 'c', 'd'))
%!error(infosettext('a', 'b', 'c', {5}))
