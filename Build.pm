use Panda::Builder;

use Shell::Command;
use LWP::Simple;
use NativeCall;

# test sub for system library
sub test() is native('SDL2.dll') { * }

class Build is Panda::Builder {
    method build($workdir) {
        my $need-copy = False;

        # we only have .dll files bundled. Non-windows is assumed to have openssl already
        if $*DISTRO.is-win {
            test();
            CATCH {
                default {
                    $need-copy = True if $_.payload ~~ m:s/Cannot locate/;
                }
            }
        }

        if $need-copy {
            # to avoid a dependency (and because Digest::SHA is too slow), we do a hacked up powershell hash
            # this should work all the way back to powershell v1
            my &ps-hash = -> $path {
                my $fn = 'function get-sha256 { param($file);[system.bitconverter]::tostring([System.Security.Cryptography.sha256]::create().computehash([system.io.file]::openread((resolve-path $file)))) -replace \"-\",\"\" } ';
                my $out = qqx/powershell -noprofile -Command "$fn get-sha256 $path"/;
                $out.lines.grep({$_.chars})[*-1];
            }
            say 'No system SDL library detected. Installing bundled version.';
            mkdir($workdir ~ '\blib\lib\SDL2');
            my @files = ("SDL2.dll");
            my @hashes = ("20EB366E76D04CEF2CF38FF4D4D7A7DCBFB75C6B50281960A49861F847561E54");
            for @files Z @hashes -> $f, $h {
                say "Fetching  " ~ $f;
                my $blob = LWP::Simple.get('http://URI/for/download/' ~ $f);
                say "Writing   " ~ $f;
                spurt($workdir ~ '\blib\lib\SDL2\\' ~ $f, $blob);

                say "Verifying " ~ $f;
                my $hash = ps-hash($workdir ~ '\blib\lib\SDL2\\' ~ $f);
                if ($hash ne $h) {
                    die "Bad download of $f (got: $hash; expected: $h)";
                }
                say "";
            }
        }
        else {
            say 'Found system SDL library.';
        }
    }
}
