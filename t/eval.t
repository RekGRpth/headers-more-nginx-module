# vi:filetype=

use lib 'lib';
use Test::Nginx::Socket; # 'no_plan';

repeat_each(3);

plan tests => repeat_each() * 2 * blocks();

#no_long_string();
#no_diff;

run_tests();

__DATA__

=== TEST 1: set request header at client side
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_evaluate_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
#        eval_subrequest_in_memory off;
#        eval_override_content_type text/plain;
        evaluate $res @res;
        #echo "[$res]";
        if ($res = '1') {
            more_set_input_headers 'Foo: Bar';
            echo "OK";
            break;
        }
        echo "NOT OK";
    }
    location @res {
        echo -n 1;
    }
--- request
    GET /foo
--- response_body
OK
