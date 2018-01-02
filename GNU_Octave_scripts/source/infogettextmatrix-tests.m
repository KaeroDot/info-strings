% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"   ; "c" \n"d";"e";         "f"    \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n#startmatrix:: simple matrix \n"b";  "c"; "d" \n"e";"f";         "g"  \n#endmatrix:: simple matrix \n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(all(all(strcmp( infogettextmatrix(infostr,'simple matrix'), {'a' 'b' 'c'; 'd' 'e' 'f'} ))))
%!assert(all(all(strcmp( infogettextmatrix(infostr,'simple matrix', {'section 1', 'subsection'}), {'b' 'c' 'd'; 'e' 'f' 'g'} ))))
%!error(infogettextmatrix('', ''));
%!error(infogettextmatrix('', infostr));
%!error(infogettextmatrix(infostr, ''));
%!error(infogettextmatrix(infostr, 'A', {'section 1'}));
