% --------------------------- tests: %<<<1
%!shared infostr
%!assert(strcmp(infogettext("A::1\nB::2",'A'),'1'))
%!assert(strcmp(infogettext("A::1\nB::2",'B'),'2'))
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(strcmp(infogettext(infostr,'A'),'1'))
%!assert(strcmp(infogettext(infostr,'B([V?*.])'),'!$^&*()[];::,.'));
%!assert(strcmp(infogettext(infostr,'C'),'c without section'))
%!assert(strcmp(infogettext(infostr,'C', {'section 1'}),'c in section 1'))
%!assert(strcmp(infogettext(infostr,'C', {'section 1', 'subsection'}),'c in subsection'))
%!assert(strcmp(infogettext(infostr,'C', {'section 2'}),'c in section 2'))
%!error(infogettext('', ''));
%!error(infogettext('', infostr));
%!error(infogettext(infostr, ''));
%!error(infogettext(infostr, 'A', {'section 1'}));



% NOVY TESTOVACI INFOSTR:
% 
% infostr = "A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n"


% A:: 1
% some note
% B([V?*.])::    !$^&*()[];::,.
% #startmatrix:: simple matrix 
% 1;  2; 3; 
% 4;5;         6;  
% #endmatrix:: simple matrix 
% C:: c without section
% #startsection:: section 1 
  % C:: c in section 1 
  % #startsection:: subsection
    % C:: c in subsection
  % #endsection:: subsection
% #endsection:: section 1
% #startsection:: section 2
  % C:: c in section 2
% #endsection:: section 2
