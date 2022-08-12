use NativeCall;
use SDL2::Raw;
use nqp;

my &memset = $*KERNEL ~~ /win32/
        ?? sub (Pointer $str, int32 $c, size_t $n) returns Pointer is symbol('memset') is native('ucrtbase') {*}
        !! sub (Pointer $str, int32 $c, size_t $n) returns Pointer is symbol('memset') is native {*};

my int ($w, $h) = 800, 600;
my SDL_Window $window;
my SDL_Surface $screen;

my int $particlenum = 1000;

SDL_Init(VIDEO);
$window = SDL_CreateWindow(
        "Particle System! Surface",
        SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOWPOS_CENTERED_MASK,
        $w, $h,
        SHOWN
                                    );

$screen = SDL_GetWindowSurface($window);

my SDL_Surface $surface = SDL_CreateRGBSurface(0, $w, $h, 32,
        0xff000000, 0x00ff0000, 0x0000ff00, 0x000000ff);
SDL_FreeSurface($surface);

SDL_ClearError;

my num @positions = 0e0 xx ($particlenum * 2);
my num @velocities = 0e0 xx ($particlenum * 2);
my num @lifetimes = 0e0 xx $particlenum;

my CArray[uint32] $pixels = nativecast(CArray[uint32], $screen.pixels);

my int $numpoints;

sub update (num \df) {
    my int $xidx = 0;
    my int $yidx = 1;
    my int $pointidx = 0;
    SDL_LockSurface($screen);
    memset($screen.pixels, 0x00000000, $h * $w * 4);
    my $color = SDL_MapRGBA($screen.format, 0xff, 0xff, 0xff, 0xff);
    loop (my int $idx = 0; $idx < $particlenum; $idx = $idx + 1) {
        my int $willdraw = 0;
        if (@lifetimes[$idx] <= 0e0) {
            if (rand < df) {
                @lifetimes[$idx] = rand * 10e0;
                @positions[$xidx] = ($w / 20e0).Num;
                @positions[$yidx] = (3 * $h / 50).Num;
                @velocities[$xidx] = (rand - 0.5e0) * 10;
                @velocities[$yidx] = (rand - 2e0) * 10;
                $willdraw = 1;
            }
        } else {
            if @positions[$yidx] > $h / 10e0 && @velocities[$yidx] > 0 {
                @velocities[$yidx] = @velocities[$yidx] * -0.6e0;
            }

            @velocities[$yidx] = @velocities[$yidx] + 9.81e0 * df;
            @positions[$xidx] = @positions[$xidx] + @velocities[$xidx] * df;
            @positions[$yidx] = @positions[$yidx] + @velocities[$yidx] * df;

            @lifetimes[$idx] = @lifetimes[$idx] - df;
            $willdraw = 1;
        }

        if ($willdraw) {
            #$points[$pointidx++] = (@positions[$xidx] * 10).floor;
            #$points[$pointidx++] = (@positions[$yidx] * 10).floor;
            my $x = (@positions[$xidx] * 10).floor;
            my $y = (@positions[$yidx] * 10).floor;
            $pixels[$x + $y * $w] = $color if $x < $w && $y < $h;
        }

        $xidx = $xidx + 2;
        $yidx = $xidx + 1;
    }
    SDL_UnlockSurface($screen);
    $numpoints = ($pointidx - 1) div 2;
}

sub render {
    SDL_UpdateWindowSurface($window);
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
        }
    }

    update($df);

    render;

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
