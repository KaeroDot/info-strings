% tests: %<<<2
%!shared s,m,res,s_s,s_ff,s_fs1,s_fs2,m_s,m_fs1,m_fs2
% % test matrix with all quirks of quotes and newlines according RFC:
%! s = [' aaa1   ;  bbb1    ;  ccc1' char(10) ' aaa2   ; " bbb2 " ;  ccc2 ' char(10) '" aaa3 ";  bbb3 ; " ccc3 "' char(10) '"aaa4"  ; "b""bb4" ; "ccc4"' char(10) '"aaa5"  ; "bb;b5"  ; "ccc5"' char(10) '"aaa6"  ; "bb           ' char(10) '            b6"    ; "ccc6"' char(10) ];
% % result matrix:
%! m{1,1} = 'aaa1';
%! m{1,2} = 'bbb1';
%! m{1,3} = 'ccc1';
%! m{2,1} = 'aaa2';
%! m{2,2} = ' bbb2 ';
%! m{2,3} = 'ccc2';
%! m{3,1} = ' aaa3 ';
%! m{3,2} = 'bbb3';
%! m{3,3} = ' ccc3 ';
%! m{4,1} = 'aaa4';
%! m{4,2} = 'b"bb4';
%! m{4,3} = 'ccc4';
%! m{5,1} = 'aaa5';
%! m{5,2} = 'bb;b5';
%! m{5,3} = 'ccc5';
%! m{6,1} = 'aaa6';
%! m{6,2} = ['bb           ' char(10) '            b6'];
%! m{6,3} = 'ccc6';
%! res = csv2cell(s);
%!assert(all(all(strcmp(res, m))));
% % test matrix for slow method:
%! s_s = [' "1"; "2"; "3" ' char(10) ' "4"; "5"; "6" '];
% % test matrix for fast/fast method:
%! s_ff = [' 1; 2; 3 ' char(10) ' 4; 5; 6 '];
% % test matrix 1 for fast/slow method:
%! s_fs1 = [' 1; 2; 3 ' char(10) ' 4; 5 '];
% % test matrix 2 for fast/slow method:
%! s_fs2 = [' 1; 2 ' char(10) ' 4; 5; 6 '];
% % result matrix for slow and fast/fast method:
%! m_s(1,1) = 1;
%! m_s(1,2) = 2;
%! m_s(1,3) = 3;
%! m_s(2,1) = 4;
%! m_s(2,2) = 5;
%! m_s(2,3) = 6;
% % result matrix 1 for slow/fast method:
%! m_fs1 = m_s;
%! m_fs1(2,3) = NaN;
% % result matrix 2 for slow/fast method:
%! m_fs2 = m_s;
%! m_fs2(1,3) = NaN;
% % make tests:
%! res = csv2cell(s_s);
%! res = cellfun(@str2double, res, 'UniformOutput', false);
%! res = cell2mat(res);
%!assert(all(all(res == m_s)));
%! res = csv2cell(s_ff);
%! res = cellfun(@str2double, res, 'UniformOutput', false);
%! res = cell2mat(res);
%!assert(all(all(res == m_s)));
%! res = csv2cell(s_fs1);
%! res = cellfun(@str2double, res, 'UniformOutput', false);
%! res = cell2mat(res);
%!assert(all(all(isequaln(res, m_fs1))));
%! res = csv2cell(s_fs2);
%! res = cellfun(@str2double, res, 'UniformOutput', false);
%! res = cell2mat(res);
%!assert(all(all(isequaln(res, m_fs2))));
