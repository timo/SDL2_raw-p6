use NativeCall;
use SDL2::Raw;

my ($w, $h) = 320, 240;
my SDL_Window $window;
my SDL_Renderer $renderer;

constant $sdl-lib = 'SDL2';
constant SDL_INIT_VIDEO = 0x00000020;
constant SDL_WINDOWPOS_UNDEFINED_MASK = 0x1FFF0000;
constant SDL_WINDOW_SHOWN = 0x00000004;

sub SDL_RenderDrawPoints( SDL_Renderer $, CArray[int32] $points, int32 $count ) returns int32 is native($sdl-lib) {*}

my $noise_texture = SDL_CreateTexture($renderer, %PIXELFORMAT<ARGB8888>, STREAMING, $w, $h);

my CArray[int32] $points .= new;

sub render {
    my $pixdata = Pointer[int32].new;
    my int32 $pitch;
    my int32 $cursor;
    SDL_LockTexture($noise_texture, SDL_Rect, $pixdata, $pitch);

    say $pixdata;

    $pixdata = nativecast(CArray[int32], $pixdata);

    say $pixdata;

    loop (my int $row; $row < $h; $row = $row + 1) {
        loop (my int $col; $col < $w; $col = $col + 1) {
            $pixdata[$cursor + $col] = Bool.pick ?? 0xff112233 !! 0xffffffff;
        }
        $cursor += $pitch;
    }

    SDL_UnlockTexture($noise_texture);

    SDL_RenderCopy($renderer, $noise_texture, SDL_Rect, SDL_Rect);
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

my $event = SDL_Event.new;

main: loop {
    while SDL_PollEvent($event) {
        my $casted_event = SDL_CastEvent($event);

        given $casted_event {
            when *.type == QUIT {
                last main;
            }
        }
    }

    my $then = now;
    render();
    note "{1 / (now - $then)} fps";
}
