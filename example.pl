use NativeCall;
use SDL2::Raw;

SDL_Init(VIDEO);

for ^SDL_GetNumRenderDrivers() {
    my $foo = SDL_RendererInfo.new;
    SDL_GetRenderDriverInfo($_, $foo);
    say $foo.perl;
}

my CArray[SDL_Window] $win .= new;
my CArray[SDL_Renderer] $render .= new;

SDL_CreateWindowAndRenderer(1024, 786, ACCELERATED, $win, $render);

say $win[0].perl;
say $render[0].perl;

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
}

SDL_Quit();
