use NativeCall;
use SDL2::Raw;
use nqp;

my num ($w, $h) = 1024e0, 786e0;
my SDL_Window $window;
my SDL_Renderer $renderer;

my int $particlenum = 3000;

constant $sdl-lib = 'SDL2';

sub SDL_RenderDrawPoints( SDL_Renderer $, CArray[int32] $points, int32 $count ) returns int32 is native($sdl-lib) {*}

SDL_Init(VIDEO);
$window = SDL_CreateWindow(
    "Particle System!",
    SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOWPOS_CENTERED_MASK,
    $w.Int, $h.Int,
    SHOWN
);
$renderer = SDL_CreateRenderer( $window, -1, ACCELERATED );

SDL_ClearError();

my SDL_RendererInfo $renderer_info .= new;
SDL_GetRendererInfo($renderer, $renderer_info);
say $renderer_info;

say %PIXELFORMAT.pairs.grep({ $_.value == any($renderer_info.texf1, $renderer_info.texf2, $renderer_info.texf3) });

my num @positions = 0e0 xx ($particlenum * 2);
my num @velocities = 0e0 xx ($particlenum * 2);
my num @lifetimes = 0e0 xx $particlenum;

my CArray[int32] $points .= new;
my int $numpoints;

my num ($spawnx, $spawny) = $w / 20e0, 3e0 * $h / 50e0;

sub update (num \df) {
    my int $xidx = 0;
    my int $yidx = 1;
    my int $pointidx = -1;
    my num $gravitydiff = 9.81e0 * df;
    loop (my int $idx = 0; $idx < $particlenum; $idx = $idx + 1) {
        my int $willdraw = 0;
        if (nqp::atpos_n(@lifetimes, $idx) <= 0e0) {
            if (True) {
                nqp::bindpos_n(@lifetimes,  $idx, rand * 10e0);
                nqp::bindpos_n(@positions,  $xidx, $spawnx);
                nqp::bindpos_n(@positions,  $yidx, $spawny);
                #nqp::bindpos_n(@velocities, $xidx, (rand - 0.5e0) * 10e0);
                #nqp::bindpos_n(@velocities, $yidx, (rand - 2e0) * 10e0);
                nqp::bindpos_n(@velocities, $xidx, sin(rand * 2e0 * pi) * (rand) * 10e0);
                nqp::bindpos_n(@velocities, $yidx, cos(rand * 2e0 * pi) * (rand) * 10e0 - 18e0);
                $willdraw = 1;
            }
        } else {
            if nqp::atpos_n(@positions, $yidx) > nqp::div_n($h, 10e0) && nqp::atpos_n(@velocities, $yidx) > 0e0 {
                nqp::bindpos_n(@velocities, $yidx, nqp::atpos_n(@velocities, $yidx) * -0.6e0);
            }

            nqp::bindpos_n(@velocities, $yidx, nqp::atpos_n(@velocities, $yidx) + $gravitydiff);
            nqp::bindpos_n(@positions, $xidx,  nqp::atpos_n(@positions, $xidx) + nqp::atpos_n(@velocities, $xidx) * df);
            nqp::bindpos_n(@positions, $yidx,  nqp::atpos_n(@positions, $yidx) + nqp::atpos_n(@velocities, $yidx) * df);

            nqp::bindpos_n(@lifetimes, $idx, nqp::atpos_n(@lifetimes, $idx) - df);
            $willdraw = 1;
        }

        if ($willdraw) {
            $points.ASSIGN-POS($pointidx = $pointidx + 1, (nqp::atpos_n(@positions, $xidx) * 10e0).Int);
            $points.ASSIGN-POS($pointidx = $pointidx + 1, (nqp::atpos_n(@positions, $yidx) * 10e0).Int);
        }

        $xidx = $xidx + 2;
        $yidx = $xidx + 1;
    }
    $numpoints = ($pointidx - 1) div 2;
}

sub render {
    SDL_SetRenderDrawColor($renderer, 0x0, 0x0, 0x0, 0xff);
    SDL_RenderClear($renderer);

    SDL_SetRenderDrawColor($renderer, 0xff, 0xff, 0xff, 0x7f);
    SDL_RenderDrawPoints($renderer, $points, $numpoints);

    SDL_RenderPresent($renderer);
}

my $event = SDL_Event.new;

my @times;

my num $df = 0.0001e0;

main: loop {
    my $start = nqp::time_n();

    while SDL_PollEvent($event) {
        my $casted_event = SDL_CastEvent($event);

        given $casted_event {
            when *.type == QUIT {
                last main;
            }
            when *.type == KEYDOWN {
                if .scancode == 44 {
                    $spawnx = rand * $w / 10e0;
                    $spawny = rand * $h / 10e0;
                    #@lifetimes = @lifetimes.map({ nqp::div_n($_, 20e0) });
                    $start = nqp::time_n();
                }
            }
        }
    }

    update($df);

    render();

    @times.push: nqp::time_n() - $start;
    $df = nqp::time_n() - $start;
}

@times .= sort;

my @timings = (@times[* div 50], @times[* div 4], @times[* div 2], @times[* * 3 div 4], @times[* - * div 100]);

say "frames per second:";
say (1 X/ @timings).fmt("%3.4f");
say "timings:";
say (     @timings).fmt("%3.4f");
say "";

'raw_timings.txt'.IO.spurt((1 X/ @times).join("\n"));
