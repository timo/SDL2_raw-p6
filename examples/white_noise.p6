use NativeCall;
 
class SDL_Window is repr('CStruct') {}
class SDL_Renderer is repr('CStruct') {}
 
my ($w, $h) = 320, 240;
my SDL_Window $window;
my SDL_Renderer $renderer;
 
constant $sdl-lib = 'SDL2';
constant SDL_INIT_VIDEO = 0x00000020;
constant SDL_WINDOWPOS_UNDEFINED_MASK = 0x1FFF0000;
constant SDL_WINDOW_SHOWN = 0x00000004;
 
sub SDL_Init(int32 $flag) returns int32 is native($sdl-lib) {*}
sub SDL_Quit() is native($sdl-lib) {*}
 
sub SDL_CreateWindow(Str $title, int $x, int $y, int $w, int $h, int32 $flag) returns SDL_Window is native($sdl-lib) {*}
sub SDL_CreateRenderer(SDL_Window $, int $, int $) returns SDL_Renderer is native($sdl-lib) {*}
sub SDL_SetRenderDrawColor(SDL_Renderer $, int $r, int $g, int $b, int $a) returns Int is native($sdl-lib) {*}
sub SDL_RenderClear(SDL_Renderer $) returns Int is native($sdl-lib) {*}
sub SDL_RenderDrawPoint( SDL_Renderer $, int32 $x, int32 $y ) returns Int is native($sdl-lib) {*}
sub SDL_RenderDrawPoints( SDL_Renderer $, CArray[int32] $points, int32 $count ) returns Int is native($sdl-lib) {*}
sub SDL_RenderPresent(SDL_Renderer $) is native($sdl-lib) {*}

my CArray[int32] $points .= new;

sub render {
    SDL_SetRenderDrawColor($renderer, 0, 0, 0, 0);
    SDL_RenderClear($renderer);
    SDL_SetRenderDrawColor($renderer, 255, 255, 255, 0);
    my int $cur = 0;
    loop (my int $i; $i < $w; $i = $i + 1) {
        loop (my int $j; $j < $h; $j = $j + 1) {
            if Bool.pick {
                $points[$cur++] = $i;
                $points[$cur++] = $j;
            }
        }
    }
    SDL_RenderDrawPoints( $renderer, $points, $cur div 2 );
    SDL_RenderPresent($renderer);
}

sub old_render {
    SDL_SetRenderDrawColor($renderer, 0, 0, 0, 0);
    SDL_RenderClear($renderer);
    SDL_SetRenderDrawColor($renderer, 255, 255, 255, 0);
    loop (my int $i; $i < $w; $i = $i + 1) {
        loop (my int $j; $j < $h; $j = $j + 1) {
            SDL_RenderDrawPoint( $renderer, $i, $j ) if Bool.pick
        }
    }
    SDL_RenderPresent($renderer);
}

SDL_Init(SDL_INIT_VIDEO);
$window = SDL_CreateWindow(
    "some white noise",
    SDL_WINDOWPOS_UNDEFINED_MASK, SDL_WINDOWPOS_UNDEFINED_MASK,
    $w, $h,
    SDL_WINDOW_SHOWN
);
$renderer = SDL_CreateRenderer( $window, -1, 1 );
loop {
    my $then = now;
    render();
    note "{1 / (now - $then)} fps";
}
END { SDL_Quit() }

Signal(SIGTERM).tap({ SDL_Quit(); exit(0) });
