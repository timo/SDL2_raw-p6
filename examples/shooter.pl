use NativeCall;
use SDL2::Raw;
use Cairo;
use nqp;

constant W = 1280;
constant H = 960;

constant REFRACT_PROB = 30;
constant ENEMY_PROB = 5;

class Object is rw {
    has Complex $.pos;
    has Complex $.vel;
    has Int $.id = (4096.rand).Int;
    has Num $.lifetime;
}

class Enemy is Object is rw {
    has Int $.HP;
}

my $player = Object.new( :pos(H / 2 + (H * 6 / 7)\i) );

SDL_Init(VIDEO);

for ^SDL_GetNumRenderDrivers() {
    my $foo = SDL_RendererInfo.new;
    SDL_GetRenderDriverInfo($_, $foo);
    say $foo.perl;
}

my $window = SDL_CreateWindow("Space Shooter!",
        SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOWPOS_CENTERED_MASK,
        1280, 960,
        OPENGL);
my $render = SDL_CreateRenderer($window, -1, ACCELERATED +| PRESENTVSYNC);

#SDL_RenderSetLogicalSize($render, 800, 600);

my @starfields = do for ^4 {
    my $texture = SDL_CreateTexture($render, %PIXELFORMAT<ARGB8888>, TARGET, 1200, 1920);

    $texture;

    SDL_SetRenderTarget($render, $texture);
    SDL_SetRenderDrawColor($render, 0, 0, 0, 0);
    SDL_RenderClear($render);
    SDL_SetRenderDrawColor($render, 255, 255, 255, (255 * (1 - $_ * 0.2)).Int);

    for ^250 {
        my ($x, $y) = 1200.rand.Int, 960.rand.Int;
        SDL_RenderDrawPoint($render, $x, $y);
        SDL_RenderDrawPoint($render, $x, $y + 960);
    }

    SDL_SetTextureBlendMode($texture, 1);

    $texture;
};
SDL_SetRenderTarget($render, SDL_Texture);

my $enemy_image = Cairo::Image.record(
    -> $_ {
        .translate(64, 64);
        .scale(3, 3);
        .move_to(5, -15);
        .line_to(-5, -15);
        .curve_to(-30, -15, -15, 15, -5, 15);
        .line_to(-3, -5);
        .line_to(0, 5);
        .line_to(3, -5);
        .line_to(5, 15);
        .curve_to(15, 15, 30, -15, 5, -15);
        .line_to(5, -15);

        .line_to(0, -5) :relative;
        .line_to(-10, 0) :relative;
        .line_to(0, 5) :relative;

        .rgb(0.9, 0.2, 0.1);
        .fill() :preserve;
        .rgb(1, 1, 1);
        .stroke();
    }, 128, 128, Cairo::FORMAT_ARGB32);

my $enemy_texture = SDL_CreateTexture($render, %PIXELFORMAT<ARGB8888>, STATIC, 128, 128);
SDL_UpdateTexture($enemy_texture, SDL_Rect.new(0, 0, 128, 128), $enemy_image.data, $enemy_image.stride // 128 * 4);
SDL_SetTextureBlendMode($enemy_texture, 1);

SDL_SetRenderDrawBlendMode($render, 1);

my @times;

my num $start = nqp::time_n();
my $event = SDL_Event.new;

enum GAME_KEYS (
    K_UP    => 82,
    K_DOWN  => 81,
    K_LEFT  => 80,
    K_RIGHT => 79,
    K_SPACE => 44,
);

my %down_keys;

my @bullets;
my @enemies;
my @shieldbounces;
my @kills;
my $nextreload = 0;
my $explosion_background = 0;

my num $last_frame_start = nqp::time_n();

main: loop {
    my num $start = nqp::time_n();
    my $dt = $start - $last_frame_start // 0.00001;
    while SDL_PollEvent($event) {
        my $casted_event = SDL_CastEvent($event);

        given $casted_event {
            when *.type == QUIT {
                last main;
            }
            when *.type == KEYDOWN {
                if GAME_KEYS(.scancode) -> $comm {
                    %down_keys{$comm} = 1;
                } else { say "new keycode found: $_.scancode()"; }

                CATCH { say $_ }
            }
            when *.type == KEYUP {
                if GAME_KEYS(.scancode) -> $comm {
                    %down_keys{$comm} = 0;
                } else { say "new keycode found: $_.scancode()"; }

                CATCH { say $_ }
            }
        }
    }

    $explosion_background -= $dt if $explosion_background > 0;

    if %down_keys<K_LEFT> && $player.pos.re > 20 {
        $player.pos -= 400 * $dt;
    }
    if %down_keys<K_RIGHT> && $player.pos.re < W - 20 {
        $player.pos += 400 * $dt;
    }

    if %down_keys<K_SPACE> {
        if $start > $nextreload && !defined $player.lifetime {
            @bullets.push(Object.new(:pos($player.pos), :vel(0 - 768i)));
            $nextreload = $start + 0.2;
        }
    }

    for flat @bullets, @shieldbounces {
        $_.pos += $dt * $_.vel;
        $_.lifetime -= $dt if defined $_.lifetime;
    }
    @bullets .= grep(
        -> $b {
            my $p = $b.pos;
            0 < $b.pos.re < W
            and 0 < $b.pos.im < H
    });

    for @enemies {
        if $_.pos.re < 15 && $_.vel.re < 0 {
            $_.vel = -$_.vel.re + $_.vel.im\i
        }
        if $_.pos.re > W - 15 && $_.vel.re > 0 {
            $_.vel = -$_.vel.re + $_.vel.im\i
        }
        if !defined $_.lifetime {
            if $_.vel.im < 182 && ($_.id > 128 || $_.pos.im < H / 4) {
                $_.vel += ($dt * 100)\i;
                my $polarvel = $_.vel.polar;
                $_.vel = unpolar($polarvel[0] min 182, $polarvel[1]);
            } elsif $_.id <= 128 {
                if $_.pos.im > H / 4 {
                    if $_.vel.im > 16 {
                        $_.vel *= 0.9
                    }
                }
            }
        }

        $_.pos += $dt * $_.vel;

        if $_.lifetime {
            $_.lifetime -= $dt;
            $_.vel *= 0.8;
        } else {
            if !defined $player.lifetime {
                for @bullets -> $b {
                    next unless -20 < $b.pos.re - $_.pos.re < 20;
                    next unless -20 < $b.pos.im - $_.pos.im < 20;

                    my $posdiff   = ($_.pos - $b.pos);
                    my $polardiff = $posdiff.polar;
                    if $polardiff[0] < 35 {
                        if $_.HP == 0 {
                            $_.lifetime = 2e0;
                            $_.vel += $b.vel / 4;
                            $_.vel *= 4;
                            if 100.rand < REFRACT_PROB && @bullets < 50 {
                                for ^4 {
                                    @bullets.push:
                                        Object.new: :pos($b.pos), :vel(unpolar(768, (2 * π).rand));
                                }
                            }
                            @kills.push($_);
                            $explosion_background = 0.9 + 0.1.rand;
                        } elsif $_.HP > 0 {
                            next if $_.HP <= 2 && $polardiff >= 25;
                            $_.HP--;
                            my $bumpdiff = unpolar(1, ($posdiff - 30i).polar[1]);
                            $_.vel += $bumpdiff * ($_.HP > 2 ?? 25 !! 200) - 96i;
                            if $_.HP >= 2 {
                                @shieldbounces.push:
                                    Object.new: :pos($_.pos),
                                                :vel($_.vel),
                                                :lifetime(0.25e0);
                            }
                        }
                        $b.pos -= 1000i;
                        last;
                    }
                }
            }

            if ($player.pos - $_.pos).polar[0] < 40 {
                $player.lifetime //= 3e0;
                $explosion_background = 1e0;
            }
        }
    }
    @enemies .= grep({ $_.pos.im < H + 30 && (!$_.lifetime || $_.lifetime > 0) });
    @shieldbounces.shift while @shieldbounces and @shieldbounces[0].lifetime <= 0;

    if 100.rand < ENEMY_PROB && @enemies < 100 {
        @enemies.push: Enemy.new:
            :pos((W - 24).rand + 12 - 15i),
            :vel((100.rand - 50) + 182i),
            :HP(3);
    }

    SDL_SetRenderDrawColor($render, 0, 0, 0, 0);
    SDL_RenderClear($render);

    my @yoffs  = ((nqp::time_n() * -100) % 960).Int,
                 ((nqp::time_n() *  -80) % 960).Int,
                 ((nqp::time_n() *  -50) % 960).Int,
                 ((nqp::time_n() *  -15) % 960).Int;

    SDL_SetRenderDrawColor($render, 255, 255, 255, 255);
    for ^4 {
        my SDL_Rect $src .= new: x => 0, y => @yoffs.AT-POS($_).Int, w => 1200, h => 960;
        SDL_RenderCopy($render, @starfields.AT-POS($_), $src, SDL_Rect);
    }

    for @enemies {
        SDL_RenderCopy($render, $enemy_texture, SDL_Rect, SDL_Rect.new(.pos.re - 32, .pos.im - 32, 64, 64));
    }

    SDL_SetRenderDrawColor($render, 78, 78, 255, 255);
    for @bullets {
        my $bulletrect = SDL_Rect.new: $_.pos.re - 3, $_.pos.im - 8, 6, 16;
        SDL_RenderFillRect($render, $bulletrect);
    }

    SDL_RenderPresent($render);
    nqp::force_gc() if 3.rand < 1;
    @times.push: nqp::time_n() - $start;

    $last_frame_start = $start;
    #sleep(1 / 50);
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
