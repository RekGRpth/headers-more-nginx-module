# vi:filetype=perl

use lib 'lib';
use Test::Nginx::Socket;

plan tests => 3;

no_diff;

run_tests();

__DATA__

=== TEST 1: simple set (1 arg)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        deny all;
        more_set_headers 'X-Foo: Blah';
    }
--- request
    GET /foo
--- response_headers
X-Foo: Blah
--- response_body_like: 403 Forbidden
--- error_code: 403
