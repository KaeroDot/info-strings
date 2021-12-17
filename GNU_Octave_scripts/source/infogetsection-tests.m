% --------------------------- tests: %<<<1
%!shared infostr, section1, section2, section1subsection, indx
%!assert(strcmp(infogetsection("#startsection::A\n#endsection::A", 'A'), ''))
%!assert(strcmp(infogetsection("#startsection::A\n1\n#endsection::A", 'A'), '1'))
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%! section1 = sprintf('C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection');
%! section2 = sprintf('C:: c in section 2');
%! section1subsection = sprintf('C:: c in subsection');
%!assert(strcmp(infogetsection(infostr, 'section 1'), section1))
%! [tmp, indx] = infogetsection(infostr, 'section 1');
%!assert(indx == 283) %XXX asi chyba? 284 je s \n, 283 bez \n
%!assert(strcmp(infogetsection(infostr, 'section 2'), section2))
%!assert(strcmp(infogetsection(infostr, 'subsection', {'section 1'}), section1subsection))
%!assert(strcmp(infogetsection(infostr, {'section 1', 'subsection'}), section1subsection))
%!error(infogetsection(infostr, 'section 3'))
%!error(infogetsection(infostr, 'section 1', {'section 2'}))
%!error(infogetsection(infostr, 'section 2', {'section 1'}))
%!error(infogetsection(infostr, {'section 1', 'section 2'}))
%!error(infogetsection(infostr, 'section 3', {'section 1'}))
