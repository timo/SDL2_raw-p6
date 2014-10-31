use NativeCall;

class SDL_Point is repr('CStruct') {
    has int $.x;
    has int $.y;
}

class SDL_Rect is repr('CStruct') {
    has int $.x;
    has int $.y;
    has int $.w;
    has int $.h;
}
class SDL_DisplayMode is repr('CStruct') {
    has uint32 $.format;
    has int    $.w;
    has int    $.h;
    has int    $.refresh_rate;
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

sub SDL_Init(int32 $flags) is native('libSDL2') is export {*}
sub SDL_Quit() is native('libSDL2') is export {*}

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
    'NONE',           # Never used
    'SHOWN',          # Window has been shown
    'HIDDEN',         # Window has been hidden
    'EXPOSED',        # Window has been exposed and should be redrawn
    'MOVED',          # Window has been moved to data1', data2
    'RESIZED',        # Window has been resized to data1xdata2
    'SIZE_CHANGED',   # The window size has changed', either as a result of an API call or through the system or user changing the window size.
    'MINIMIZED',      # Window has been minimized
    'MAXIMIZED',      # Window has been maximized
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
    has int $.max_texture_width;
    has int $.max_texture_height;
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
    NONE
    COLOR
    ALPHA
>;

enum SDL_RendererFlip <
    NONE
    HORIZONTAL
    VERTICAL
>;

class SDL_Renderer is repr('CPointer') { }

class SDL_Texture is repr('CPointer') { }

sub SDL_GetNumRenderDrivers returns int is native('libSDL2') is export {*}
sub SDL_GetRenderDriverInfo(int $index, SDL_RendererInfo $info) returns int is native('libSDL2') is export {*}

sub SDL_CreateWindowAndRenderer(int $width, int $height,
                                uint32 $flags,
                                SDL_Window $win, SDL_Renderer $renderer)
                        returns int is native('libSDL2') is export {*}

sub SDL_CreateRenderer(SDL_Window $win, int $index, uint32 $flags) returns SDL_Renderer is native('libSDL2') is export {*}

sub SDL_SetTextureBlendMode(SDL_Texture $tex, int $blendmode) returns int is native('libSDL2') is export {*}
sub SDL_GetTextureBlendMode(SDL_Texture $tex, CArray[int] $blendmode) returns int is native('libSDL2') is export {*}

sub SDL_RenderSetLogicalSize(SDL_Renderer $renderer, int $w, int $h) returns int is native('libSDL2') is export {*}
sub SDL_RenderGetLogicalSize(SDL_Renderer $renderer, CArray[int] $w, CArray[int] $h) is native('libSDL2') is export {*}

sub SDL_SetRenderDrawColor(SDL_Renderer $renderer, uint8 $r, uint8 $g, uint8 $b, uint8 $a) returns int is native('libSDL2') is export {*}
sub SDL_GetRenderDrawColor(SDL_Renderer $renderer, CArray[uint8] $r, CArray[uint8] $g, CArray[uint8] $b, CArray[uint8] $a) returns int is native('libSDL2') is export {*}

sub SDL_RenderCopy(SDL_Renderer $renderer, SDL_Texture $src, SDL_Rect $srcrect, SDL_Rect $destrect) returns int is native('libSDL2') is export {*}
sub SDL_RenderCopyEx(SDL_Renderer $renderer, SDL_Texture $src, SDL_Rect $srcrect, SDL_Rect $destrect, num $angle, SDL_Point $center, int $flip) returns int is native('libSDL2') is export {*}

sub SDL_RenderPresent(SDL_Renderer $renderer) is native('libSDL2') is export {*}


sub SDL_DestroyTexture(SDL_Texture $texture) is native('libSDL2') is export {*}
sub SDL_DestroyRenderer(SDL_Renderer $renderer) is native('libSDL2') is export {*}

sub SDL_GL_BindTexture(SDL_Texture $texture, CArray[num] $texw, CArray[num] $texh) returns int is native('libSDL2') is export {*}
sub SDL_GL_UnBindTexture(SDL_Texture $texture) returns int is native('libSDL2') is export {*}
sub SDL_VideoInit(Str $drivername) returns int is native('libSDL2') is export {*}
sub SDL_VideoQuit() is native('libSDL2') is export {*}

sub SDL_GetNumVideoDrivers() returns int is native('libSDL2') is export {*}
sub SDL_GetVideoDriver(int $index) returns Str is native('libSDL2') is export {*}
sub SDL_GetCurrentVideoDriver() returns Str is native('libSDL2') is export {*}

sub SDL_GetNumVideoDisplays() returns int is native('libSDL2') is export {*}
sub SDL_GetDisplayName(int $index) returns Str is native('libSDL2') is export {*}
sub SDL_GetDisplayBounds(int $index, SDL_Rect $rect) returns int is native('libSDL2') is export {*}

sub SDL_CreateWindow(Str $title, int $x, int $y, int $w, int $h, uint32 $flags) returns SDL_Window is native('libSDL2') is export {*}
sub SDL_SetWindowTitle(SDL_Window $window, Str $title) returns Str is native('libSDL2') is export {*}
sub SDL_GetWindowTitle(SDL_Window $window) returns Str is native('libSDL2') is export {*}

sub SDL_UpdateWindowSurface(SDL_Window $window) returns int is native('libSDL2') is export {*}

sub SDL_SetWindowGrab(SDL_Window $window, int $grabbed) is native('libSDL2') is export {*}
sub SDL_GetWindowGrab(SDL_Window $window) returns int is native('libSDL2') is export {*}
