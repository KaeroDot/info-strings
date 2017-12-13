% --------------------------- tests: %<<<1
%!shared iskey, iskeysubkey, iskey2, isvalval2, isvalsubval2
%! iskey = sprintf('#startsection:: skey\n        key:: val\n#endsection:: skey');
%! iskeysubkey = sprintf('#startsection:: skey\n        #startsection:: subskey\n                key:: val\n        #endsection:: subskey\n#endsection:: skey');
%! iskey2 = sprintf('#startsection:: skey2\n        key:: val\n#endsection:: skey2');
%! isvalval2 = sprintf('#startsection:: skey\n        #startsection:: subskey\n                key:: val\n        #endsection:: subskey\n        key:: val2\n#endsection:: skey');
%! isvalsubval2 = sprintf('#startsection:: skey\n        #startsection:: subskey\n                key:: val\n                key:: val2\n        #endsection:: subskey\n#endsection:: skey');
%!assert(strcmp(infosetsection( 'skey', 'key:: val'                             ), iskey));
%!assert(strcmp(infosetsection( 'key:: val', {'skey'}                           ), iskey));
%!assert(strcmp(infosetsection( 'key:: val', {'skey', 'subskey'}                ), iskeysubkey));
%!assert(strcmp(infosetsection( iskey, 'skey2', 'key:: val'                     ), [iskey  sprintf('\n') iskey2]));
%!assert(strcmp(infosetsection( iskey, 'key:: val', {'skey2'}                   ), [iskey  sprintf('\n') iskey2]));
%!assert(strcmp(infosetsection( iskey2, 'subskey', 'key:: val', {'skey'}        ), [iskey2 sprintf('\n') iskeysubkey]));
%!assert(strcmp(infosetsection( iskeysubkey, 'key:: val2', {'skey'}             ), isvalval2));
%!assert(strcmp(infosetsection( iskeysubkey, 'subskey', 'key:: val2', {'skey'}  ), isvalsubval2));
%!error(infosetsection('a'))
%!error(infosetsection(5))
%!error(infosetsection('a', 'b', 'c', 'd'))
%!error(infosetsection('a', 'b', 'c', {5}))
