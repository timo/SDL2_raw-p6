unit module SDL2::Raw:ver<0.0.2>;

=begin pod

=head1 SDL2::Raw

A low-sugar binding to SDL2.

=head2 Synopsis

=begin code :lang<perl6>
    use SDL2::Raw;

    die "couldn't initialize SDL2: { SDL_GetError }" if SDL_Init(VIDEO) != 0;

    my $window = SDL_CreateWindow("Hello, world!",
            SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOWPOS_CENTERED_MASK,
            800, 600, OPENGL);
    my $render = SDL_CreateRenderer($window, -1, ACCELERATED +| PRESENTVSYNC);

    my $event = SDL_Event.new;

    main: loop {
        SDL_SetRenderDrawColor($render, 0, 0, 0, 0);
        SDL_RenderClear($render);

        while SDL_PollEvent($event) {
            if $event.type == QUIT {
                last main;
            }
        }

        SDL_SetRenderDrawColor($render, 255, 255, 255, 255);
        SDL_RenderFillRect($render,
            SDL_Rect.new(
                2 * min(now * 300 % 800, -now * 300 % 800),
                2 * min(now * 470 % 600, -now * 470 % 600),
            sin(3 * now) * 50 + 80, cos(4 * now) * 50 + 60));

        SDL_RenderPresent($render);
    }
    SDL_Quit();
=end code

=head2 Status

There's a bunch of functions and structs already covered, but there's also a whole bunch of things I haven't touched at all. If you need any specific part of the API covered, feel free to open a ticket on github or even a pull request!

=head2 Examples

=head3 Snake

L<screenshots/snake-screenshot.png>

A simple Snake game. Control it with the arrow keys, guide your snake to eat the red circles, and avoid running into your tail.

This code uses C<Cairo> to create the images for the snake's body and tail.

=head3 Particles

L<screenshots/particles-screenshot.png>

A very simple particle system that spews white pixels from a central point that get pulled down by gravity and bounce on the floor.

=head3 Shooter

L<screenshots/shooter-screenshot.png>

A more complicated game. Control it with the arrow keys and hold the spacebar to fire.

The code also uses C<Cairo> to render the player's spaceship and the enemy spaceships. In generating the starfields it shows how to render to a texture with C<SDL2>.

=head3 White Noise

L<screenshots/white-noise-screenshot.png>

Just draws random white and black pixels to a texture and displays it.

=end pod

use NativeCall;

my Str $lib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $lib = 'SDL2';
    } else {
        $lib = 'SDL2';
    }
}

class SDL_Point is export is repr('CStruct') is rw {
    # positional
    multi method new(Real $x, Real $y) { self.bless(:$x.Int, :$y.Int) }
    multi method new(Complex $complex) { self.bless(:x($complex.re), :y($complex.im)) }

    # named
    multi method new(Int(Real) :$x!, Int(Real) :$y!) { self.bless(:$x, :$y) }

    has int32 $.x;
    has int32 $.y;
}

class SDL_Rect is export is repr('CStruct') is rw {
    # positional
    multi method new(int $x, int $y, int $w, int $h) { self.bless(:$x, :$y, :$w, :$h) }
    multi method new(Int(Real) $x, Int(Real) $y, Int(Real) $w, Int(Real) $h) { self.bless(:$x, :$y, :$w, :$h) }

    # named
    multi method new(int :$x!, int :$y!, int :$w!, int :$h!) { self.bless(:$x, :$y, :$w, :$h) }
    multi method new(Int(Real) :$x!, Int(Real) :$y!, Int(Real) :$w!, Int(Real) :$h!) { self.bless(:$x, :$y, :$w, :$h) }

    has int32 $.x;
    has int32 $.y;
    has int32 $.w;
    has int32 $.h;
}
class SDL_DisplayMode is export is repr('CStruct') is rw {
    has uint32   $.format;
    has int32    $.w;
    has int32    $.h;
    has int32    $.refresh_rate;
    has Pointer  $.driverdata;
}

enum SDL_INIT is export (
    :TIMER(0x1),
    :AUDIO(0x10),
    :VIDEO(0x20),
    :JOYSTICK(0x200),
    :HAPTIC(0x1000),
    :GAMECONTROLLER(0x2000),
    :EVENTS(0x4000),
    :NOPARACHUTE(0x100000)
);

sub SDL_Init(int32 $flags) is native($lib) is export returns int32 {*}
sub SDL_Quit() is native($lib) is export {*}

sub term:<SDL_GetTicks> is native($lib) is symbol<SDL_GetTicks> is export returns uint32 {*}

class SDL_Window is export is repr('CPointer') { }

enum SDL_WindowFlags is export (
    :FULLSCREEN(0x00000001),
    :OPENGL(0x00000002),
    :SHOWN(0x00000004),
    :HIDDEN(0x00000008),
    :BORDERLESS(0x00000010),
    :RESIZABLE(0x00000020),
    :MINIMIZED(0x00000040),
    :MAXIMIZED(0x00000080),
    :INPUT_GRABBED(0x00000100),
    :INPUT_FOCUS(0x00000200),
    :MOUSE_FOCUS(0x00000400),
    :FULLSCREEN_DESKTOP(0x00001001),
    :FOREIGN(0x00000800),
    :ALLOW_HIGHDPI(0x00002000),
    :MOUSE_CAPTURE(0x00004000),
);

enum WindowEventID is export (
    'WINDOW_EVENT_NONE',           # Never used
    'EVENT_SHOWN',          # Window has been shown
    'EVENT_HIDDEN',         # Window has been hidden
    'EXPOSED',        # Window has been exposed and should be redrawn
    'MOVED',          # Window has been moved to data1', data2
    'RESIZED',        # Window has been resized to data1xdata2
    'SIZE_CHANGED',   # The window size has changed', either as a result of an API call or through the system or user changing the window size.
    'EVENT_MINIMIZED',      # Window has been minimized
    'EVENT_MAXIMIZED',      # Window has been maximized
    'RESTORED',       # Window has been restored to normal size and position
    'ENTER',          # Window has gained mouse focus
    'LEAVE',          # Window has lost mouse focus
    'FOCUS_GAINED',   # Window has gained keyboard focus
    'FOCUS_LOST',     # Window has lost keyboard focus
    'CLOSE',          # The window manager requests that the window be closed
);

our constant SDL_WINDOWPOS_UNDEFINED_MASK is export = 0x1FFF0000;
our constant SDL_WINDOWPOS_CENTERED_MASK is export = 0x2FFF0000;

class SDL_RendererInfo is export is repr('CStruct') is rw {
    has Str $.name;
    has int32 $.flags;
    has int32 $.num_texture_formats;
    # ugly hack because we don't have flattened arrays in cstructs yet
    has int32 $.texf1; has int32 $.texf2; has int32 $.texf3; has int32 $.texf4; has int32 $.texf5; has int32 $.texf6; has int32 $.texf7; has int32 $.texf8; has int32 $.texf9; has int32 $.texf10; has int32 $.texf11; has int32 $.texf12; has int32 $.texf13; has int32 $.texf14; has int32 $.texf15; has int32 $.texf16;
    has int32 $.max_texture_width;
    has int32 $.max_texture_height;
}

enum SDL_RendererFlags is export (
    :SOFTWARE(1),
    :ACCELERATED(2),
    :PRESENTVSYNC(4),
    :TARGETTEXTURE(8),
);

enum SDL_TextureAccess is export <
    STATIC
    STREAMING
    TARGET
>;

enum SDL_TextureModulate is export <
    TEXTURE_MODULATE_NONE
    COLOR
    ALPHA
>;

enum SDL_RendererFlip is export <
    RENDERER_FLIP_NONE
    HORIZONTAL
    VERTICAL
>;

enum SDL_BlendMode is export <
    BLENDMODE_NONE
    BLENDMODE_BLEND
    BLENDMODE_ADD
    BLENDMODE_MOD
>;

class SDL_Renderer is export is repr('CPointer') { }

class SDL_Texture is export is repr('CPointer') { }

class SDL_Surface is export is repr('CPointer') { }

class SDL_GLContext is export is repr('CPointer') { }

sub SDL_GetNumRenderDrivers()
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_GetRenderDriverInfo(int32 $index, SDL_RendererInfo $info)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_CreateWindowAndRenderer(int32 $width, int32 $height,
                                int32 $flags,
                                Pointer[SDL_Window] $win, Pointer[SDL_Renderer] $renderer)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_CreateRenderer(SDL_Window $win, int32 $index, int32 $flags)
        returns SDL_Renderer
        is native($lib)
        is export
        {*}

sub SDL_GetRendererInfo(SDL_Renderer $renderer, SDL_RendererInfo $info)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_CreateTexture(SDL_Renderer $renderer, int32 $format, int32 $access, int32 $w, int32 $h)
        returns SDL_Texture
        is native($lib)
        is export
        {*}

sub SDL_SetRenderTarget(SDL_Renderer $renderer, SDL_Texture $texture)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_UpdateTexture(SDL_Texture $tex, SDL_Rect $rect, Pointer $data, int32 $pitch)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_LockTexture(SDL_Texture $tex, SDL_Rect $rect, Pointer[int64] $pixdata, int32 $pitch is rw)
        returns int32
        is native($lib)
        is export
        {*}
sub SDL_UnlockTexture(SDL_Texture $tex)
        is native($lib)
        is export
        {*}

sub SDL_SetTextureBlendMode(SDL_Texture $tex, int32 $blendmode)
        returns int32
        is native($lib)
        is export
        {*}
sub SDL_GetTextureBlendMode(SDL_Texture $tex, Pointer[int32] $blendmode)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_SetTextureAlphaMod(SDL_Texture $tex, uint8 $alpha)
        returns int32
        is native($lib)
        is export
        {*}
sub SDL_GetTextureAlphaMod(SDL_Texture $tex, uint8 $alpha is rw)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_SetTextureColorMod(SDL_Texture $tex,
            uint8 $r,
            uint8 $g,
            uint8 $b)
        returns int32
        is native($lib)
        is export
        {*}
sub SDL_GetTextureColorMod(SDL_Texture $tex,
            uint8 $r is rw,
            uint8 $g is rw,
            uint8 $b is rw)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_CreateTextureFromSurface(SDL_Renderer $renderer, SDL_Surface $surface )
        returns SDL_Texture
        is native($lib)
        is export
        {*}

sub SDL_RenderSetLogicalSize(SDL_Renderer $renderer, int32 $w, int32 $h)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_RenderGetLogicalSize(SDL_Renderer $renderer, Pointer[int32] $w, Pointer[int32] $h)
        is native($lib)
        is export {*}

sub SDL_SetRenderDrawColor(SDL_Renderer $renderer, int8 $r, int8 $g, int8 $b, int8 $a)
        returns int32
        is native($lib)
        is export
        {*}

sub SDL_GetRenderDrawColor(SDL_Renderer $renderer, Pointer[uint8] $r, Pointer[uint8] $g, Pointer[uint8] $b, Pointer[uint8] $a) returns int32 is native($lib) is export {*}

sub SDL_SetRenderDrawBlendMode(SDL_Renderer $renderer, int32 $blendmode)
        is native($lib)
        returns int32
        is export
        {*}

sub SDL_RenderCopy(SDL_Renderer $renderer, SDL_Texture $src, SDL_Rect $srcrect, SDL_Rect $destrect) returns int32 is native($lib) is export {*}
sub SDL_RenderCopyEx(SDL_Renderer $renderer, SDL_Texture $src, SDL_Rect $srcrect, SDL_Rect $destrect, num64 $angle, SDL_Point $center, int32 $flip) returns int32 is native($lib) is export {*}

sub SDL_RenderClear(SDL_Renderer $renderer) returns int32 is native($lib) is export {*}
sub SDL_RenderPresent(SDL_Renderer $renderer) is native($lib) is export {*}

sub SDL_RenderDrawPoint(SDL_Renderer $renderer, int32 $x, int32 $y) returns int32 is native($lib) is export {*}
sub SDL_RenderDrawLine(SDL_Renderer $renderer, int32 $x, int32 $y, int32 $x2, int32 $y2) returns int32 is native($lib) is export {*}

sub SDL_RenderDrawRect(SDL_Renderer $renderer, SDL_Rect $rect) returns int32 is native($lib) is export {*}
sub SDL_RenderFillRect(SDL_Renderer $renderer, SDL_Rect $rect) returns int32 is native($lib) is export {*}

sub SDL_DestroyTexture(SDL_Texture $texture) is native($lib) is export {*}
sub SDL_DestroyRenderer(SDL_Renderer $renderer) is native($lib) is export {*}

sub SDL_VideoInit(Str $drivername) returns int32 is native($lib) is export {*}
sub SDL_VideoQuit() is native($lib) is export {*}

sub SDL_GetNumVideoDrivers() returns int32 is native($lib) is export {*}
sub SDL_GetVideoDriver(int32 $index) returns Str is native($lib) is export {*}
sub SDL_GetCurrentVideoDriver() returns Str is native($lib) is export {*}

sub SDL_GetNumVideoDisplays() returns int32 is native($lib) is export {*}
sub SDL_GetDisplayName(int32 $index) returns Str is native($lib) is export {*}
sub SDL_GetDisplayBounds(int32 $index, SDL_Rect $rect) returns int32 is native($lib) is export {*}

sub SDL_CreateWindow(Str $title, int32 $x, int32 $y, int32 $w, int32 $h, int32 $flags) returns SDL_Window is native($lib) is export {*}
sub SDL_DestroyWindow(SDL_Window $win) is native($lib) is export {*}
sub SDL_SetWindowTitle(SDL_Window $window, Str $title) is native($lib) is export {*}
sub SDL_GetWindowTitle(SDL_Window $window) returns Str is native($lib) is export {*}

sub SDL_UpdateWindowSurface(SDL_Window $window) returns int32 is native($lib) is export {*}

sub SDL_SetWindowGrab(SDL_Window $window, int32 $grabbed) is native($lib) is export {*}
sub SDL_GetWindowGrab(SDL_Window $window) returns int32 is native($lib) is export {*}

sub SDL_LoadBMP(Str $path) returns SDL_Surface is native($lib) is export {*}
sub SDL_SaveBMP(SDL_Surface $surf, Str $file) returns int32 is native($lib) is export {*}

enum SDL_EventType is export (
   FIRSTEVENT     => 0,

   QUIT           => 0x100,

   "APP_TERMINATING",
   "APP_LOWMEMORY",
   "APP_WILLENTERBACKGROUND",
   "APP_DIDENTERBACKGROUND",
   "APP_WILLENTERFOREGROUND",
   "APP_DIDENTERFOREGROUND",

   WINDOWEVENT    => 0x200,
   "SYSWMEVENT",

   KEYDOWN        => 0x300,
   "KEYUP",
   "TEXTEDITING",
   "TEXTINPUT",

   MOUSEMOTION    => 0x400,
   "MOUSEBUTTONDOWN",
   "MOUSEBUTTONUP",
   "MOUSEWHEEL",

   JOYAXISMOTION  => 0x600,
   "JOYBALLMOTION",
   "JOYHATMOTION",
   "JOYBUTTONDOWN",
   "JOYBUTTONUP",
   "JOYDEVICEADDED",
   "JOYDEVICEREMOVED",

   CONTROLLERAXISMOTION  => 0x650,
   "CONTROLLERBUTTONDOWN",
   "CONTROLLERBUTTONUP",
   "CONTROLLERDEVICEADDED",
   "CONTROLLERDEVICEREMOVED",
   "CONTROLLERDEVICEREMAPPED",

   FINGERDOWN      => 0x700,
   "FINGERUP",
   "FINGERMOTION",

   DOLLARGESTURE   => 0x800,
   "DOLLARRECORD",
   "MULTIGESTURE",

   CLIPBOARDUPDATE => 0x900,

   DROPFILE        => 0x1000,

   RENDER_TARGETS_RESET => 0x2000,
   "RENDER_DEVICE_RESET",

   USEREVENT    => 0x8000,

   LASTEVENT    => 0xFFFF,
);

class SDL_Event is export is repr('CStruct') is rw {
    has uint32 $.type;
    has uint32 $.timestamp;
    has int64  $.dummy1;
    has int64  $.dummy2;
    has int64  $.dummy3;
    has int64  $.dummy4;
    has int64  $.dummy5;
    has int64  $.dummy6;
}

class SDL_WindowEvent is export is repr('CStruct') is rw {
   has uint32 $.type;
   has uint32 $.timestamp;
   has uint32 $.windowID;
   has uint8  $.event;
   has uint8  $.padding1;
   has uint8  $.padding2;
   has uint8  $.padding3;
   has int32  $.data1;
   has int32  $.data2;
}

class SDL_KeyboardEvent is export is repr('CStruct') is rw {
   has uint32 $.type;
   has uint32 $.timestamp;
   has uint32 $.windowID;
   has uint8  $.state;
   has uint8  $.repeat;
   has int32  $.scancode;
   has int32  $.sym;
   has uint16  $.mod;
}

class SDL_MouseMotionEvent is export is repr('CStruct') is rw {
    has uint32 $.type;
    has uint32 $.timestamp;
    has uint32 $.windowID;
    has uint32 $.which;
    has uint32 $.state;
    has int32  $.x;
    has int32  $.y;
    has int32  $.xrel;
    has int32  $.yrel;
}

class SDL_MouseButtonEvent is export is repr('CStruct') is rw {
    has uint32 $.type;
    has uint32 $.timestamp;
    has uint32 $.windowID;
    has uint32 $.which;
    has uint8  $.button;
    has uint8  $.state;
    has uint8  $.clicks;
    has uint8  $.padding1;
    has int32  $.x;
    has int32  $.y;
}

class SDL_MouseWheelEvent is export is repr('CStruct') is rw {
    has uint32 $.type;
    has uint32 $.timestamp;
    has uint32 $.windowID;
    has uint32 $.which;
    has int32  $.x;
    has int32  $.y;
}

sub SDL_PollEvent(SDL_Event $event) returns int32 is native($lib) is export {*}
sub SDL_WaitEvent(SDL_Event $event) returns int32 is native($lib) is export {*}
sub SDL_WaitEventTimeout(SDL_Event $event, int32 $timeout) returns int32 is native($lib) is export {*}

sub SDL_CastEvent(SDL_Event $event) is export {
    given $event.type {
        when WINDOWEVENT {
            nativecast(SDL_WindowEvent, $event)
        }
        when KEYDOWN | KEYUP {
            nativecast(SDL_KeyboardEvent, $event)
        }
        when MOUSEBUTTONUP | MOUSEBUTTONDOWN {
            nativecast(SDL_MouseButtonEvent, $event)
        }
        when MOUSEMOTION {
            nativecast(SDL_MouseMotionEvent, $event)
        }
        when MOUSEWHEEL {
            nativecast(SDL_MouseWheelEvent, $event)
        }
        default {
            $event
        }
    }
}

sub SDL_GetKeyboardState(int32 $numkeys is rw) returns CArray[uint8] is native($lib) is export {*}

our constant SDL_QUERY   = -1;
our constant SDL_IGNORE  =  0;
our constant SDL_DISABLE =  0;
our constant SDL_ENABLE  =  1;

sub SDL_EventState(int32 $type, int32 $state) returns uint8 is native($lib) is export {*}


sub SDL_GetError returns Str is native($lib) is export {*}

sub SDL_ClearError is native($lib) is export {*}

enum SDL_LogCategory is export <
        SDL_LOG_CATEGORY_APPLICATION
        SDL_LOG_CATEGORY_ERROR
        SDL_LOG_CATEGORY_ASSERT
        SDL_LOG_CATEGORY_SYSTEM
        SDL_LOG_CATEGORY_AUDIO
        SDL_LOG_CATEGORY_VIDEO
        SDL_LOG_CATEGORY_RENDER
        SDL_LOG_CATEGORY_INPUT
        SDL_LOG_CATEGORY_TEST

        SDL_LOG_CATEGORY_RESERVED1
        SDL_LOG_CATEGORY_RESERVED2
        SDL_LOG_CATEGORY_RESERVED3
        SDL_LOG_CATEGORY_RESERVED4
        SDL_LOG_CATEGORY_RESERVED5
        SDL_LOG_CATEGORY_RESERVED6
        SDL_LOG_CATEGORY_RESERVED7
        SDL_LOG_CATEGORY_RESERVED8
        SDL_LOG_CATEGORY_RESERVED9
        SDL_LOG_CATEGORY_RESERVED10

        SDL_LOG_CATEGORY_CUSTOM
    >;

enum SDL_LogPriority is export (
       SDL_LOG_PRIORITY_VERBOSE => 1,
       'SDL_LOG_PRIORITY_DEBUG',
       'SDL_LOG_PRIORITY_INFO',
       'SDL_LOG_PRIORITY_WARN',
       'SDL_LOG_PRIORITY_ERROR',
       'SDL_LOG_PRIORITY_CRITICAL',
       'SDL_NUM_LOG_PRIORITIE',
   );

sub SDL_LogSetAllPriority(uint64 $priority) is native($lib) is export {*}

sub SDL_LogSetPriority(int32 $category, uint64 $priority) is native($lib) is export {*}

my sub _pxfmt($type, $order, $layout, $bits, $bytes) {
    (1 +< 28) +| ($type +< 24) +| ($order +< 20) +| ($layout +< 16) +| ($bits +< 8) +| $bytes
}

enum SDL_Pixeltype is export <
        PIXELTYPE_UNKNOWN
        PIXELTYPE_INDEX1
        PIXELTYPE_INDEX4
        PIXELTYPE_INDEX8
        PIXELTYPE_PACKED8
        PIXELTYPE_PACKED16
        PIXELTYPE_PACKED32
        PIXELTYPE_ARRAYU8
        PIXELTYPE_ARRAYU16
        PIXELTYPE_ARRAYU32
        PIXELTYPE_ARRAYF16
        PIXELTYPE_ARRAYF32
    >;


enum SDL_BitmapOrder is export <
        BITMAPORDER_NONE
        BITMAPORDER_4321
        BITMAPORDER_1234
    >;

enum SDL_PackedOrder is export <
        PACKEDORDER_NONE
        PACKEDORDER_XRGB
        PACKEDORDER_RGBX
        PACKEDORDER_ARGB
        PACKEDORDER_RGBA
        PACKEDORDER_XBGR
        PACKEDORDER_BGRX
        PACKEDORDER_ABGR
        PACKEDORDER_BGRA
    >;

enum SDL_ArrayOrder is export <
        ARRAYORDER_NONE
        ARRAYORDER_RGB
        ARRAYORDER_RGBA
        ARRAYORDER_ARGB
        ARRAYORDER_BGR
        ARRAYORDER_BGRA
        ARRAYORDER_ABGR
    >;

enum SDL_PackedLayout is export <
        PACKEDLAYOUT_NONE
        PACKEDLAYOUT_332
        PACKEDLAYOUT_4444
        PACKEDLAYOUT_1555
        PACKEDLAYOUT_5551
        PACKEDLAYOUT_565
        PACKEDLAYOUT_8888
        PACKEDLAYOUT_2101010
        PACKEDLAYOUT_1010102
    >;

our %PIXELFORMAT is export = (
        UNKNOWN => 0,
        INDEX1LSB =>
            _pxfmt(PIXELTYPE_INDEX1, BITMAPORDER_4321, 0,
                                   1, 0),
        INDEX1MSB =>
            _pxfmt(PIXELTYPE_INDEX1, BITMAPORDER_1234, 0,
                                   1, 0),
        INDEX4LSB =>
            _pxfmt(PIXELTYPE_INDEX4, BITMAPORDER_4321, 0,
                                   4, 0),
        INDEX4MSB =>
            _pxfmt(PIXELTYPE_INDEX4, BITMAPORDER_1234, 0,
                                   4, 0),
        INDEX8 =>
            _pxfmt(PIXELTYPE_INDEX8, 0, 0, 8, 1),
        RGB332 =>
            _pxfmt(PIXELTYPE_PACKED8, PACKEDORDER_XRGB,
                                   PACKEDLAYOUT_332, 8, 1),
        RGB444 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_XRGB,
                                   PACKEDLAYOUT_4444, 12, 2),
        RGB555 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_XRGB,
                                   PACKEDLAYOUT_1555, 15, 2),
        BGR555 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_XBGR,
                                   PACKEDLAYOUT_1555, 15, 2),
        ARGB4444 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_ARGB,
                                   PACKEDLAYOUT_4444, 16, 2),
        RGBA4444 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_RGBA,
                                   PACKEDLAYOUT_4444, 16, 2),
        ABGR4444 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_ABGR,
                                   PACKEDLAYOUT_4444, 16, 2),
        BGRA4444 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_BGRA,
                                   PACKEDLAYOUT_4444, 16, 2),
        ARGB1555 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_ARGB,
                                   PACKEDLAYOUT_1555, 16, 2),
        RGBA5551 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_RGBA,
                                   PACKEDLAYOUT_5551, 16, 2),
        ABGR1555 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_ABGR,
                                   PACKEDLAYOUT_1555, 16, 2),
        BGRA5551 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_BGRA,
                                   PACKEDLAYOUT_5551, 16, 2),
        RGB565 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_XRGB,
                                   PACKEDLAYOUT_565, 16, 2),
        BGR565 =>
            _pxfmt(PIXELTYPE_PACKED16, PACKEDORDER_XBGR,
                                   PACKEDLAYOUT_565, 16, 2),
        RGB24 =>
            _pxfmt(PIXELTYPE_ARRAYU8, ARRAYORDER_RGB, 0,
                                   24, 3),
        BGR24 =>
            _pxfmt(PIXELTYPE_ARRAYU8, ARRAYORDER_BGR, 0,
                                   24, 3),
        RGB888 =>
            _pxfmt(PIXELTYPE_PACKED32, PACKEDORDER_XRGB,
                                   PACKEDLAYOUT_8888, 24, 4),
        RGBX8888 =>
            _pxfmt(PIXELTYPE_PACKED32, PACKEDORDER_RGBX,
                                   PACKEDLAYOUT_8888, 24, 4),
        BGR888 =>
            _pxfmt(PIXELTYPE_PACKED32, PACKEDORDER_XBGR,
                                   PACKEDLAYOUT_8888, 24, 4),
        BGRX8888 =>
            _pxfmt(PIXELTYPE_PACKED32, PACKEDORDER_BGRX,
                                   PACKEDLAYOUT_8888, 24, 4),
        ARGB8888 =>
            _pxfmt(PIXELTYPE_PACKED32, PACKEDORDER_ARGB,
                                   PACKEDLAYOUT_8888, 32, 4),
        RGBA8888 =>
            _pxfmt(PIXELTYPE_PACKED32, PACKEDORDER_RGBA,
                                   PACKEDLAYOUT_8888, 32, 4),
        ABGR8888 =>
            _pxfmt(PIXELTYPE_PACKED32, PACKEDORDER_ABGR,
                                   PACKEDLAYOUT_8888, 32, 4),
        BGRA8888 =>
            _pxfmt(PIXELTYPE_PACKED32, PACKEDORDER_BGRA,
                                   PACKEDLAYOUT_8888, 32, 4),
        ARGB2101010 =>
            _pxfmt(PIXELTYPE_PACKED32, PACKEDORDER_ARGB,
                                   PACKEDLAYOUT_2101010, 32, 4),
   );

enum SDL_GLAttr is export <
    RED_SIZE
    GREEN_SIZE
    BLUE_SIZE
    ALPHA_SIZE
    BUFFER_SIZE
    DOUBLEBUFFER
    DEPTH_SIZE
    STENCIL_SIZE
    ACCUM_RED_SIZE
    ACCUM_GREEN_SIZE
    ACCUM_BLUE_SIZE
    ACCUM_ALPHA_SIZE
    STEREO
    MULTISAMPLEBUFFERS
    MULTISAMPLESAMPLES
    ACCELERATED_VISUAL
    RETAINED_BACKING
    CONTEXT_MAJOR_VERSION
    CONTEXT_MINOR_VERSION
    CONTEXT_EGL
    CONTEXT_FLAGS
    CONTEXT_PROFILE_MASK
    SHARE_WITH_CURRENT_CONTEXT
    FRAMEBUFFER_SRGB_CAPABLE
>;

enum SDL_GLProfile is export (
    :CONTEXT_PROFILE_CORE(0x0001),
    :CONTEXT_PROFILE_COMPATIBILITY(0x0002),
    :CONTEXT_PROFILE_ES(0x0004)
);

# GL Functions
sub SDL_GL_BindTexture(SDL_Texture $texture, Pointer[num32] $texw, Pointer[num32] $texh) returns int32 is native($lib) is export {*}
sub SDL_GL_UnBindTexture(SDL_Texture $texture) returns int32 is native($lib) is export {*}

sub SDL_GL_CreateContext(SDL_Window $window) returns SDL_GLContext is native($lib) is export {*}
sub SDL_GL_DeleteContext(SDL_GLContext $context) is native($lib) is export {*}
sub SDL_GL_MakeCurrent(SDL_Window $window, SDL_GLContext $context) returns int32 is native($lib) is export {*}

sub SDL_GL_SetAttribute(int32 $attr, int32 $value) returns int32 is native($lib) is export {*}
sub SDL_GL_SwapWindow(SDL_Window $window) is native($lib) is export {*}

sub SDL_RenderDrawPoints( SDL_Renderer $, CArray[int32] $points, int32 $count )
  returns int32 is native($lib) is export {*}
