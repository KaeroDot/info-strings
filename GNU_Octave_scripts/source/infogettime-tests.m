% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nT:: 2013-12-11T22:59:30.123456\nC:: 2\n#startsection:: section 1 \n  C:: 3\n  #startsection:: subsection\n    C:: 4\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: 5\n#endsection:: section 2\n');
%!assert(infogettime(infostr,'T') == 1386799170.123456)
%!error(infogettime('', ''));
%!error(infogettime('', infostr));
%!error(infogettime(infostr, ''));
%!error(infogettime(infostr, 'A', {'section 1'}));
