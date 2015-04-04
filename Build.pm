use Panda::Builder;

use Shell::Command;
use NativeCall;

# test sub for system library
our sub testlib() is native('SDL2.dll') { * }

class Build is Panda::Builder {
    method build($workdir) {
        my $need-copy = False;

        # we only have .dll files bundled. Non-windows is assumed to have openssl already
        if $*DISTRO.is-win {
            testlib();
            CATCH {
                default {
                    $need-copy = True if $_.payload ~~ m:s/Cannot locate/;
                }
            }
        }

        if $need-copy {
            say 'No system SDL library detected. Installing bundled version.';
            mkdir($workdir ~ '\blib\lib\SDL2');
            cp($workdir ~ '\native-lib\SDL2.dll', $workdir ~ '\blib\lib\SDL2\SDL2.dll');
        }
        else {
            say 'Found system SDL library.';
        }
    }
}
