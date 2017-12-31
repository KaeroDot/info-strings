% --------------------------- tests: %<<<1
%!shared istxt
%! istxt = sprintf('#startmatrix:: tmat\n        2013-12-11T22:59:30.123456\n        2013-12-11T22:59:30.123456\n#endmatrix:: tmat');
%!assert(strcmp(infosettimematrix('tmat', [1386799170.123456; 1386799170.123456]), istxt));
%!error(infosettimematrix('a'))
%!error(infosettimematrix(5, 'a'))
%!error(infosettimematrix('a', 'b'))
%!error(infosettimematrix('a', 5, 'd'))
%!error(infosettimematrix('a', 5, {5}))
%!error(infosettimematrix('a', 'b', 5, 'd'))
%!error(infosettimematrix('a', 'b', 5, {5}))
