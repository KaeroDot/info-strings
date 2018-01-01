% run tests implemented in function definitions:
addpath('..')

test infosetmatrix.m
test infogetmatrix.m

test infosetnumber.m
test infogetnumber.m

test infosetsection.m
test infogetsection.m

test infosettext.m
test infogettext.m

test infosettextmatrix.m
test infogettextmatrix.m

test infosettime.m
test infogettime.m

test infosettimematrix.m
test infogettimematrix.m

test infoload.m
test infosave.m

% make very complex test and measure time:
tempfile = 'test_file_to_delete';
mat1 = magic(5);
mat1key = 'matrix1';
mat2 = magic(100)(:,1:end-1);
mat2key = 'matrix2';
num1 = 5.0123456789;
num1key = 'number1';
num2 = -3.1-7.1i;
num2key = 'number2';
sec1 = {'first quite complex name of section !@#$%^&*()'};
sec2 = {'second quite complex name of section !@#$%^&*()'};
secarray = cellfun(@num2str, num2cell([1:100]), 'UniformOutput', false);
text1 = 'some text 1234567890!@#$%^&*()-=_+[]{};\:"|,./<>?';
text1key = 'text1';
text2 = 'some other text';
text2key = 'text2';
textmatrix1 = {'a', 'b', 'c'; 'd', 'e', 'f'};
textmatrix1key = 'textmatrix1';
textmatrix2 = {"a", "b\n", 'c"c"c'; "d", "e", "f"};
textmatrix2key = 'textmatrix2';
time1 = time();
time1key = 'time1';
time2 = time1 + 10;
time2key = 'time2';

% make infostring:
id = tic;
is = '';
is = infosetmatrix(is, mat1key, mat1, sec1);
is = infosetmatrix(is, mat2key, mat2, sec2);
is = infosetnumber(is, num1key, num1, sec1);
is = infosetnumber(is, num2key, num2, sec2);
is = infosettext(is, text1key, text1, sec1);
is = infosettext(is, text2key, text2, sec2);
is = infosettextmatrix(is, textmatrix1key, textmatrix1, sec1);
is = infosettextmatrix(is, textmatrix2key, textmatrix2, sec2);
is = infosettime(is, time1key, time1, sec1);
is = infosettime(is, time2key, time2, sec2);
disp(['making infostring took ' num2str(toc(id)) ' s']);
% save and load:
infosave(is, tempfile, 1, 1);
clear is;
is = infoload(tempfile);
% make tests:
id = tic;
assert(infogetmatrix(is, mat1key, sec1), mat1);
assert(infogetmatrix(is, mat2key, sec2), mat2);
assert(infogetnumber(is, num1key, sec1), num1);
assert(infogetnumber(is, num2key, sec2), num2);
assert(infogettext(is, text1key, sec1), text1);

assert(infogettext(is, text2key, sec2), text2);
assert(infogettextmatrix(is, textmatrix1key, sec1), textmatrix1);
assert(infogettextmatrix(is, textmatrix2key, sec2), textmatrix2);
assert(infogettime(is, time1key, sec1), time1, 1e-6);
assert(infogettime(is, time2key, sec2), time2, 1e-6);
disp(['reading and testing infostring took ' num2str(toc(id)) ' s']);
% clean up
delete([tempfile '.info']);
