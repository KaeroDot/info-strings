% --------------------------- tests: %<<<1
%!shared infostr, ts, tzoffset
%               Basic tests
%! ts = 'A:: 1970-01-01T00:00:00+00:00';
%!assert(infogettime(ts, 'A') == 0);
%! ts = 'A:: 1970-01-01T00:00:00.0000000001+00:00';
%!assert(infogettime(ts, 'A') == 0 + 1e-10);
%! ts = 'A:: 1970-01-01T00:01:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 60 + 1e-6);
%! ts = 'A:: 1970-01-01T01:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 3600 + 1e-6);
%! ts = 'A:: 1970-01-02T00:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 86400 + 1e-6);
%! ts = 'A:: 1970-02-01T00:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 31*86400 + 1e-6);
%! ts = 'A:: 1971-01-01T00:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 365*86400 + 1e-6);
%               Time zones
%! ts = 'A:: 1970-01-01T02:00:00.000001+00:00';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%! ts = 'A:: 1970-01-01T02:30:00.000001+00:30';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%! ts = 'A:: 1970-01-01T01:30:00.000001-00:30';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%! ts = 'A:: 1970-01-01T03:30:00.000001+01:30';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%! ts = 'A:: 1970-01-01T00:30:00.000001-01:30';
%!assert(infogettime(ts, 'A') == 2*3600 + 1e-6);
%               Local time
%! ts = 'A:: 1970-01-01T00:00:00.000001';
%! tzoffset = localtime(now).gmtoff;
%!assert(infogettime(ts, 'A') == -1*tzoffset + 1e-6);
%               Arbitrary time
%! ts = 'A:: 2011-12-13T14:15:16.17+00:00';
%!assert(infogettime(ts, 'A') == 1323785716.17)
%               Test in infostring:
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nT:: 2013-12-11T22:59:30.123456+01:00\nC:: 2\n#startsection:: section 1 \n  C:: 3\n  #startsection:: subsection\n    C:: 4\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: 5\n#endsection:: section 2\n');
%!assert(infogettime(infostr,'T') == 1386799170.123456)
%!error(infogettime('', ''));
%!error(infogettime('', infostr));
%!error(infogettime(infostr, ''));
%!error(infogettime(infostr, 'A', {'section 1'}));
