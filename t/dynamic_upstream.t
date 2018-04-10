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

=== TEST 1: Default Upstream
--- http_config eval: $::http_config
--- config
    location /t {
        content_by_lua_block {
            luxy.configure({ default_upstream = 'application' })
            ngx.say(luxy.get_upstream())
        }
    }
--- request
GET /t
--- response_body
application

=== TEST 2: Upstream by Request URI
--- http_config eval: $::http_config
--- config
    location /t {
        content_by_lua_block {
            luxy.configure({ default_upstream = 'application' })
            luxy.set_mappings({ ['/t'] = 'legacy' })

            ngx.say(luxy.get_upstream())
        }
    }
--- request
GET /t
--- response_body
legacy

=== Test 3: Execute Upstream (legacy as default)
--- http_config eval: $::http_config
--- config
    location /t {
        set  $upstream  '';

        rewrite_by_lua_block {
            luxy.configure({ default_upstream = 'legacy' })
            luxy.set_mappings({ ['/unmatched'] = 'application' })

            ngx.var.upstream = luxy.get_upstream();

            ngx.req.set_header('Host', ngx.var.upstream);
        }

        proxy_pass  http://$upstream;
    }
--- request
GET /t
--- response_body
upstream: legacy/t

=== Test 3: Execute Upstream (application as match)
--- http_config eval: $::http_config
--- config
    location /t {
        set  $upstream  '';

        rewrite_by_lua_block {
            luxy.configure({ default_upstream = 'legacy' })
            luxy.set_mappings({ ['/t'] = 'application' })

            ngx.var.upstream = luxy.get_upstream();

            ngx.req.set_header('Host', ngx.var.upstream);
        }

        proxy_pass  http://$upstream;
    }
--- request
GET /t
--- response_body
upstream: application/t
