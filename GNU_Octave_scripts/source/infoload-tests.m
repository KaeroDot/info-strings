% --------------------------- tests: %<<<1
%!shared fn, cont, cont_expected, fid, is
%! fn = 'tmp.info';
%! cont = ['delete' char(13) char(10) 'this' char(10) 'file'];
%! cont_expected = ['delete' char(10) 'this' char(10) 'file'];
%! fid = fopen(fn, 'w');
%! fprintf(fid, cont);
%! fclose(fid);
%! is = infoload(fn);
%!assert(strcmp(is, cont_expected));
%! is = infoload(fn, 0);
%!assert(strcmp(is, cont_expected));
%! is = infoload(fn(1:end-5));
%!assert(strcmp(is, cont_expected));
%! delete(fn);
%!error(infoload(fn(1:end-5), 0));
%!error(infoload(5));
