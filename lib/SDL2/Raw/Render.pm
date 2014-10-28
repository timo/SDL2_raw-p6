use NativeCall;

use SDL2::Raw::Video;

class SDL_RendererInfo is repr('CStruct') {
    has Str $.name;
    has uint32 $.flags;
    has uint32 $.num_texture_formats;
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

sub SDL_GetNumRenderDrivers returns int is native('libSDL-2.0') {*}
sub SDL_GetRenderDriverInfo(int $index, CArray[SDL_RendererInfo] $info) returns int is native('libSDL-2.0') {*}

sub SDL_CreateWindowAndRenderer(int $width, int $height,
                                uint32 $flags,
                                CArray[SDL_Window] $win, CArray[SDL_Renderer] $renderer)
                        returns int is native('libSDL-2.0') {*}

sub SDL_CreateRenderer(SDL_Window $win, int $index, uint32 $flags) returns SDL_Renderer is native('libSDL-2.0') {*}

sub SDL_SetTextureBlendMode(SDL_Texture $tex, int $blendmode) returns int is native('libSDL-2.0') {*}
sub SDL_GetTextureBlendMode(SDL_Texture $tex, CArray[int] $blendmode) returns int is native('libSDL-2.0') {*}

sub SDL_RenderSetLogicalSize(SDL_Renderer $renderer, int $w, int $h) returns int is native('libSDL-2.0') {*}
sub SDL_RenderGetLogicalSize(SDL_Renderer $renderer, CArray[int] $w, CArray[int] $h) is native('libSDL-2.0') {*}

sub SDL_SetRenderDrawColor(SDL_Renderer $renderer, uint8 $r, uint8 $g, uint8 $b, uint8 $a) returns int is native('libSDL-2.0') {*}
sub SDL_GetRenderDrawColor(SDL_Renderer $renderer, CArray[uint8] $r, CArray[uint8] $g, CArray[uint8] $b, CArray[uint8] $a) returns int is native('libSDL-2.0') {*}

sub SDL_RenderCopy(SDL_Renderer $renderer, SDL_Texture $src, SDL_Rect $srcrect, SDL_Rect $destrect) returns int is native('libSDL-2.0') {*}
sub SDL_RenderCopyEx(SDL_Renderer $renderer, SDL_Texture $src, SDL_Rect $srcrect, SDL_Rect $destrect, num $angle, CArray[SDL_Point] $center, int $flip) returns int is native('libSDL-2.0') {*}

sub SDL_RenderPresent(SDL_Renderer $renderer) is native('libSDL-2.0') {*}


sub SDL_DestroyTexture(SDL_Texture $texture) is native('libSDL-2.0') {*}
sub SDL_DestroyRenderer(SDL_Renderer $renderer) is native('libSDL-2.0') {*}

sub SDL_GL_BindTexture(SDL_Texture $texture, CArray[num] $texw, CArray[num] $texh) returns int is native('libSDL-2.0') {*}
sub SDL_GL_UnBindTexture(SDL_Texture $texture) returns int is native('libSDL-2.0') {*}
