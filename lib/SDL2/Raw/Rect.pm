use NativeCall;

class SDL::Point is repr('CStruct') {
    has int $.x;
    has int $.y;
}

class SDL::Rect is repr('CStruct') {
    has int $.x;
    has int $.y;
    has int $.w;
    has int $.h;
}
