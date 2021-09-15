use v6.d;
use Cro::HTTP::Router;
use Cro::HTTP::Exception;
use Base64; 
unit module API is export; 

# Compile-time config
constant $cwd      = '/home/dsock/projects/codesections/main';
constant $zola-cmd = 'zola build';

# Run-time config
my $token = join ':', %*ENV<CODESEC_API_USER CODESEC_API_PASSWORD>:v;

my Str $auth-ok := 'Basic ' ~encode-base64 :str, $token;
sub http-err($msg, $_=response) { .status = 500 and .set-body: $msg }

my &api-v1 = { route {
    #| Check that api.codesections.com is functioning normally
    get -> 'health' { content 'text/plain', 'OK' }

    #| Build the www.codesections.com static site from latest git source
    post -> 'zola', 'build', :$authorization! is header where $auth-ok {
        my $cmd = shell :err:$cwd, qq{ set -e; git pull; $zola-cmd };
        $cmd ?? created  'https://www.codesections.com'
             !! http-err 'zola build error: ' ~$cmd.err.slurp(:close) }
}}

our $App is export = route { include v1 => api-v1 }
