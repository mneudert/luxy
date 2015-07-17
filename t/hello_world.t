use File::Spec;
use Test::Nginx::Socket;

# setup testing environment
my $html_dir    = html_dir();
my $fixture_dir = File::Spec->catfile($html_dir, '..', '..', 'fixtures');

open my $fh, '<', File::Spec->catfile($fixture_dir, 'http.conf');
read $fh, our $http_config, -s $fh;
close $fh;

# proceed with testing
repeat_each(2);
plan tests => repeat_each() * 2;

run_tests();

__DATA__

=== TEST 1: Hello World
--- http_config eval: $::http_config
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
