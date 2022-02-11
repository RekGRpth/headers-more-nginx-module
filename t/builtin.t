# vi:filetype=

use lib 'lib';
use Test::Nginx::Socket; # 'no_plan';

plan tests => 60;

no_diff;

run_tests();

__DATA__

=== TEST 1: set Server
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        echo hi;
        more_set_headers 'Server: Foo';
    }
--- request
    GET /foo
--- response_headers
Server: Foo
--- response_body
hi



=== TEST 2: clear Server
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        echo hi;
        more_clear_headers 'Server: ';
    }
--- request
    GET /foo
--- response_headers
! Server
--- response_body
hi



=== TEST 3: set Content-Type
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        default_type 'text/plan';
        more_set_headers 'Content-Type: text/css';
        echo hi;
    }
--- request
    GET /foo
--- response_headers
Content-Type: text/css
--- response_body
hi



=== TEST 4: set Content-Type
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        default_type 'text/plan';
        more_set_headers 'Content-Type: text/css';
        return 404;
    }
--- request
    GET /foo
--- response_headers
Content-Type: text/css
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 5: clear Content-Type
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        default_type 'text/plain';
        more_clear_headers 'Content-Type: ';
        return 404;
    }
--- request
    GET /foo
--- response_headers
! Content-Type
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 6: clear Content-Type (colon not required)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        default_type 'text/plain';
        more_set_headers 'Content-Type: Hello';
        more_clear_headers 'Content-Type';
        return 404;
    }
--- request
    GET /foo
--- response_headers
! Content-Type
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 7: clear Content-Type (value ignored)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        default_type 'text/plain';
        more_set_headers 'Content-Type: Hello';
        more_clear_headers 'Content-Type: blah';
        return 404;
    }
--- request
    GET /foo
--- response_headers
! Content-Type
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 8: clear Content-Type (case insensitive)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        default_type 'text/plain';
        more_set_headers 'Content-Type: Hello';
        more_clear_headers 'content-type: blah';
        return 404;
    }
--- request
    GET /foo
--- response_headers
! Content-Type
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 9: clear Content-Type using set empty
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        default_type 'text/plain';
        more_set_headers 'Content-Type: Hello';
        more_set_headers 'content-type:';
        return 404;
    }
--- request
    GET /foo
--- response_headers
! Content-Type
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 10: clear Content-Type using setting key only
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        default_type 'text/plain';
        more_set_headers 'Content-Type: Hello';
        more_set_headers 'content-type';
        return 404;
    }
--- request
    GET /foo
--- response_headers
! Content-Type
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 11: set content-length
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /len {
        more_set_headers 'Content-Length: 2';
        echo hello;
    }
--- request
    GET /len
--- response_headers
Content-Length: 2
--- response_body chop
he



=== TEST 12: set content-length multiple times
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /len {
        more_set_headers 'Content-Length: 2';
        more_set_headers 'Content-Length: 4';
        echo hello;
    }
--- request
    GET /len
--- response_headers
Content-Length: 4
--- response_body chop
hell



=== TEST 13: clear content-length
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /len {
        more_set_headers 'Content-Length: 4';
        more_set_headers 'Content-Length:';
        echo hello;
    }
--- request
    GET /len
--- response_headers
! Content-Length
--- response_body
hello



=== TEST 14: clear content-length (another way)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /len {
        more_set_headers 'Content-Length: 4';
        more_clear_headers 'Content-Length';
        echo hello;
    }
--- request
    GET /len
--- response_headers
! Content-Length
--- response_body
hello



=== TEST 15: clear content-type
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /len {
        default_type 'text/plain';
        more_set_headers 'Content-Type:';
        echo hello;
    }
--- request
    GET /len
--- response_headers
! Content-Type
--- response_body
hello



=== TEST 16: clear content-type (the other way)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /len {
        default_type 'text/plain';
        more_clear_headers 'Content-Type:';
        echo hello;
    }
--- request
    GET /len
--- response_headers
! Content-Type
--- response_body
hello



=== TEST 17: set Charset
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /len {
        default_type 'text/plain';
        more_set_headers 'Charset: gbk';
        echo hello;
    }
--- request
    GET /len
--- response_headers
Charset: gbk
--- response_body
hello



=== TEST 18: clear Charset
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /len {
        default_type 'text/plain';
        more_set_headers 'Charset: gbk';
        more_clear_headers 'Charset';
        echo hello;
    }
--- request
    GET /len
--- response_headers
! Charset
--- response_body
hello



=== TEST 19: clear Charset (the other way: using set)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /len {
        default_type 'text/plain';
        more_set_headers 'Charset: gbk';
        more_set_headers 'Charset: ';
        echo hello;
    }
--- request
    GET /len
--- response_headers
! Charset
--- response_body
hello



=== TEST 20: set Vary
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        more_set_headers 'Vary: gbk';
        echo hello;
    }
    location /len {
        default_type 'text/plain';
        more_set_headers 'Vary: hello';
        proxy_pass http://127.0.0.1:$server_port/foo;
    }
--- request
    GET /len
--- response_headers
Vary: hello
--- response_body
hello
