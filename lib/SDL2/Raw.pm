use NativeCall;

my Str $lib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $lib = 'SDL2';
    } else {
        $lib = 'libSDL2';
    }
}

class SDL_Point is repr('CStruct') {
    has int32 $.x;
    has int32 $.y;
}

class SDL_Rect is repr('CStruct') {
    has int32 $.x;
    has int32 $.y;
    has int32 $.w;
    has int32 $.h;
}
class SDL_DisplayMode is repr('CStruct') {
    has uint32 $.format;
    has int32    $.w;
    has int32    $.h;
    has int32    $.refresh_rate;
    has OpaquePointer $.driverdata;
}

enum SDL_INIT (
    :TIMER(0x1),
    :AUDIO(0x10),
    :VIDEO(0x20),
    :JOYSTICK(0x200),
    :HAPTIC(0x1000),
    :GAMECONTROLLER(0x2000),
    :EVENTS(0x4000),
    :NOPARACHUTE(0x100000)
);

sub SDL_Init(int32 $flags) is native($lib) is export {*}
sub SDL_Quit() is native($lib) is export {*}

class SDL_Window is repr('CPointer') { }

enum SDL_WindowFlags (
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

enum WindowEventID (
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

our constant SDL_WINDOWPOS_UNDEFINED_MASK = 0x1FFF0000;
our constant SDL_WINDOWPOS_CENTERED_MASK = 0x2FFF0000;

class SDL_RendererInfo is repr('CStruct') {
    has Str $.name;
    has int32 $.flags;
    has int32 $.num_texture_formats;
    # ugly hack because we don't have flattened arrays in cstructs yet
    has int32 $.texf1; has int32 $.texf2; has int32 $.texf3; has int32 $.texf4; has int32 $.texf5; has int32 $.texf6; has int32 $.texf7; has int32 $.texf8; has int32 $.texf9; has int32 $.texf10; has int32 $.texf11; has int32 $.texf12; has int32 $.texf13; has int32 $.texf14; has int32 $.texf15; has int32 $.texf16;
    has int32 $.max_texture_width;
    has int32 $.max_texture_height;
}

enum SDL_RendererFlags (
    :SOFTWARE(1),
    :ACCELERATED(2),
    :PRESENTVSYNC(4),
    :TARGETTEXTURE(8),
);

enum SDL_TextureAccess <
    STATIC
    STREAMING
    TARGET
>;

enum SDL_TextureModulate <
    TEXTURE_MODULATE_NONE
    COLOR
    ALPHA
>;

enum SDL_RendererFlip <
    RENDERER_FLIP_NONE
    HORIZONTAL
    VERTICAL
>;

class SDL_Renderer is repr('CPointer') { }

class SDL_Texture is repr('CPointer') { }

sub SDL_GetNumRenderDrivers()
        returns int
        is native($lib)
        is export
        {*}

sub SDL_GetRenderDriverInfo(int $index, SDL_RendererInfo $info)
        returns int
        is native($lib)
        is export
        {*}

sub SDL_CreateWindowAndRenderer(int $width, int $height,
                                int32 $flags,
                                CArray[SDL_Window] $win, CArray[SDL_Renderer] $renderer)
        returns int
        is native($lib)
        is export
        {*}

sub SDL_CreateRenderer(SDL_Window $win, int $index, int32 $flags)
        returns SDL_Renderer
        is native($lib)
        is export
        {*}

sub SDL_CreateTexture(SDL_Renderer $renderer, int32 $format, int $access, int $w, int $h)
        returns SDL_Texture
        is native($lib)
        is export
        {*}

sub SDL_SetRenderTarget(SDL_Renderer $renderer, SDL_Texture $texture)
        returns int
        is native($lib)
        is export
        {*}

sub SDL_UpdateTexture(SDL_Texture $tex, SDL_Rect $rect, OpaquePointer $data, int32 $pitch)
        returns int
        is native($lib)
        is export
        {*}

sub SDL_SetTextureBlendMode(SDL_Texture $tex, int $blendmode)
        returns int
        is native($lib)
        is export
        {*}

sub SDL_GetTextureBlendMode(SDL_Texture $tex, CArray[int] $blendmode)
        returns int
        is native($lib)
        is export
        {*}

sub SDL_RenderSetLogicalSize(SDL_Renderer $renderer, int $w, int $h)
        returns int
        is native($lib)
        is export
        {*}

sub SDL_RenderGetLogicalSize(SDL_Renderer $renderer, CArray[int] $w, CArray[int] $h)
        is native($lib)
        is export {*}

sub SDL_SetRenderDrawColor(SDL_Renderer $renderer, int8 $r, int8 $g, int8 $b, int8 $a)
        returns int
        is native($lib)
        is export
        {*}

sub SDL_SetTextureColorMod(SDL_Texture $texture, int8 $r, int8 $g, int8 $b) returns int32 is native($lib) is export {*}

sub SDL_GetRenderDrawColor(SDL_Renderer $renderer, CArray[uint8] $r, CArray[uint8] $g, CArray[uint8] $b, CArray[uint8] $a) returns int is native($lib) is export {*}

sub SDL_SetRenderDrawBlendMode(SDL_Renderer $renderer, int $blendmode)
        is native($lib)
        is export
        {*}

sub SDL_RenderCopy(SDL_Renderer $renderer, SDL_Texture $src, SDL_Rect $srcrect, SDL_Rect $destrect) returns int is native($lib) is export {*}
sub SDL_RenderCopyEx(SDL_Renderer $renderer, SDL_Texture $src, SDL_Rect $srcrect, SDL_Rect $destrect, num $angle, SDL_Point $center, int $flip) returns int is native($lib) is export {*}

sub SDL_RenderClear(SDL_Renderer $renderer) returns int is native($lib) is export {*}
sub SDL_RenderPresent(SDL_Renderer $renderer) is native($lib) is export {*}

sub SDL_RenderDrawPoint(SDL_Renderer $renderer, int $x, int $y) returns int is native($lib) is export {*}
sub SDL_RenderDrawLine(SDL_Renderer $renderer, int $x, int $y, int $x2, int $y2) returns int is native($lib) is export {*}

sub SDL_RenderDrawRect(SDL_Renderer $renderer, SDL_Rect $rect) returns int is native($lib) is export {*}
sub SDL_RenderFillRect(SDL_Renderer $renderer, SDL_Rect $rect) returns int is native($lib) is export {*}

sub SDL_DestroyTexture(SDL_Texture $texture) is native($lib) is export {*}
sub SDL_DestroyRenderer(SDL_Renderer $renderer) is native($lib) is export {*}

sub SDL_GL_BindTexture(SDL_Texture $texture, CArray[num] $texw, CArray[num] $texh) returns int is native($lib) is export {*}
sub SDL_GL_UnBindTexture(SDL_Texture $texture) returns int is native($lib) is export {*}

sub SDL_VideoInit(Str $drivername) returns int is native($lib) is export {*}
sub SDL_VideoQuit() is native($lib) is export {*}

sub SDL_GetNumVideoDrivers() returns int is native($lib) is export {*}
sub SDL_GetVideoDriver(int $index) returns Str is native($lib) is export {*}
sub SDL_GetCurrentVideoDriver() returns Str is native($lib) is export {*}

sub SDL_GetNumVideoDisplays() returns int is native($lib) is export {*}
sub SDL_GetDisplayName(int $index) returns Str is native($lib) is export {*}
sub SDL_GetDisplayBounds(int $index, SDL_Rect $rect) returns int is native($lib) is export {*}

sub SDL_CreateWindow(Str $title, int $x, int $y, int $w, int $h, int32 $flags) returns SDL_Window is native($lib) is export {*}
sub SDL_SetWindowTitle(SDL_Window $window, Str $title) returns Str is native($lib) is export {*}
sub SDL_GetWindowTitle(SDL_Window $window) returns Str is native($lib) is export {*}

sub SDL_UpdateWindowSurface(SDL_Window $window) returns int is native($lib) is export {*}

sub SDL_SetWindowGrab(SDL_Window $window, int $grabbed) is native($lib) is export {*}
sub SDL_GetWindowGrab(SDL_Window $window) returns int is native($lib) is export {*}


enum SDL_EventType (
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

class SDL_Event is repr('CStruct') {
    has uint32 $.type;
    has uint32 $.timestamp;
    has int64  $.dummy1;
    has int64  $.dummy2;
    has int64  $.dummy3;
    has int64  $.dummy4;
    has int64  $.dummy5;
    has int64  $.dummy6;
}

class SDL_WindowEvent is repr('CStruct') {
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

class SDL_KeyboardEvent is repr('CStruct') {
   has uint32 $.type;
   has uint32 $.timestamp;
   has uint32 $.windowID;
   has uint8  $.state;
   has uint8  $.repeat;
   has int32  $.scancode;
   has int32  $.sym;
   has uint16  $.mod;
}

class SDL_MouseMotionEvent is repr('CStruct') {
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

class SDL_MouseButtonEvent is repr('CStruct') {
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

class SDL_MouseWheelEvent is repr('CStruct') {
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

our constant SDL_QUERY   = -1;
our constant SDL_IGNORE  =  0;
our constant SDL_DISABLE =  0;
our constant SDL_ENABLE  =  1;

sub SDL_EventState(int32 $type, int32 $state) returns uint8 is native($lib) is export {*}

my sub _pxfmt($type, $order, $layout, $bits, $bytes) {
    (1 +< 28) +| ($type +< 24) +| ($order +< 20) +| ($layout +< 16) +| ($bits +< 8) +| $bytes
}

enum SDL_Pixeltype <
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


enum SDL_BitmapOrder <
        BITMAPORDER_NONE
        BITMAPORDER_4321
        BITMAPORDER_1234
    >;

enum SDL_PackedOrder <
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

enum SDL_ArrayOrder <
        ARRAYORDER_NONE
        ARRAYORDER_RGB
        ARRAYORDER_RGBA
        ARRAYORDER_ARGB
        ARRAYORDER_BGR
        ARRAYORDER_BGRA
        ARRAYORDER_ABGR
    >;

enum SDL_PackedLayout <
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
