use NativeCall;
use SDL2::Raw;

my int ($w, $h) = 320, 240;
my SDL_Window $window;
my SDL_Renderer $renderer;

constant $sdl-lib = 'SDL2';
constant SDL_INIT_VIDEO = 0x00000020;
constant SDL_WINDOWPOS_UNDEFINED_MASK = 0x1FFF0000;
constant SDL_WINDOW_SHOWN = 0x00000004;

sub SDL_RenderDrawPoints( SDL_Renderer $, CArray[int32] $points, int32 $count ) returns int32 is native($sdl-lib) {*}

SDL_Init(SDL_INIT_VIDEO);
$window = SDL_CreateWindow(
    "some white noise",
    SDL_WINDOWPOS_UNDEFINED_MASK, SDL_WINDOWPOS_UNDEFINED_MASK,
    $w, $h,
    SDL_WINDOW_SHOWN
);
$renderer = SDL_CreateRenderer( $window, -1, ACCELERATED +| TARGETTEXTURE );

SDL_ClearError();

my SDL_RendererInfo $renderer_info .= new;
SDL_GetRendererInfo($renderer, $renderer_info);
say $renderer_info;

say %PIXELFORMAT.pairs.grep({ $_.value == any($renderer_info.texf1, $renderer_info.texf2, $renderer_info.texf3) });

my $noise_texture = SDL_CreateTexture($renderer, %PIXELFORMAT<ARGB8888>, STREAMING, $w, $h);

#my CArray[int32] $points .= new;

my $pixdatabuf = CArray[int64].new(0, 1234, 1234, 1234);

sub render {
    my int $pitch;
    my int $cursor;
    my $pixdata = nativecast(Pointer[int64], $pixdatabuf);
    SDL_LockTexture($noise_texture, SDL_Rect, $pixdata, $pitch);

    $pitch div= 4; # pitch is in bytes, our addresses are in 32bit chunks

    $pixdata = nativecast(CArray[int32], Pointer.new($pixdatabuf[0]));

    loop (my int $row; $row < $h; $row = $row + 1) {
        loop (my int $col; $col < $w; $col = $col + 1) {
            $pixdata[$cursor + $col] = Bool.pick ?? 0xff112233 !! 0xffffffff;
            #$pixdata[$cursor + $col] = 0xff112233;
        }
        $cursor += $pitch;
    }

    SDL_UnlockTexture($noise_texture);

    SDL_RenderCopy($renderer, $noise_texture, SDL_Rect, SDL_Rect);
    SDL_RenderPresent($renderer);
}

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
