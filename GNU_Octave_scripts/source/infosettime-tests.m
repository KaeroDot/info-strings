% --------------------------- tests: %<<<1
%!shared istxt, iskey, iskeydbl
%! setenv ('TZ', 'UTC0');
%! istxt = infosettime('T', 1323785716.17);
%! unsetenv('TZ');
%!assert(strcmp(istxt, 'T:: 2011-12-13T14:15:16.1700006+00:00'));
%!error(infosettime('a'))
%!error(infosettime(5, 'a'))
%!error(infosettime('a', 'b'))
%!error(infosettime('a', 'b', 'd'))
%!error(infosettime('a', 'b', {5}))
%!error(infosettime('a', 'b', 5, 'd'))
%!error(infosettime('a', 'b', 5, {5}))
