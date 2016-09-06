use NativeCall;
use SDL2::Raw;

constant W = 800;
constant H = 600;

SDL_Init(VIDEO);
my $window = SDL_CreateWindow("Image",
        SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOWPOS_CENTERED_MASK,
        W, H,
        OPENGL);
my $render = SDL_CreateRenderer($window, -1, ACCELERATED +| PRESENTVSYNC);

my $bmp = SDL_LoadBMP( "test.bmp" );
my $texture = SDL_CreateTextureFromSurface( $render, $bmp );
my $dst_rect = SDL_Rect.new( 0, 0, W, H );

main: loop {
    my $event = SDL_Event.new;

    while SDL_PollEvent( $event ) {
        my $casted_event = SDL_CastEvent( $event );
        if $casted_event.type == QUIT {
            last main;
        }
    }

    SDL_RenderCopy( $render, $texture, Nil, $dst_rect );
    SDL_RenderPresent( $render );
}

SDL_Quit();
