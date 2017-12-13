% --------------------------- tests: %<<<1
%!shared fn, fne, cont
%! delete(fn);
%! delete(fne);
%! fn = 'tmp';
%! fne = [fn '.info'];
%! cont = 'delete this file';
%! infosave(cont, fn)
%!assert(exist(fne, 'file'));
%! delete(fne);
%! infosave(cont, fn, 0)
%!assert(exist(fn, 'file'));
%! delete(fn);
%!error(infosave(5));
%!error(infosave(cont, 5));
