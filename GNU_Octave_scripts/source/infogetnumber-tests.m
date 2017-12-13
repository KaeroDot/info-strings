% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: 2\n#startsection:: section 1 \n  C:: 3\n  #startsection:: subsection\n    C:: 4\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: 5\n#endsection:: section 2\n');
%!assert(infogetnumber(infostr,'A') == 1)
%!assert(infogetnumber(infostr,'C') == 2)
%!assert(infogetnumber(infostr,'C', {'section 1'}) == 3)
%!assert(infogetnumber(infostr,'C', {'section 1', 'subsection'}) == 4)
%!assert(infogetnumber(infostr,'C', {'section 2'}) == 5)
%!error(infogetnumber('', ''));
%!error(infogetnumber('', infostr));
%!error(infogetnumber(infostr, ''));
%!error(infogetnumber(infostr, 'A', {'section 1'}));
