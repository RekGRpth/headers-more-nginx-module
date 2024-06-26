# vi:filetype=

use lib 'lib';
use Test::Nginx::Socket;

repeat_each(2);

plan tests => repeat_each() * 119;

#master_on();
#workers(2);
log_level("warn");
no_diff;

run_tests();

__DATA__

=== TEST 1: simple set (1 arg)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        echo hi;
        more_set_headers 'X-Foo: Blah';
    }
--- request
    GET /foo
--- response_headers
X-Foo: Blah
--- response_body
hi



=== TEST 2: simple set (2 args)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        echo hi;
        more_set_headers 'X-Foo: Blah' 'X-Bar: hi';
    }
--- request
    GET /foo
--- response_headers
X-Foo: Blah
X-Bar: hi
--- response_body
hi



=== TEST 3: two sets in a single location
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /two {
        echo hi;
        more_set_headers 'X-Foo: Blah'
        more_set_headers 'X-Bar: hi';
    }
--- request
    GET /two
--- response_headers
X-Foo: Blah
X-Bar: hi
--- response_body
hi



=== TEST 4: two sets in a single location (for 404 too)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /two {
        more_set_headers 'X-Foo: Blah'
        more_set_headers 'X-Bar: hi';
        return 404;
    }
--- request
    GET /two
--- response_headers
X-Foo: Blah
X-Bar: hi
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 5: set a header then clears it (500)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /two {
        more_set_headers 'X-Foo: Blah';
        more_set_headers 'X-Foo:';
        return 500;
    }
--- request
    GET /two
--- response_headers
! X-Foo
! X-Bar
--- response_body_like: 500 Internal Server Error
--- error_code: 500



=== TEST 6: set a header only when 500 (matched)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        more_set_headers -s 500 'X-Mine: Hiya';
        more_set_headers -s 404 'X-Yours: Blah';
        return 500;
    }
--- request
    GET /bad
--- response_headers
X-Mine: Hiya
! X-Yours
--- response_body_like: 500 Internal Server Error
--- error_code: 500



=== TEST 7: set a header only when 500 (not matched with 200)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        more_set_headers -s 500 'X-Mine: Hiya';
        more_set_headers -s 404 'X-Yours: Blah';
        echo hello;
    }
--- request
    GET /bad
--- response_headers
! X-Mine
! X-Yours
--- response_body
hello
--- error_code: 200



=== TEST 8: set a header only when 500 (not matched with 404)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        more_set_headers -s 500 'X-Mine: Hiya';
        more_set_headers -s 404 'X-Yours: Blah';
        return 404;
    }
--- request
    GET /bad
--- response_headers
! X-Mine
X-Yours: Blah
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 9: more conditions
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        more_set_headers -s '503 404' 'X-Mine: Hiya';
        more_set_headers -s ' 404  413 ' 'X-Yours: Blah';
        return 503;
    }
--- request
    GET /bad
--- response_headers
X-Mine: Hiya
! X-Yours
--- response_body_like: 503 Service
--- error_code: 503



=== TEST 10: more conditions
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        more_set_headers -s '503 404' 'X-Mine: Hiya';
        more_set_headers -s ' 404   413 ' 'X-Yours: Blah';
        return 404;
    }
--- request
    GET /bad
--- response_headers
X-Mine: Hiya
X-Yours: Blah
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 11: more conditions
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        more_set_headers -s '503 404' 'X-Mine: Hiya';
        more_set_headers -s ' 404   413  ' 'X-Yours: Blah';
        return 413;
    }
--- request
    GET /bad
--- response_headers
! X-Mine
X-Yours: Blah
--- response_body_like: 413 Request Entity Too Large
--- error_code: 413



=== TEST 12: simple -t
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/css';
        more_set_headers -t 'text/css' 'X-CSS: yes';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
X-CSS: yes
--- response_body
hi



=== TEST 13: simple -t (not matched)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/plain';
        more_set_headers -t 'text/css' 'X-CSS: yes';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
! X-CSS
--- response_body
hi



=== TEST 14: multiple -t (not matched)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/plain';
        more_set_headers -t 'text/javascript' -t 'text/css' 'X-CSS: yes';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
! X-CSS
--- response_body
hi



=== TEST 15: multiple -t (matched)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/plain';
        more_set_headers -t 'text/javascript' -t 'text/plain' 'X-CSS: yes';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
X-CSS: yes
--- response_body
hi



=== TEST 16: multiple -t (matched)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/javascript';
        more_set_headers -t 'text/javascript' -t 'text/plain' 'X-CSS: yes';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
X-CSS: yes
--- response_body
hi



=== TEST 17: multiple -t (matched) with extra spaces
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/javascript';
        more_set_headers -t ' text/javascript  ' -t 'text/plain' 'X-CSS: yes';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
X-CSS: yes
--- response_body
hi



=== TEST 18: multiple -t merged
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/javascript';
        more_set_headers -t ' text/javascript  text/plain' 'X-CSS: yes';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
X-CSS: yes
--- response_body
hi



=== TEST 19: multiple -t merged (2)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/plain';
        more_set_headers -t ' text/javascript  text/plain' 'X-CSS: yes';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
X-CSS: yes
--- response_body
hi



=== TEST 20: multiple -s option in a directive (not matched)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        more_set_headers -s 404 -s 500 'X-status: howdy';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
! X-status
--- response_body
hi



=== TEST 21: multiple -s option in a directive (matched 404)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        more_set_headers -s 404 -s 500 'X-status: howdy';
        return 404;
    }
--- request
    GET /bad
--- response_headers
X-status: howdy
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 22: multiple -s option in a directive (matched 500)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        more_set_headers -s 404 -s 500 'X-status: howdy';
        return 500;
    }
--- request
    GET /bad
--- response_headers
X-status: howdy
--- response_body_like: 500 Internal Server Error
--- error_code: 500



=== TEST 23: -s mixed with -t
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/html';
        more_set_headers -s 404 -s 200 -t 'text/html' 'X-status: howdy2';
        return 404;
    }
--- request
    GET /bad
--- response_headers
X-status: howdy2
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 24: -s mixed with -t
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/html';
        more_set_headers -s 404 -s 200 -t 'text/plain' 'X-status: howdy2';
        return 404;
    }
--- request
    GET /bad
--- response_headers
! X-status
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 25: -s mixed with -t
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/html';
        more_set_headers -s 404 -s 200 -t 'text/html' 'X-status: howdy2';
        echo hi;
    }
--- request
    GET /bad
--- response_headers
X-status: howdy2
--- response_body
hi
--- error_code: 200



=== TEST 26: -s mixed with -t
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /bad {
        default_type 'text/html';
        more_set_headers -s 500 -s 200 -t 'text/html' 'X-status: howdy2';
        return 404;
    }
--- request
    GET /bad
--- response_headers
! X-status
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 27: merge from the upper level
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    more_set_headers -s 404 -t 'text/html' 'X-status2: howdy3';
    location /bad {
        default_type 'text/html';
        more_set_headers -s 500 -s 200 -t 'text/html' 'X-status: howdy2';
        return 404;
    }
--- request
    GET /bad
--- response_headers
X-status2: howdy3
! X-status
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 28: merge from the upper level
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    more_set_headers -s 404 -t 'text/html' 'X-status2: howdy3';
    location /bad {
        default_type 'text/html';
        more_set_headers -s 500 -s 200 -t 'text/html' 'X-status: howdy2';
        echo yeah;
    }
--- request
    GET /bad
--- response_headers
! X-status2
X-status: howdy2
--- response_body
yeah
--- error_code: 200



=== TEST 29: override settings by inheritance
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    more_set_headers -s 404 -t 'text/html' 'X-status: yeah';
    location /bad {
        default_type 'text/html';
        more_set_headers -s 404 -t 'text/html' 'X-status: nope';
        return 404;
    }
--- request
    GET /bad
--- response_headers
X-status: nope
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 30: append settings by inheritance
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    more_set_headers -s 404 -t 'text/html' 'X-status: yeah';
    location /bad {
        default_type 'text/html';
        more_set_headers -s 404 -t 'text/html' 'X-status2: nope';
        return 404;
    }
--- request
    GET /bad
--- response_headers
X-status: yeah
X-status2: nope
--- response_body_like: 404 Not Found
--- error_code: 404



=== TEST 31: clear headers with wildcard
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location = /backend {
        add_header X-Hidden-One "i am hidden";
        add_header X-Hidden-Two "me 2";
        echo hi;
    }
    location /hello {
        more_clear_headers 'X-Hidden-*';
        proxy_pass http://127.0.0.1:$server_port/backend;
    }
--- request
    GET /hello
--- response_headers
! X-Hidden-One
! X-Hidden-Two
--- response_body
hi



=== TEST 32: clear duplicate headers
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location = /backend {
        add_header pragma no-cache;
        add_header pragma no-cache;
        echo hi;
    }
    location /hello {
        more_clear_headers 'pragma';
        proxy_pass http://127.0.0.1:$server_port/backend;
    }
--- request
    GET /hello
--- response_headers
!pragma
--- response_body
hi



=== TEST 33: HTTP 0.9 (set)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        more_set_headers 'X-Foo: howdy';
        echo ok;
    }
--- raw_request eval
"GET /foo\r\n"
--- response_headers
! X-Foo
--- response_body
ok
--- http09



=== TEST 34: use the -a option to append the cookie field
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /cookie {
        more_set_headers -a 'Set-Cookie: name=lynch';
        echo ok;
    }
--- request
    GET /cookie
--- response_headers
Set-Cookie: name=lynch
--- response_body
ok



=== TEST 35: the original Set-Cookie fields will not be overwritten, when using the -a option
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /cookie {
        more_set_headers 'Set-Cookie: name=lynch';
        more_set_headers -a 'Set-Cookie: born=1981';
        echo ok;
    }
--- request
    GET /cookie
--- raw_response_headers_like eval
"Set-Cookie: name=lynch\r\nSet-Cookie: born=1981\r\n"
--- response_body
ok



=== TEST 36: The behavior of builtin headers can not be changed
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        more_set_headers -a "Server: myServer";
        echo ok;
    }
--- request
    GET /foo
--- must_die
--- error_log chomp
can not append builtin headers
--- suppress_stderr
--- SKIP



=== TEST 37: can not use -a option with more_clear_headers
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /foo {
        more_clear_headers -a 'Content-Type';
        echo ok;
    }
--- request
    GET /foo
--- must_die
--- error_log chomp
invalid option name: "-a"
--- suppress_stderr
--- SKIP
