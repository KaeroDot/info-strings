% --------------------------- tests: %<<<1
%!shared istxt
%! istxt = sprintf('#startmatrix:: tmat\n        2011-12-13T14:15:16.1700006+00:00\n        2011-12-13T14:15:16.1700006+00:00\n#endmatrix:: tmat');
%! setenv ('TZ', 'UTC0');
%!assert(strcmp(infosettimematrix('tmat', [1323785716.17; 1323785716.17]), istxt));
%! unsetenv('TZ');
%!error(infosettimematrix('a'))
%!error(infosettimematrix(5, 'a'))
%!error(infosettimematrix('a', 'b'))
%!error(infosettimematrix('a', 5, 'd'))
%!error(infosettimematrix('a', 5, {5}))
%!error(infosettimematrix('a', 'b', 5, 'd'))
%!error(infosettimematrix('a', 'b', 5, {5}))
