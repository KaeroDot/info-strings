% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \n#startmatrix:: time matrix\n  2013-12-11T22:59:30.123456\n  2013-12-11T22:59:35.123456\n#endmatrix:: time matrix\nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(all(all( abs(infogettimematrix(infostr,'time matrix') - [1386799170.12346; 1386799175.12346]) < 6e-6 )))
%!error(infogettimematrix('', ''));
%!error(infogettimematrix('', infostr));
%!error(infogettimematrix(infostr, ''));
%!error(infogettimematrix(infostr, 'A', {'section 1'}));
