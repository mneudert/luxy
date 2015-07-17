use Test::Nginx::Socket;
use Cwd qw(cwd);

# setup testing environment
my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/src/?.lua;;";
};


# proceed with testing
repeat_each(2);
plan tests => repeat_each() * 2;

run_tests();

__DATA__

=== TEST 1: Hello World
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local luxy = require "luxy"

            luxy.hello()
        ';
    }
--- request
GET /t
--- response_body
hello world
