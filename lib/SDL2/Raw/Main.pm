use NativeCall;

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

sub SDL_Init(uint32 $flags) is native('libSDL-2.0') {*}
sub SDL_Quit() is native('libSDL-2.0') {*}
