# vim:set ft= ts=4 sw=4 et fdm=marker:

use lib 'lib';
use Test::Nginx::Socket;

#worker_connections(1014);
#master_process_enabled(1);
#log_level('warn');

repeat_each(2);

plan tests => repeat_each() * (4 * blocks());

#no_diff();
no_long_string();

run_tests();

__DATA__

=== TEST 1: clear the Connection req header
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /req-header {
        more_clear_input_headers Connection;
        echo "connection: $http_connection";
    }
--- request
GET /req-header

--- stap
F(ngx_http_headers_more_exec_input_cmd) {
    printf("rewrite: conn type: %d\n", $r->headers_in->connection_type)
}


F(ngx_http_core_content_phase) {
    printf("content: conn type: %d\n", $r->headers_in->connection_type)
}

--- stap_out
rewrite: conn type: 1
content: conn type: 0

--- response_body
connection: 
--- no_error_log
[error]



=== TEST 2: set custom Connection req header (close)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /req-header {
        more_set_input_headers "Connection: CLOSE";
        echo "connection: $http_connection";
    }
--- request
GET /req-header

--- stap
F(ngx_http_headers_more_exec_input_cmd) {
    printf("rewrite: conn type: %d\n", $r->headers_in->connection_type)
}


F(ngx_http_core_content_phase) {
    printf("content: conn type: %d\n", $r->headers_in->connection_type)
}

--- stap_out
rewrite: conn type: 1
content: conn type: 1

--- response_body
connection: CLOSE
--- no_error_log
[error]



=== TEST 3: set custom Connection req header (keep-alive)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /req-header {
        more_set_input_headers "Connection: keep-alive";
        echo "connection: $http_connection";
    }
--- request
GET /req-header

--- stap
F(ngx_http_headers_more_exec_input_cmd) {
    printf("rewrite: conn type: %d\n", $r->headers_in->connection_type)
}


F(ngx_http_core_content_phase) {
    printf("content: conn type: %d\n", $r->headers_in->connection_type)
}

--- stap_out
rewrite: conn type: 1
content: conn type: 2

--- response_body
connection: keep-alive
--- no_error_log
[error]



=== TEST 4: set custom Connection req header (bad)
--- main_config
    load_module /etc/nginx/modules/ngx_http_echo_module.so;
    load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;
--- config
    location /req-header {
        more_set_input_headers "Connection: bad";
        echo "connection: $http_connection";
    }
--- request
GET /req-header

--- stap
F(ngx_http_headers_more_exec_input_cmd) {
    printf("rewrite: conn type: %d\n", $r->headers_in->connection_type)
}


F(ngx_http_core_content_phase) {
    printf("content: conn type: %d\n", $r->headers_in->connection_type)
}

--- stap_out
rewrite: conn type: 1
content: conn type: 0

--- response_body
connection: bad
--- no_error_log
[error]
