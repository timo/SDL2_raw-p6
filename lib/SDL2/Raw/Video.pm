use NativeCall;

use SDL2::Raw::Rect;

class SDL_DisplayMode is repr('CStruct') {
    has uint32 $.format;
    has int    $.w;
    has int    $.h;
    has int    $.refresh_rate;
    has OpaquePointer $.driverdata;
}

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

sub SDL_VideoInit(Str $drivername) returns int is native('libSDL-2.0') {*}
sub SDL_VideoQuit() is native('libSDL-2.0') {*}

sub SDL_GetNumVideoDrivers() returns int is native('libSDL-2.0') {*}
sub SDL_GetVideoDriver(int $index) returns Str is native('libSDL-2.0') {*}
sub SDL_GetCurrentVideoDriver() returns Str is native('libSDL-2.0') {*}

sub SDL_GetNumVideoDisplays() returns int is native('libSDL-2.0') {*}
sub SDL_GetDisplayName(int $index) returns Str is native('libSDL-2.0') {*}
sub SDL_GetDisplayBounds(int $index, CArray[SDL_Rect] $rect) returns int is native('libSDL-2.0') {*}

sub SDL_CreateWindow(Str $title, int $x, int $y, int $w, int $h, uint32 $flags) returns SDL_Window is native('libSDL-2.0') {*}
sub SDL_SetWindowTitle(SDL_Window $window, Str $title) returns Str is native('libSDL-2.0') {*}
sub SDL_GetWindowTitle(SDL_Window $window) returns Str is native('libSDL-2.0') {*}

sub SDL_UpdateWindowSurface(SDL_Window $window) returns int is native('libSDL-2.0') {*}

sub SDL_SetWindowGrab(SDL_Window $window, int $grabbed) is native('libSDL-2.0') {*}
sub SDL_GetWindowGrab(SDL_Window $window) returns int is native('libSDL-2.0') {*}
