/*
 */

#include "pngdecoder.h"
#include "inflate.h"
#include "string.h"
#include "../log.h"

#define MemoryCopy(a, b, c) memcpy(a, b, c)

#define TRACE_PNG(args...) _LOG(args)
#define ASSERT(x)

#define PIXEL_DISABLE_4BITINDEXED_ENABLED
#define PIXEL_NO_COLOR_TABLE_REORDER

#define CHECKMEM(x) { if (!x) _LOG("ERROR IN PNG DECODER - NO MEMORY !!!"); }

typedef unsigned short u16;
typedef unsigned char u8;
typedef unsigned int u32;

inline static int Abs(int a)
{
    return (a < 0) ? (-a) : a;
}

//--------------------------------------------------------------------------------------------

const uchar PngDecoder::cSignature[] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00};

static u16 GetLEUInt16(void* p)
{
    return *(u8*)p + ((*((u8*)p+1))<<8);
}

static u32 GetLEUInt32(void* p)
{
    return GetLEUInt16(p) + (GetLEUInt16((u16*)p + 1)<<16);
}


static uint GetBEUInt32(void* data)
{
    uchar* p = (uchar*)data;
    return (uint(p[0]) << 24) | (uint(p[1]) << 16) | (uint(p[2]) << 8) | uint(p[3]);
}

static int GetBEInt32(void *data)
{
    return (int)GetBEUInt32(data);
}

PngDecoder::PngDecoder() : m_inflate(0)
{
    m_inflate = new Inflate();

#ifdef PNG_CHECK_CRC
    // Create CRC table
    for(int i = 0; i < 256; i++)
    {
        uint c = (uint)i;
        for(int k = 0; k < 8; k++)
        {
            if(c & 1)
                c = 0xedb88320L ^ (c >> 1);
            else
                c = (c >> 1);
        }
        m_crcTable[i] = c;
    }
#endif
}

PngDecoder::~PngDecoder()
{
	delete m_inflate;
}

ImageData* PngDecoder::DecodeImage(uchar* data)
{
    // Checking png signature
    const uchar* sig = cSignature;
    while (*sig)
    {
        if (*sig != *data)
        {
            TRACE_PNG("PNG signature is not valid");
            return 0;
        }
        sig++;
        data++;
    }

    // Parse chunks
    uchar* chunkHeader = 0;
    uchar* chunkPalette = 0;
    uint chunkPaletteLen = 0;
    uchar* chunkTransp = 0;
    uint chunkTranspLen = 0;
    uchar* chunkData = 0;
    uint chunkDataLen = 0;

    uint chunkId = 0;
    do
    {
        uint chunkLen = GetBEUInt32(data);
        data += sizeof(uint);
        chunkId = GetLEUInt32(data);
        data += sizeof(uint);
        uchar* chunk = data;
        data += chunkLen;
        data += sizeof(uint);

        switch (chunkId)
        {
        case cIHDR:
            chunkHeader = chunk;
            break;

        case cPLTE:
            chunkPalette = chunk;
            chunkPaletteLen = chunkLen;
            break;

        case cIDAT:
            if (chunkData)
            {
                MemoryCopy(chunkData + chunkDataLen, chunk, chunkLen);
                chunkDataLen += chunkLen;
            }
            else
            {
                chunkData = chunk;
                chunkDataLen = chunkLen;
            }
            break;

        case cIEND:
            break;

        case ctRNS:
            chunkTransp = chunk;
            chunkTranspLen = chunkLen;
            break;

        default:
            {
                char buf[5];
                buf[0] = (char)chunkId;
                buf[1] = (char)(chunkId >> 8);
                buf[2] = (char)(chunkId >> 16);
                buf[3] = (char)(chunkId >> 24);
                buf[4] = 0;
                TRACE_PNG("Unsupported chunk '%s'. Skipping it", buf);
            }
            break;
        }
    } while (chunkId != cIEND);

    if (!chunkHeader || !chunkData)
    {
        TRACE_PNG("Missing required chunks");
        return 0;
    }

    int width = GetBEInt32(chunkHeader);
    chunkHeader += sizeof(int);
    int height = GetBEInt32(chunkHeader);
    chunkHeader += sizeof(int);
    int bitDepth = *chunkHeader++;
    int colorType = *chunkHeader++;
    int compressMeth = *chunkHeader++;
    int filterMeth = *chunkHeader++;
    int interMeth = *chunkHeader++;

    // Supported color types:
    // 3 - indexed
    // 2 - RGB
    // 6 - RGBA (only if semitransparent is enabled)
    // 4 - greyscale rgba
    if ((colorType != 3 && colorType != 2 && colorType != 6 && colorType != 4)|| compressMeth != 0 || (bitDepth != 8 && bitDepth != 4 && bitDepth != 2 && bitDepth != 1) || filterMeth != 0 || interMeth != 0)
    {
        TRACE_PNG("Wrong png type:");
        TRACE_PNG(" colortype = %i", colorType);
        TRACE_PNG(" compressMeth = %i", compressMeth);
        TRACE_PNG(" bitDepth = %i", bitDepth);
        TRACE_PNG(" filterMeth = %i", filterMeth);
        TRACE_PNG(" interMeth = %i", interMeth);
        return 0;
    }

    bool isTransp = false;
    bool isSemiTransp = false;
    int transpColor = 0;
    if (chunkTransp && chunkTranspLen != 0)
    {
        transpColor = -1;
        for (uint i = 0; i < chunkTranspLen; i++)
        {
            int t = chunkTransp[i];
            if (t == 0 && transpColor == -1)
            {
                transpColor = i;
                t = 255;
            }

            if (t != 255)
            {
                // Semi transparency detected !!!
                isSemiTransp = true;
                transpColor = 0;
                break;
            }
        }
        if (transpColor != -1)
            isTransp = true;
        else
            transpColor = 0;
    }

    uchar* pixels = 0;

	// Create pixels array first...
    uchar* imgPixels = new uchar[width * height * 4]; // Real RGBA

	uint allocSize;
	uint pitch;
	uint dpitch;

	// This is for 4 and less bit bitmaps (?)
	if (bitDepth != 8)
		pitch = (width + 1) >> 1;
	else
		pitch = width;

	if (colorType == 2) // RGB
		pitch *= 3;
	else if (colorType == 6) // RGBA
		pitch *= 4;
	else if (colorType == 4) // greyscale + alpha
		pitch *= 2;

	if (bitDepth != 8)
		dpitch = width;
	else
		dpitch = pitch;

	// Change source pitch for 2bits and 1bits images
	if (bitDepth == 2)
		pitch = (width + 3) >> 2;
	else if (bitDepth == 1)
		pitch = (width + 7) >> 3;

	allocSize = (dpitch + 1) * (height + 1); // we need one more byte per row and one more row for proper decoding

	pixels = new uchar[allocSize];
	CHECKMEM(pixels);

	uchar* depackTo = pixels + allocSize - (pitch + 1) * height;
	ASSERT(depackTo > pixels);

#ifdef DEBUG_ASSERT
	uint depacked =
#endif
	m_inflate->ZLibUncompress(depackTo, chunkData);
	ASSERT((depackTo + depacked) <= (pixels + allocSize));

	uchar* from = depackTo;
	uchar* to = pixels;

	uchar* prevLine = 0;

	uint pixSize;
	switch (colorType)
	{
	case 6: pixSize = 4; break;
	case 2: pixSize = 3; break;
	case 4: pixSize = 2; break;
	default: pixSize = 1; break;
	}

	for (int y = 0; y < height; y++)
	{
		int filter = *from++;

		if (filter != 0)
		{
			if (filter == 1)
			{
				if (colorType == 3)
				{
					for (uint i = 0; i < pitch - 1; i++)
						from[i + 1] += from[i];
				}
				else
				{
					// Apply per channel filter for RGB(A) images
					for (uint k = 0; k < pixSize; k++)
					{
						for (uint i = k; i < (pitch - pixSize); i += pixSize)
							from[i + pixSize] += from[i];
					}
				}
			}
			else if (filter == 2)
			{
				if (prevLine)
				{
					if (colorType == 3)
					{
						for (uint i = 0; i < pitch; i++)
							from[i] += prevLine[i];
					}
					else
					{
						// Apply per channel filter for RGB(A) images
						for (uint k = 0; k < pixSize; k++)
						{
							for (uint i = k; i < pitch; i += pixSize)
								from[i] += prevLine[i];
						}
					}
				}
			}
			else if (filter == 3)
			{
				if (colorType == 3)
				{
					for (uint i = 0; i < pitch; i++)
						from[i] += (int(i > 0 ? from[i - 1] : 0) + int(prevLine ? prevLine[i] : 0)) >> 1;
				}
				else
				{
					// Apply per channel filter for RGB(A) images
					for (uint k = 0; k < pixSize; k++)
					{
						for (uint i = k; i < pitch; i += pixSize)
							from[i] += (int(i >= pixSize ? from[i - pixSize] : 0) + int(prevLine ? prevLine[i] : 0)) >> 1;
					}
				}
			}
			else if (filter == 4)
			{
				if (colorType == 3)
				{
					for (uint i = 0; i < pitch; i++)
					{
						int a = i > 0 ? from[i - 1] : 0;
						int b = prevLine ? prevLine[i] : 0;
						int c = (prevLine && i > 0) ? prevLine[i - 1] : 0;

						int p = a + b - c;
						int pa = Abs(p - a);
						int pb = Abs(p - b);
						int pc = Abs(p - c);

						if (pa <= pb && pa <= pc)
							p = a;
						else if (pb <= pc)
							p = b;
						else
							p = c;

						from[i] += p;
					}
				}
				else
				{
					// Apply per channel filter for RGB(A) images
					for (uint k = 0; k < pixSize; k++)
					{
						for (uint i = k; i < pitch; i += pixSize)
						{
							int a = i >= pixSize ? from[i - pixSize] : 0;
							int b = prevLine ? prevLine[i] : 0;
							int c = (prevLine && i >= pixSize) ? prevLine[i - pixSize] : 0;

							int p = a + b - c;
							int pa = Abs(p - a);
							int pb = Abs(p - b);
							int pc = Abs(p - c);

							if (pa <= pb && pa <= pc)
								p = a;
							else if (pb <= pc)
								p = b;
							else
								p = c;

							from[i] += p;
						}
					}
				}
			}
			else
			{
				TRACE_PNG("Unsupported filter");
				delete[] pixels;
				pixels = 0;
				break;
			}
		}

		prevLine = from;

		uchar* tfrom = 0; // this code may be optimized !!!
		if (bitDepth == 2)
		{
			uchar* xfrom = from;
			uchar* xto = from - dpitch;
			uchar* tto = xto;

			for (int x = 0; x < width; x += 2)
			{
				int v = *from;
				if (x & 2)
				{
					from++;
					*xto++ = (v & 3) | ((v << 2) & 0x30);
				}
				else
				{
					*xto++ = ((v >> 4) & 3) | ((v >> 2) & 0x30);
				}
			}
			tfrom = xfrom + pitch;
			from = tto;
		}
		else if (bitDepth == 1)
		{
			uchar* xfrom = from;
			uchar* xto = from - dpitch;
			uchar* tto = xto;

			for (int x = 0; x < width; x += 2)
			{
				int v = *from;
				if (x & 4)
				{
					if (x & 2)
					{
						from++;
						*xto++ = (v & 1) | ((v << 3) & 0x10);
					}
					else
					{
						*xto++ = ((v >> 2) & 1) | ((v << 1) & 0x10);
					}
				}
				else
				{
					if (x & 2)
					{
						*xto++ = ((v >> 4) & 1) | ((v >> 1) & 0x10);
					}
					else
					{
						*xto++ = ((v >> 6) & 1) | ((v >> 3) & 0x10);
					}
				}
			}
			tfrom = xfrom + pitch;
			from = tto;
		}

		if (bitDepth != 8)
		{
			for (int x = 0; x < width; x++)
			{
				if (x & 1)
					*to++ = *from++ & 0x0f;
				else
					*to++ = *from >> 4;
			}

			if (width & 1)
				from++;
		}
		else
		{
			MemoryCopy(to, from, pitch);
			to += pitch;
			from += pitch;
		}

		if (bitDepth == 2 || bitDepth == 1)
			from = tfrom;
	}

	if (colorType == 3)
	{
		// Indexed data
		u8* pp = pixels;
		u8* pt = imgPixels;

		for (int i = 0; i < height; i++)
		{
			for (int j = 0; j < width; j++)
			{
				uint idx = *pp++;
				u8* pal = chunkPalette + (idx * 3) + 2;
				*pt++ = *pal--;
				*pt++ = *pal--;
				*pt++ = *pal--;

				if (isSemiTransp)
				{
					if (idx < chunkTranspLen)
						*pt++ = chunkTransp[idx];
					else
						*pt++ = 0xff;
				}
				else if (isTransp)
				{
					*pt++ = ((int)idx == transpColor) ? 0 : 0xff;
				}
				else
				{
					*pt++ = 0xff;
				}
			}
		}
	}
	else if (colorType == 4)
	{
		// greyscale(A) data
		u8* pp = pixels;
		u8* pt = imgPixels;

		for (int i = 0; i < height; i++)
		{
			for (int j = 0; j < width; j++)
			{
				u8 c = *pp++;
				*pt++ = c;
				*pt++ = c;
				*pt++ = c;
				*pt++ = *pp++;
			}
		}
	}
	else
	{
		// RGB(A) data
		u8* pp = pixels;
		u8* pt = imgPixels;

		for (int i = 0; i < height; i++)
		{
			for (int j = 0; j < width; j++)
			{
				u8 r = *pp++;
				u8 g = *pp++;
				u8 b = *pp++;
				*pt++ = b;
				*pt++ = g;
				*pt++ = r;

				if (colorType == 6)
					*pt++ = *pp++;
				else
					*pt++ = 0xff;
			}
		}
	}

	delete[] pixels;
	pixels = 0;

    TRACE_PNG("Decoded image %ix%i", width, height);

    return new ImageData(imgPixels, width, height);
}
