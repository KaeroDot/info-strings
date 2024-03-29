% ## Copyright (C) 2019 Martin Šíra %<<<1
% ##
% 
% ## -*- texinfo -*-
% ## Function reads test.info, compares it to correct values, writes info and reads it again and again
% ## compares to correct values. The aim is to do an extensive and thorough test of info scripts.
% 
% ## Author: Martin Šíra <msiraATcmi.cz>
% ## Created: 2019
% ## Version: 0.2
% ## Script quality:
% ##   Tested: no
% ##   Contains help: no
% ##   Contains example in help: no
% ##   Checks inputs: no
% ##   Contains tests: no
% ##   Contains demo: no
% ##   Optimized: no

function allres = test_octave

isoct = exist('OCTAVE_VERSION', 'builtin') > 0;

if isoct
        addpath('../GNU_Octave_scripts/')
else
        addpath('../Matlab_scripts/')
end

k = cell(0);
v = cell(0);
t = cell(0);
t = cell(0);
% counter of values:
val = 0;
% cells with:
% k: keys
% v: values with expected results
% t: type of value (number, string, time, matrix, stringmatrix, timematrix, section)
% s: cell of strings with sections

val = val + 1;
k{val} = 'Test key, no value';
v{val}   = '';
t{val}   = 'string';
s{val}   = {''};
val = val + 1;
k{val} = 'Test key';
v{val}   = 'A';
t{val}   = 'string';
s{val}   = {''};
val = val + 1;
k{val} = 'Test key, similar';
v{val}   = 'B';
t{val}   = 'string';
s{val}   = {''};
val = val + 1;
k{val} = 'Test key, no spaces';
v{val}   = 'C';
t{val}   = 'string';
s{val}   = {''};
val = val + 1;
k{val} = 'Test key, both spaces';
v{val}   = 'D';
t{val}   = 'string';
s{val}   = {''};
val = val + 1;
k{val} = 'Test key, space left';
v{val}   = 'E';
t{val}   = 'string';
s{val}   = {''};
val = val + 1;
k{val} = 'Test key, space right';
v{val}   = 'F';
t{val}   = 'string';
s{val}   = {''};
val = val + 1;
k{val} = 'Test integer, 16 digits';
v{val}   = 1234567890123456;
t{val}   = 'number';
s{val}   = {''};
val = val + 1;
k{val} = 'Test floating point, 16 digits after decimal dot';
v{val}   = 0.1234567890123456;
t{val}   = 'number';
s{val}   = {''};
val = val + 1;
k{val} = 'Test floating point, 15 digits before decimal dot';
v{val}   = 123456789012345.6;
t{val}   = 'number';
s{val}   = {''};
val = val + 1;
k{val} = 'Test complex number';
v{val}   = 2.34 + 5.67i;
t{val}   = 'number';
s{val}   = {''};
val = val + 1;
k{val} = 'Test imaginary number';
v{val}   = 8.90i;
t{val}   = 'number';
s{val}   = {''};
val = val + 1;
k{val} = 'Test string, simple';
v{val}   = 'test string';
t{val}   = 'string';
s{val}   = {''};
val = val + 1;
k{val} = 'Test string, nonletter characters';
v{val}   = ['!@#$%^&*()-=[]{};' char(39)  '"' char(92) char(39) char(92) '"\:|,./<>?'];
t{val}   = 'string';
s{val}   = {''};
val = val + 1;
k{val} = ['Test string, nonletter characters in key !@#$%^&*()-=[]{};' char(39)  '"' char(92) char(39) char(92)  '"\:|,./<>?'];
v{val}   = 'in key';
t{val}   = 'string';
s{val}   = {''};
if isoct
        % matlab cannot handle UTF8
        val = val + 1;
        k{val} = 'Test string, UTF8 characters';
        v{val}   = 'řœДμΩℜℑ';
        t{val}   = 'string';
        s{val}   = {''};
        val = val + 1;
        k{val} = 'Test string, UTF8 characters in key řœДμΩℜℑ';
        v{val}   = 'in key';
        t{val}   = 'string';
        s{val}   = {''};
end
val = val + 1;
k{val} = 'Test time, no time zone';
v{val}   = 1014376332.123456;
t{val}   = 'time';
s{val}   = {''};
val = val + 1;
k{val} = 'Test time, with time zone, UTC';
v{val}   = 1014379932.123456;
t{val}   = 'time';
s{val}   = {''};
val = val + 1;
k{val} = 'Test time, with time zone, +10 minutes';
v{val}   = 1014379932.123456;
t{val}   = 'time';
s{val}   = {''};
val = val + 1;
k{val} = 'Test time, with time zone, -10 minutes';
v{val}   = 1014379932.123456;
t{val}   = 'time';
s{val}   = {''};
val = val + 1;
k{val} = 'Test time, with time zone, +1 hour';
v{val}   = 1014379932.123456;
t{val}   = 'time';
s{val}   = {''};
val = val + 1;
k{val} = 'Test time, with time zone, -1 hour';
v{val}   = 1014379932.123456;
t{val}   = 'time';
s{val}   = {''};
val = val + 1;
k{val} = 'Test time, with time zone, +1:10';
v{val}   = 1014379932.123456;
t{val}   = 'time';
s{val}   = {''};
val = val + 1;
k{val} = 'Test time, with time zone, -1:10';
v{val}   = 1014379932.123456;
t{val}   = 'time';
s{val}   = {''};

val = val + 1;
k{val} = 'Test matrix, empty';
v{val}   = [];
t{val}   = 'matrix';
s{val}   = {''};
val = val + 1;
k{val}   = 'Test matrix, single value';
v{val}   = 1;
t{val}   = 'matrix';
s{val}   = {''};
val = val + 1;
k{val} = ['Test matrix, single value, nonletter characters in key !@#$%^&*()-=[]{};' char(39)  '"' char(92) char(39) char(92)  '"\:|,./<>?'];
v{val}   = 2;
t{val}   = 'matrix';
s{val}   = {''};
if isoct
        % matlab cannot handle UTF8
        val = val + 1;
        k{val} = 'Test matrix, single value, UTF8 characters in key řœДμΩℜℑ';
        v{val}   = 3;
        t{val}   = 'matrix';
        s{val}   = {''};
end
val = val + 1;
k{val} = 'Test matrix, row numbers';
v{val}   = [4  5  6];
t{val}   = 'matrix';
s{val}   = {''};
val = val + 1;
k{val} = 'Test matrix, column numbers';
v{val}   = [7; 8; 9];
t{val}   = 'matrix';
s{val}   = {''};
val = val + 1;
k{val} = 'Test matrix';
v{val}   = [1.1,  2.1, 3.1; 4e4, -5e5, 6e-6; 7.7e7,  8.123456789e1, NaN];
t{val}   = 'matrix';
s{val}   = {''};
val = val + 1;
k{val} = 'Test matrix complex';
v{val}   = [1.234,  2.345i, 3.456 + 4.567i];
t{val}   = 'matrix';
s{val}   = {''};
val = val + 1;
k{val} = 'Test matrix, mixed numbers and text for reading as numbers';
v{val}   = [1, NaN, 2, NaN; 3, NaN, 4, NaN];
t{val}   = 'matrix';
s{val}   = {''};
val = val + 1;
k{val} = 'Test matrix, mixed numbers and text for reading as strings';
v{val}   = {'11', 'One', '12', 'Two'; '13', 'Three', '14', 'Four'};
t{val}   = 'stringmatrix';
s{val}   = {''};
val = val + 1;
k{val} = 'Test matrix, mixed numbers and text with special characters read as numbers';
v{val}   = [1, NaN, 2, NaN; 3, NaN, 4, NaN];
t{val}   = 'matrix';
s{val}   = {''};
val = val + 1;
k{val} = 'Test matrix, mixed numbers and text with special characters read as strings';
v{val}   = {'11', 'One;One', '12', 'Two"Two'; '13', 'Three;Three', '14', sprintf('Four\n                Four')};
t{val}   = 'stringmatrix';
s{val}   = {''};
val = val + 1;
k{val} = 'Test matrix, time values';
v{val}   = [1014379932.123456, 1014379932.123456+1*3600; 1014379932.123456+2*3600, 1014379932.123456+3*3600];
t{val}   = 'timematrix';
s{val}   = {''};
k{val} = 'Test matrix, lousy format and spaces';
v{val}   = [77, 8.8, NaN; NaN, 999, 10; 11, 12, 13];
t{val}   = 'matrix';
s{val}   = {''};

val = val + 1;
k{val} = 'Key for section test';
v{val}   = 1;
t{val}   = 'number';
s{val}   = {''};
val = val + 1;
k{val} = 'Key for section test';
v{val}   = 2;
t{val}   = 'number';
s{val}   = {'Test section'};
val = val + 1;
k{val} = 'Key for section test';
v{val}   = 3;
t{val}   = 'number';
s{val}   = {'Test section', 'Test subsection'};
val = val + 1;
k{val} = 'Key for section test';
v{val}   = 4;
t{val}   = 'number';
s{val}   = {'Test section', 'Test subsection', 'Test subsubsection'};
val = val + 1;
k{val} = 'Key for section test';
v{val}   = 5;
t{val}   = 'number';
s{val}   = {'Test section', 'Test subsection', 'Test subsubsection', 'Test subsubsubsection'};
val = val + 1;
k{val} = 'Key for section test';
v{val}   = 6;
t{val}   = 'number';
s{val}   = {'Test section 2'};
val = val + 1;
k{val} = 'Key for section test';
v{val}   = 7;
t{val}   = 'number';
s{val}   = {'Test section 2', 'Test section 2'};
val = val + 1;
k{val} = 'Key for section test';
v{val}   = 8;
t{val}   = 'number';
s{val}   = {'Test section 2', 'Test section 2', 'Test section 2'};
val = val + 1;
k{val} = 'Key for section test';
v{val}   = 9;
t{val}   = 'number';
s{val}   = {'Test section 2', 'Test section 2', 'Test section 2', 'Test section 2'};
val = val + 1;
k{val} = 'Key for section test';
v{val}   = 10;
s{val}   = {['Test section, nonletter characters in key !@#$%^&*()-=[]{};' char(39)  '"' char(92) char(39) char(92)  '"\:|,./<>?']};
t{val}   = 'number';
if isoct
        % matlab cannot handle UTF8
        val = val + 1;
        k{val} = 'Key for section test';
        v{val}   = 11;
        s{val}   = {'Test section, UTF8 characters in key řœДμΩℜℑ'};
        t{val}   = 'number';
end
val = val + 1;
k{val} = '';
v{val}   = ['!@#$%^&*()-=[]{};' char(39)  '"' char(92) char(39) char(92)  '"\:|,./<>?' sprintf('\n        \t\n                ') 'řœДμΩℜℑ'];
s{val}   = {'Test section, special characters inside'};
t{val}   = 'section';

% run tests
for j = 1:3
        % j==1 regexps
        % j==2 parsing
        % j==3 save and reload of infostring
        switch j
        case 1
                disp('Tests using regular expressions')
                % load infostring from existing file:
                infostr = infoload('test.info');
                % values will be set to this infostring and saved and loaded later:
                infostr2 = '';
        case 2
                % save new infostring to temporary file so it will not be spoiled by following run:
                infosave(infostr2, 'tmp.info', 0, 1);
                % parse infostring:
                disp('Tests using parsing')
                infostr = infoparse(infostr);
        case 3
                disp('Tests using regular expressions after saving and loading')
                % load temporary file and make tests again:
                infostr = infoload('tmp.info');
        otherwise
                error('selftest is written badly - bad case')
        end
        tic
        % for every key do tests:
        for i = 1:length(k)
                switch t{i}
                case 'number'
                        res{i} = infogetnumber(infostr, k{i}, s{i});
                        testr(j,i) = (numel(res{i}) == numel(v{i})) & all(all( res{i} == v{i} | (isnan(v{i}) & isnan(res{i})) ));
                        infostr2 = infosetnumber(infostr2, k{i}, v{i}, s{i});
                case 'string'
                        res{i} = infogettext(infostr, k{i}, s{i});
                        testr(j,i) = strcmp(res{i}, v{i});
                        infostr2 = infosettext(infostr2, k{i}, v{i}, s{i});
                case 'time'
                        res{i} = infogettime(infostr, k{i}, s{i});
                        testr(j,i) = abs(res{i} - v{i}) < 0.5e-6;       % this is given by precision of number in octave for current years
                        infostr2 = infosettime(infostr2, k{i}, v{i}, s{i});
                case 'matrix'
                        res{i} = infogetmatrix(infostr, k{i}, s{i});
                        testr(j,i) = (numel(res{i}) == numel(v{i})) & all(all( res{i} == v{i} | (isnan(v{i}) & isnan(res{i})) ));
                        infostr2 = infosetmatrix(infostr2, k{i}, v{i}, s{i});
                case 'stringmatrix'
                        res{i} = infogettextmatrix(infostr, k{i}, s{i});
                        testr(j,i) = (numel(res{i}) == numel(v{i})) & all(all(strcmp(res{i}, v{i})));
                        infostr2 = infosettextmatrix(infostr2, k{i}, v{i}, s{i});
                case 'timematrix'
                        res{i} = infogettimematrix(infostr, k{i}, s{i});
                        testr(j,i) = all(all(abs(res{i} - v{i}) < 0.5e-6)); % this is given by precision of number in octave for current years
                        infostr2 = infosettimematrix(infostr2, k{i}, v{i}, s{i});
                case 'section'
                        res{i} = infogetsection(infostr, s{i});
                        testr(j,i) = strcmp(res{i}, v{i});
                        infostr2 = infosetsection(infostr2, v{i}, s{i});
                otherwise
                        error('selftest is written badly - bad type of key-val')
                end
                % report test result:
                if testr(j,i)
                        disp(['test ' num2str(i) ' ok'])
                else
                        disp(['test ' num2str(i) ' BAD'])
                        disp(['Key: ' k{i}])
                        disp(['Value:'])
                        v{i}
                        disp(['Result:'])
                        res{i}
                        disp(['Section:'])
                        s{i}
                end
        end % i = 1:length(k)
        tim{j} = toc;
end % j = 1:2

% test of standalone files %<<<1
disp('Tests of standalone files:')
testr_standalone = [];
fn_temp = 'tmp.info';

% test 1 - key %<<<2
k = 'Test key';
v = 'A';
s = {};
fn = 'test_standalone_key.info';

infostr = infoload(fn);
infostr2 = infoparse(infostr);
r = infogettext(infostr, k, s);
r2 = infogettext(infostr2, k, s);
testr_standalone(end+1) = strcmp(v, r) & strcmp(v, r2);
infostr = infosettext('', k, v);
delete(fn_temp); infosave(infostr, fn_temp);
infostr = infoload(fn_temp);
t = infogettext(infostr, k);
testr_standalone(end) = testr_standalone(end) + strcmp(v, r);
if testr_standalone(end) disp('Test standalone key ok') else disp('Test standalone key BAD') end;

% test 2 - matrix %<<<2
k = 'Test matrix';
v = [1.1 2.1 3.1; 4e4 -5e5 6e-6; 7.7e7 8.123456789e1 NaN];
s = {};
fn = 'test_standalone_matrix.info';

infostr = infoload(fn);
infostr2 = infoparse(infostr);
r = infogetmatrix(infostr, k, s);
r2 = infogetmatrix(infostr2, k, s);
testr_standalone(end+1) = (numel(r) == numel(v)) & all(all( r == v | (isnan(v) & isnan(r)) ));
testr_standalone(end) = testr_standalone(end) & (numel(r2) == numel(v)) & all(all( r2 == v | (isnan(v) & isnan(r2)) ));
infostr = infosetmatrix('', k, v);
delete(fn_temp); infosave(infostr, fn_temp);
infostr = infoload(fn_temp);
m = infogetmatrix(infostr, k);
testr_standalone(end) = testr_standalone(end) & (numel(r) == numel(v)) & all(all( r == v | (isnan(v) & isnan(r)) ));
if testr_standalone(end) disp('Test standalone matrix ok') else disp('Test standalone matrix BAD') end;

% test 3 - time matrix %<<<2
k = 'Test matrix, time values';
v = [1014379932.123456, 1014379932.123456+1*3600; 1014379932.123456+2*3600, 1014379932.123456+3*3600];
s = {};
fn = 'test_standalone_matrixtime.info';

infostr = infoload(fn);
infostr2 = infoparse(infostr);
r = infogettimematrix(infostr, k, s);
r2 = infogettimematrix(infostr2, k, s);
testr_standalone(end+1) = all(all(abs(r - v) < 0.5e-6));
testr_standalone(end) = testr_standalone(end) & all(all(abs(r - v) < 0.5e-6));
infostr = infosettimematrix('', k, v);
delete(fn_temp); infosave(infostr, fn_temp);
infostr = infoload(fn_temp);
r = infogettimematrix(infostr, k);
testr_standalone(end) = testr_standalone(end) & all(all(abs(r - v) < 0.5e-6));
if testr_standalone(end) disp('Test standalone time matrix ok') else disp('Test standalone time matrix BAD') end;

% test 4 - section-key %<<<2
k = 'Key for section test';
v = 2;
s = {'Test section'};
fn = 'test_standalone_sectionkey.info';

infostr = infoload(fn);
infostr2 = infoparse(infostr);
r = infogetnumber(infostr, k, s);
r2 = infogetnumber(infostr2, k, s);
testr_standalone(end+1) = (numel(r) == numel(v)) & all(all( r == v | (isnan(v) & isnan(r)) ));
testr_standalone(end) = testr_standalone(end) & (numel(r2) == numel(v)) & all(all( r2 == v | (isnan(v) & isnan(r2)) ));
infostr = infosetnumber('', k, v);
delete(fn_temp); infosave(infostr, fn_temp);
infostr = infoload(fn_temp);
m = infogetnumber(infostr, k);
testr_standalone(end) = testr_standalone(end) & (numel(r) == numel(v)) & all(all( r == v | (isnan(v) & isnan(r)) ));
if testr_standalone(end) disp('Test standalone section key ok') else disp('Test standalone section key BAD') end;

% display results %<<<1
disp('------------')
disp(['Tests using regular expressions took ' num2str(tim{1}) ' s to finish.'])
disp(['Number of bad tests: ' num2str(sum(testr(1,:) == 0))])
disp(['Tests using parsing took ' num2str(tim{2}) ' s to finish.'])
disp(['Number of bad tests: ' num2str(sum(testr(2,:) == 0))])
disp(['Tests using regular expressions of saved and loaded file took ' num2str(tim{3}) ' s to finish.'])
disp(['Number of bad tests: ' num2str(sum(testr(3,:) == 0))])
disp(['Number of bad standalone tests: ' num2str(sum(testr_standalone == 0))])

allres = all(all(testr > 0));

end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
