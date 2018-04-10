use File::Basename;
use File::Spec;
use Test::Nginx::Socket;

# setup testing environment
$ENV{TEST_NGINX_PORT} ||= 1984;

my $test_dir     = File::Spec->rel2abs(dirname(__FILE__));
my $fixture_dir  = File::Spec->catfile($test_dir, 'fixtures');
my $fixture_http = File::Spec->catfile($fixture_dir, 'http.conf');

open(my $fh, '<', $fixture_http) or die "cannot open < $fixture_http: $!";
read($fh, our $http_config, -s $fh);
close $fh;

# proceed with testing
repeat_each(2);
plan tests => repeat_each() * blocks() * 2;

run_tests();

__DATA__

=== TEST 1: Before Configuration
--- http_config eval: $::http_config
--- config
    location /t {
        content_by_lua_block {
            ngx.say(luxy.is_configured())
        }
    }
--- request
GET /t
--- response_body
false

=== TEST 2: After Configuration
--- http_config eval: $::http_config
--- config
    location /t {
        content_by_lua_block {
            luxy.configure({})
            ngx.say(luxy.is_configured())
        }
    }
--- request
GET /t
--- response_body
true

=== TEST 3: Resetting Configuration
--- http_config eval: $::http_config
--- config
    location /t {
        content_by_lua_block {
            luxy.configure({ foo = 'bar' })
            ngx.say(luxy.is_configured())

            ngx.say(ngx.shared.luxy_conf:get('foo'))

            luxy.configure(nil)
            ngx.say(luxy.is_configured())
        }
    }
--- request
GET /t
--- response_body
true
bar
false
