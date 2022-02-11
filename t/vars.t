# vi:ft=

use lib 'lib';
use Test::Nginx::Socket; # 'no_plan';

plan tests => 9;

no_diff;

run_tests();

__DATA__

=== TEST 1: vars
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        echo hi;
        set $val 'hello, world';
        more_set_headers 'X-Foo: $val';
    }
--- request
    GET /foo
--- response_headers
X-Foo: hello, world
--- response_body
hi



=== TEST 2: vars in both key and val
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        echo hi;
        set $val 'hello, world';
        more_set_headers '$val: $val';
    }
--- request
    GET /foo
--- response_headers
$val: hello, world
--- response_body
hi



=== TEST 3: vars in input header directives
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        set $val 'dog';
        more_set_input_headers 'Host: $val';
        echo $host;
    }
--- request
    GET /foo
--- response_body
dog
--- response_headers
Host:
