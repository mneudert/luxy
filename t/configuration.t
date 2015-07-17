use File::Spec;
use Test::Nginx::Socket;

# setup testing environment
$ENV{TEST_NGINX_PORT} ||= 1984;

my $html_dir    = html_dir();
my $fixture_dir = File::Spec->catfile($html_dir, '..', '..', 'fixtures');

open(my $fh, '<', File::Spec->catfile($fixture_dir, 'http.conf'))
  or die "cannot open < http.conf: $!";
read $fh, our $http_config, -s $fh;
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
        content_by_lua '
            ngx.say(luxy.is_configured())
        ';
    }
--- request
GET /t
--- response_body
false

=== TEST 2: After Configuration
--- http_config eval: $::http_config
--- config
    location /t {
        content_by_lua '
            luxy.configure({})
            ngx.say(luxy.is_configured())
        ';
    }
--- request
GET /t
--- response_body
true

=== TEST 3: Resetting Configuration
--- http_config eval: $::http_config
--- config
    location /t {
        content_by_lua '
            luxy.configure({ foo = "bar" })
            ngx.say(luxy.is_configured())

            ngx.say(ngx.shared.luxy_conf:get("foo"))

            luxy.configure(nil)
            ngx.say(luxy.is_configured())
        ';
    }
--- request
GET /t
--- response_body
true
bar
false
