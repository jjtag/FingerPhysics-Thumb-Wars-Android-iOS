/*
 */

#ifndef __PngDecoder_h__
#define __PngDecoder_h__

#include "basetypes.h"

#undef PNG_CHECK_CRC

#include "inflate.h"

class ImageData
{
private:
	uchar* data;
	int width;
	int height;

public:
	ImageData(uchar* d, int w, int h) : data(d), width(w), height(h) {}
	~ImageData() { delete[] data; }

	uchar* getData() { return data; }
	int getWidth() { return width; }
	int getHeight() { return height; }
};

class PngDecoder
{
public:
    PngDecoder();
    ~PngDecoder();

    ImageData* DecodeImage(uchar* data);

private:
    static const uchar cSignature[];

    static const uint cIHDR = uint('I') | (uint('H') << 8) | (uint('D') << 16) | (uint('R') << 24);
    static const uint cPLTE = uint('P') | (uint('L') << 8) | (uint('T') << 16) | (uint('E') << 24);
    static const uint cIDAT = uint('I') | (uint('D') << 8) | (uint('A') << 16) | (uint('T') << 24);
    static const uint cIEND = uint('I') | (uint('E') << 8) | (uint('N') << 16) | (uint('D') << 24);
    static const uint ctRNS = uint('t') | (uint('R') << 8) | (uint('N') << 16) | (uint('S') << 24);

    Inflate* m_inflate;
#ifdef PNG_CHECK_CRC
    uint m_crcTable[256];
#endif
};

#endif // __PngDecoder_h__
