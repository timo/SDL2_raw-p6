use NativeCall;
use SDL2::Raw;

SDL_Init(VIDEO);

for ^SDL_GetNumRenderDrivers() {
    my $foo = SDL_RendererInfo.new;
    SDL_GetRenderDriverInfo($_, $foo);
    say $foo.perl;
}

my CArray[SDL_Window] $pass_win .= new;
my CArray[SDL_Renderer] $pass_render .= new;

$pass_win[0] = SDL_Window;
$pass_render[0] = SDL_Renderer;

say SDL_CreateWindowAndRenderer(1280, 960, 2, $pass_win, $pass_render);

my $window = $pass_win[0];
my $render = $pass_render[0];

SDL_RenderSetLogicalSize($render, 800, 600);

my @starfields = do for ^4 {
    my $texture = SDL_CreateTexture($render, %PIXELFORMAT<ARGB8888>, TARGET, 1200, 1920);

    say $texture;

    say SDL_SetRenderTarget($render, $texture);
    say SDL_SetRenderDrawColor($render, 0, 0, 0, 0);
    say SDL_RenderClear($render);
    say SDL_SetRenderDrawColor($render, 255, 255, 255, (255 * (1 - $_ * 0.2)).Int);

    for ^250 {
        my ($x, $y) = 1200.rand.Int, 960.rand.Int;
        SDL_RenderDrawPoint($render, $x, $y);
        SDL_RenderDrawPoint($render, $x, $y + 960);
    }

    say SDL_SetTextureBlendMode($texture, 1);

    $texture;
};
say SDL_SetRenderTarget($render, SDL_Texture);

say SDL_SetRenderDrawBlendMode($render, 1);

my num $start = nqp::time_n();
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

    SDL_SetRenderDrawColor($render, 0, 0, 0, 0);
    SDL_RenderClear($render);

    my @yoffs  = ((nqp::time_n() * -100) % 960).Int,
                 ((nqp::time_n() *  -80) % 960).Int,
                 ((nqp::time_n() *  -50) % 960).Int,
                 ((nqp::time_n() *  -15) % 960).Int;

    SDL_SetRenderDrawColor($render, 255, 255, 255, 255);
    for ^4 {
        my SDL_Rect $src .= new: x => 0, y => @yoffs[$_].Int, w => 1200, h => 960;
        SDL_RenderCopy($render, @starfields[$_], $src, SDL_Rect);
    }

    SDL_RenderPresent($render);
}

SDL_Quit();
