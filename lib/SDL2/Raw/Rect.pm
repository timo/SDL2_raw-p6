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
