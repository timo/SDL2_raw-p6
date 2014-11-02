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

say SDL_CreateWindowAndRenderer(1024, 786, 2, $pass_win, $pass_render);

my $window = $pass_win[0];
my $render = $pass_render[0];

SDL_RenderSetLogicalSize($render, 800, 600);

my @starfields = do for ^4 {
    my $texture = SDL_CreateTexture($render, PIXELFORMAT_ARGB4444, TARGET, 800, 600);

    SDL_SetRenderTarget($render, $texture);
    SDL_SetRenderDrawColor($render, 0, 0, 0, 0);
    SDL_RenderClear($render);
    SDL_SetRenderDrawColor($render, 255, 255, 255, 255 * (1 - $_ * 0.2));

    for ^CHUNKSIZE {
        my ($x, $y) = 800.rand.Int, 600.rand.Int;
        SDL_RenderDrawPoint($render, $x, $y);
        SDL_RenderDrawPoint($render, $x, $y + 600);
    }

    $texture;
};
SDL_SetRenderTarget($render, SDL_Texture);

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

    my @yoffs  = (nqp::time_n() * 100) % 600 - 600,
                 (nqp::time_n() *  80) % 600 - 600,
                 (nqp::time_n() *  50) % 600 - 600,
                 (nqp::time_n() *  15) % 600 - 600;

    for ^4 {
        my SDL_Rect $src .= new: x => 0, y => @yoffs[$_], w => 800, h => 600;
        SDL_RenderCopy($render, @starfields[$_], $src, SDL_Rect);
    }

    SDL_RenderPresent($render);
}

SDL_Quit();
