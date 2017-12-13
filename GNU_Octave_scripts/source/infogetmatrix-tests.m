% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2   ; 3 \n4;5;         6    \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n#startmatrix:: simple matrix \n2;  3; 4 \n5;6;         7  \n#endmatrix:: simple matrix \n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(all(all( infogetmatrix(infostr,'simple matrix') == [1 2 3; 4 5 6] )))
%!assert(all(all( infogetmatrix(infostr,'simple matrix', {'section 1', 'subsection'}) == [2 3 4; 5 6 7] )))
%!error(infogetmatrix('', ''));
%!error(infogetmatrix('', infostr));
%!error(infogetmatrix(infostr, ''));
%!error(infogetmatrix(infostr, 'A', {'section 1'}));
