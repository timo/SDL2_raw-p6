use NativeCall;
use SDL2::Raw;
use Cairo;

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

#SDL_RenderSetLogicalSize($render, 800, 600);

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

my $enemy_image = Cairo::Image.record(
    -> $ctx {
        $ctx.translate(64, 64);
        $ctx.scale(3, 3);
        $ctx.move_to(5, -15);
        $ctx.line_to(-5, -15);
        $ctx.curve_to(-30, -15, -15, 15, -5, 15);
        $ctx.line_to(-3, -5);
        $ctx.line_to(0, 5);
        $ctx.line_to(3, -5);
        $ctx.line_to(5, 15);
        $ctx.curve_to(15, 15, 30, -15, 5, -15);
        $ctx.line_to(5, -15);

        $ctx.line_to(0, -5) :relative;
        $ctx.line_to(-10, 0) :relative;
        $ctx.line_to(0, 5) :relative;

        $ctx.rgb(0.9, 0.2, 0.1);
        $ctx.fill() :preserve;
        $ctx.rgb(1, 1, 1);
        $ctx.stroke();
    }, 128, 128, FORMAT_ARGB32);

my $enemy_texture = SDL_CreateTexture($render, %PIXELFORMAT<ARGB8888>, STATIC, 128, 128);
SDL_UpdateTexture($enemy_texture, SDL_Rect.new(:x(0), :y(0), :w(128), :h(128)), $enemy_image.data, $enemy_image.stride // 128 * 4);
SDL_SetTextureBlendMode($enemy_texture, 1);

SDL_SetRenderDrawBlendMode($render, 1);

my @times;

my num $start = nqp::time_n();
my $event = SDL_Event.new;
main: loop {
    my num $start = nqp::time_n();
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
        my SDL_Rect $src .= new: x => 0, y => @yoffs.at_pos($_).Int, w => 1200, h => 960;
        SDL_RenderCopy($render, @starfields.at_pos($_), $src, SDL_Rect);
    }

    SDL_RenderCopy($render, $enemy_texture, SDL_Rect, SDL_Rect.new(:x(640), :y(480), :w(128), :h(128)));

    SDL_RenderPresent($render);
    @times.push: nqp::time_n() - $start;

    sleep(1 / 50);
}

SDL_Quit();

say <<"calculation times" "rendering times" "complete times" "GC times">>[(state $)++];
@times .= sort;

my @timings = (@times[* div 50], @times[* div 4], @times[* div 2], @times[* * 3 div 4], @times[* - * div 100]);

say "frames per second:";
say (1 X/ @timings).fmt("%3.4f");
say "timings:";
say (     @timings).fmt("%3.4f");
say "";
