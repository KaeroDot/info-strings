% --------------------------- tests: %<<<1
%!shared fn, cont, fid, is
%! fn = 'tmp.info';
%! cont = 'delete this file';
%! fid = fopen(fn, 'w');
%! fprintf(fid, cont);
%! fclose(fid);
%! is = infoload(fn);
%!assert(strcmp(is, cont));
%! is = infoload(fn, 0);
%!assert(strcmp(is, cont));
%! is = infoload(fn(1:end-5));
%!assert(strcmp(is, cont));
%! delete(fn);
%!error(infoload(fn(1:end-5), 0));
%!error(infoload(5));
