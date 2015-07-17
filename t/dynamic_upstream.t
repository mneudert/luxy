use File::Spec;
use Test::Nginx::Socket;

# setup testing environment
$ENV{TEST_NGINX_PORT} ||= 1984;

my $html_dir     = html_dir();
my $fixture_dir  = File::Spec->catfile($html_dir, '..', '..', 'fixtures');
my $fixture_http = File::Spec->catfile($fixture_dir, 'http.conf');

open(my $fh, '<', $fixture_http) or die "cannot open < $fixture_http: $!";
read($fh, our $http_config, -s $fh);
close $fh;

# proceed with testing
repeat_each(2);
plan tests => repeat_each() * blocks() * 2;

run_tests();

__DATA__

=== TEST 1: Application Upstream
--- http_config eval: $::http_config
--- config
    location /t {
        rewrite_by_lua '
            ngx.req.set_header("Host", "application")
        ';

        proxy_pass  http://application;
    }
--- request
GET /t
--- response_body
upstream: application/t

=== TEST 1: Legacy Upstream
--- http_config eval: $::http_config
--- config
    location /t {
        rewrite_by_lua '
            ngx.req.set_header("Host", "legacy")
        ';

        proxy_pass  http://legacy;
    }
--- request
GET /t
--- response_body
upstream: legacy/t
