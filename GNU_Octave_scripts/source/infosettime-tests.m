% --------------------------- tests: %<<<1
%!shared istxt, iskey, iskeydbl
%! istxt = 'T:: 2013-12-11T22:59:30.123456';
%!assert(strcmp(infosettime('T',1386799170.123456), istxt));
%!error(infosettime('a'))
%!error(infosettime(5, 'a'))
%!error(infosettime('a', 'b'))
%!error(infosettime('a', 'b', 'd'))
%!error(infosettime('a', 'b', {5}))
%!error(infosettime('a', 'b', 5, 'd'))
%!error(infosettime('a', 'b', 5, {5}))
