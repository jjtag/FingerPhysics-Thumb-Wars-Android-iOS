#include "inflate.h"

#ifdef GZIP_CHECK_CRC
const uint Inflate::cCrc32Tab[16] =
{
    0x00000000, 0x1db71064, 0x3b6e20c8, 0x26d930ac, 0x76dc4190,
    0x6b6b51f4, 0x4db26158, 0x5005713c, 0xedb88320, 0xf00f9344,
    0xd6d6a3e8, 0xcb61b38c, 0x9b64c2b0, 0x86d3d2d4, 0xa00ae278,
    0xbdbdf21c
};
#endif // GZIP_CHECK_CRC

const uchar Inflate::cClcidx[] =
{
    16, 17, 18, 0, 8, 7, 9, 6,
    10, 5, 11, 4, 12, 3, 13, 2,
    14, 1, 15
};

#ifdef INFLATE_CHECK_CRC
uint Inflate::Adler32(const void *data, uint len)
{
    const uchar *buf = (const uchar *)data;

    uint s1 = 1;
    uint s2 = 0;

    while (len > 0)
    {
        int k = len < cA32NMax ? len : cA32NMax;

        for (int i = (k >> 4); i; --i, buf += 16)
        {
            s1 += buf[0];
            s2 += s1;
            s1 += buf[1];
            s2 += s1;
            s1 += buf[2];
            s2 += s1;
            s1 += buf[3];
            s2 += s1;
            s1 += buf[4];
            s2 += s1;
            s1 += buf[5];
            s2 += s1;
            s1 += buf[6];
            s2 += s1;
            s1 += buf[7];
            s2 += s1;
            s1 += buf[8];
            s2 += s1;
            s1 += buf[9];
            s2 += s1;
            s1 += buf[10];
            s2 += s1;
            s1 += buf[11];
            s2 += s1;
            s1 += buf[12];
            s2 += s1;
            s1 += buf[13];
            s2 += s1;
            s1 += buf[14];
            s2 += s1;
            s1 += buf[15];
            s2 += s1;
        }

        for (int i = (k & 0x0f); i; --i)
        {
            s1 += *buf++;
            s2 += s1;
        }

        s1 %= cA32Base;
        s2 %= cA32Base;
        len -= k;
    }
    return (s2 << 16) | s1;
}
#endif // INFLATE_CHECK_CRC

#ifdef GZIP_CHECK_CRC
uint Inflate::Crc32(const void *data, uint len)
{
    const uchar* buf = (const uchar*)data;
    uint crc = 0xffffffff;

    for(int i = 0; i < (int)len; i++)
    {
        crc ^= buf[i];
        crc = cCrc32Tab[crc & 0x0f] ^ (crc >> 4);
        crc = cCrc32Tab[crc & 0x0f] ^ (crc >> 4);
    }
    return crc ^ 0xffffffff;
}
#endif

uint Inflate::GzipUncompress(void* dest, const void* src, uint srcLen)
{
    uchar *xsrc = (uchar* )src;
    uchar *xdest = (unsigned char* )dest;

    // -- check format --

#ifdef INFLATE_SANITY_CHECKS
    // check id bytes
    if (xsrc[0] != 0x1f || xsrc[1] != 0x8b)
        THROW(errDataNotValid);

    // check method is deflate
    if (xsrc[2] != 8)
        THROW(errDataNotValid);
#endif

    // get flag byte
    uchar flg = xsrc[3];

#ifdef INFLATE_SANITY_CHECKS
    // check that reserved bits are zero
    if (flg & 0xe0)
        THROW(errDataNotValid);
#endif

    // -- find start of compressed data --

    // skip base header of 10 bytes
    uchar* start = xsrc + 10;

    // skip extra data if present
    if (flg & cFExtra)
    {
        uint xlen = start[1];
        xlen = 256*xlen + start[0];
        start += xlen + 2;
    }

    // skip file name if present
    if (flg & cFName)
    {
        while (*start)
            ++start;
        ++start;
    }

    // skip file comment if present
    if (flg & cFComment)
    {
        while (*start)
            ++start;
        ++start;
    }

    // check header crc if present
    if (flg & cFHCrc)
    {
#ifdef GZIP_CHECK_CRC
        uint hcrc = start[1];
        hcrc = 256*hcrc + start[0];
        if (hcrc != (Crc32(xsrc, (uint)(start - xsrc) ) & 0x0000ffff))
            THROW(errDataNotValid);
#endif // GZIP_CHECK_CRC

        start += 2;
    }

    // -- get decompressed length --
    uint dlen;
    dlen = xsrc[srcLen - 1];
    dlen = 256*dlen + xsrc[srcLen - 2];
    dlen = 256*dlen + xsrc[srcLen - 3];
    dlen = 256*dlen + xsrc[srcLen - 4];

    // -- get crc32 of decompressed data --
    uint crc32;
    crc32 = xsrc[srcLen - 5];
    crc32 = 256*crc32 + xsrc[srcLen - 6];
    crc32 = 256*crc32 + xsrc[srcLen - 7];
    crc32 = 256*crc32 + xsrc[srcLen - 8];

    // -- decompress data --
    uint resLen = Uncompress(xdest, start);

#ifdef INFLATE_SANITY_CHECKS
    if (resLen != dlen)
        THROW(errDataNotValid);
#endif

    // -- check CRC32 checksum --
#ifdef GZIP_CHECK_CRC
    if (crc32 != Crc32(xdest, dlen))
        THROW(errDataNotValid);
#endif // GZIP_CHECK_CRC

    return resLen;
}

uint Inflate::GetGzipUncompressedSize(void* src, uint srcLen)
{
    uchar* xsrc = (uchar*)src;
    uint dlen;
    dlen = xsrc[srcLen - 1];
    dlen = 256*dlen + xsrc[srcLen - 2];
    dlen = 256*dlen + xsrc[srcLen - 3];
    dlen = 256*dlen + xsrc[srcLen - 4];

    return dlen;
}

//////////////////////////////////////////////////////////////////////////

void Inflate::BuildBitsBase(uchar* bits, ushort *base, int delta, int first)
{
    // build bits table
    for (int i = 0; i < delta; ++i)
        bits[i] = 0;

    for (int i = 0; i < 30 - delta; ++i)
        bits[i + delta] = i / delta;

    // build base table
    int sum = first;
    for (int i = 0; i < 30; ++i)
    {
        base[i] = sum;
        sum += 1 << bits[i];
    }
}

/* build the fixed huffman trees */
void Inflate::BuildFixedTrees(InflateTree *lt, InflateTree *dt)
{
    // build fixed length tree
    for (int i = 0; i < 7; ++i)
        lt->m_table[i] = 0;

    lt->m_table[7] = 24;
    lt->m_table[8] = 152;
    lt->m_table[9] = 112;

    for (int i = 0; i < 24; ++i)
        lt->m_trans[i] = 256 + i;

    for (int i = 0; i < 144; ++i)
        lt->m_trans[24 + i] = i;

    for (int i = 0; i < 8; ++i)
        lt->m_trans[24 + 144 + i] = 280 + i;

    for (int i = 0; i < 112; ++i)
        lt->m_trans[24 + 144 + 8 + i] = 144 + i;

    // build fixed distance tree
    for (int i = 0; i < 5; ++i)
        dt->m_table[i] = 0;

    dt->m_table[5] = 32;

    for (int i = 0; i < 32; ++i)
        dt->m_trans[i] = i;
}

void Inflate::BuildTree(InflateTree* t, const uchar *lengths, uint num)
{
    ushort offs[16];

    // clear code length count table
    for (int i = 0; i < 16; ++i)
        t->m_table[i] = 0;

    // scan symbol lengths, and sum code length counts
    for (int i = 0; i < (int)num; ++i)
        t->m_table[lengths[i]]++;

    t->m_table[0] = 0;

    // compute offset table for distribution sort
    int sum = 0;
    for (int i = 0; i < 16; ++i)
    {
        offs[i] = sum;
        sum += t->m_table[i];
    }

    // create code->symbol translation table (symbols sorted by code)
    for (int i = 0; i < (int)num; ++i)
    {
        if (lengths[i])
            t->m_trans[offs[lengths[i]]++] = i;
    }
}

//////////////////////////////////////////////////////////////////////////

int Inflate::GetBit()
{
    // check if tag is empty
    if (!m_bitcount--)
    {
        /* load next tag */
        m_tag = *m_src++;
        m_bitcount = 7;
    }

    // shift bit out of tag
    int bit = m_tag & 0x01;
    m_tag >>= 1;

    return bit;
}

uint Inflate::ReadBits(int num, int base)
{
    uint val = 0;

    // read num bits
    int limit = 1 << num;
    for (int i = 1; i < limit; i <<= 1)
    {
        if (GetBit())
            val += i;
    }

    return val + base;
}

int Inflate::DecodeSymbol(InflateTree *t)
{
    int sum = 0;
    int cur = 0;
    int len = 0;

    // get more bits while code value is above sum
    do
    {
        cur = 2*cur + GetBit();
        ++len;
        sum += t->m_table[len];
        cur -= t->m_table[len];
    }
    while (cur >= 0);

    return t->m_trans[sum + cur];
}

/* given a data stream, decode dynamic trees from it */
void Inflate::DecodeTrees(InflateTree *lt, InflateTree *dt)
{
    InflateTree* codeTree = lt;

    // get 5 bits HLIT (257-286)
    uint hlit = ReadBits(5, 257);

    // get 5 bits HDIST (1-32)
    uint hdist = ReadBits(5, 1);

    // get 4 bits HCLEN (4-19)
    uint hclen = ReadBits(4, 4);

    for (uint i = 0; i < 19; ++i)
        m_lengths[i] = 0;

    // read code lengths for code length alphabet
    for (uint i = 0; i < hclen; ++i)
    {
        // get 3 bits code length (0-7)
        uint clen = ReadBits(3, 0);
        m_lengths[cClcidx[i]] = clen;
    }

    // build code length tree
    BuildTree(codeTree, m_lengths, 19);

    // decode code lengths for the dynamic trees
    for (uint num = 0; num < hlit + hdist; )
    {
        int sym = DecodeSymbol(codeTree);

        switch (sym)
        {
        case 16:
            // copy previous code length 3-6 times (read 2 bits)
            {
                uchar prev = m_lengths[num - 1];
                for (uint length = ReadBits(2, 3); length; --length)
                    m_lengths[num++] = prev;
            }
            break;

        case 17:
            // repeat code length 0 for 3-10 times (read 3 bits)
            for (uint length = ReadBits(3, 3); length; --length)
                m_lengths[num++] = 0;
            break;

        case 18:
            // repeat code length 0 for 11-138 times (read 7 bits)
            for (uint length = ReadBits(7, 11); length; --length)
                m_lengths[num++] = 0;
            break;

        default:
            // values 0-15 represent the actual code lengths
            m_lengths[num++] = sym;
            break;
        }
    }

    // build dynamic trees
    BuildTree(lt, m_lengths, hlit);
    BuildTree(dt, m_lengths + hlit, hdist);
}

//////////////////////////////////////////////////////////////////////////

void Inflate::InflateBlockData(InflateTree *lt, InflateTree *dt)
{
    // remember current output position
    uchar *start = m_dest;

    while (1)
    {
        int sym = DecodeSymbol(lt);

        // check for end of block
        if (sym == 256)
        {
            m_len += (uint)(m_dest - start);
            return;
        }

        if (sym < 256)
        {
            *m_dest++ = sym;
        }
        else
        {
            sym -= 257;

            // possibly get more bits from length code
            int length = ReadBits(m_lenBits[sym], m_lenBase[sym]);

            int dist = DecodeSymbol(dt);

            // possibly get more bits from distance code
            int offs = ReadBits(m_distBits[dist], m_distBase[dist]);

            // copy match
            for (int i = 0; i < length; ++i)
                m_dest[i] = m_dest[i - offs];

            m_dest += length;
        }
    }
}

void Inflate::InflateUncompressedBlock()
{
    // get length
    uint length = m_src[1];
    length = 256*length + m_src[0];

    // get one's complement of length
    uint invlength = m_src[3];
    invlength = 256*invlength + m_src[2];

    // check length
#ifdef INFLATE_SANITY_CHECKS
    if (length != (~invlength & 0x0000ffff))
        THROW(errDataNotValid);
#endif

    m_src += 4;

    /* copy block */
    for (int i = length; i; --i)
        *m_dest++ = *m_src++;

    // make sure we start next block on a byte boundary
    m_bitcount = 0;

    m_len += length;
}

// inflate a block of data compressed with fixed huffman trees
void Inflate::InflateFixedBlock()
{
    // decode block using fixed trees
    Inflate::InflateBlockData(&m_sltree, &m_sdtree);
}

// inflate a block of data compressed with dynamic huffman trees
void Inflate::InflateDynamicBlock()
{
    // decode trees from stream
    DecodeTrees(&m_ltree, &m_dtree);

    // decode block using decoded trees
    InflateBlockData(&m_ltree, &m_dtree);
}

//////////////////////////////////////////////////////////////////////////

Inflate::Inflate()
{
    // build fixed huffman trees
    BuildFixedTrees(&m_sltree, &m_sdtree);

    // build extra bits and base tables
    BuildBitsBase(m_lenBits, m_lenBase, 4, 3);
    BuildBitsBase(m_distBits, m_distBase, 2, 1);

    // fix a special case
    m_lenBits[28] = 0;
    m_lenBase[28] = 258;
}

uint Inflate::Uncompress(void *dest, const void *src)
{
    // initialize data
    m_src = (const uchar *)src;
    m_bitcount = 0;

    m_dest = (uchar *)dest;
    m_len = 0;

    int bfinal;

    do
    {
        // read final block flag
        bfinal = GetBit();

        // read block type (2 bits)
        uint btype = ReadBits(2, 0);

        // decompress block
        switch (btype)
        {
        case 0:
            // decompress uncompressed block
            InflateUncompressedBlock();
            break;

        case 1:
            // decompress block with fixed huffman trees
            InflateFixedBlock();
            break;

        case 2:
            // decompress block with dynamic huffman trees
            InflateDynamicBlock();
            break;

#ifdef INFLATE_SANITY_CHECKS
        default:
            THROW(errDataNotValid);
#endif
        }
    }
    while (!bfinal);

    return m_len;
}

uint Inflate::ZLibUncompress(void *dest, const void *src)
{
#ifdef INFLATE_SANITY_CHECKS
    // -- get header bytes --
    int cmf = ((uchar*)src)[0];
    int flg = ((uchar*)src)[1];

    // -- check format --

    // check checksum
    if ((256*cmf + flg) % 31)
        THROW(errDataNotValid);

    // check method is deflate
    if ((cmf & 0x0f) != 8)
        THROW(errDataNotValid);

    // check window size is valid
    if ((cmf >> 4) > 7)
        THROW(errDataNotValid);

    // check there is no preset dictionary
    if (flg & 0x20)
        THROW(errDataNotValid);
#endif

    // -- inflate --
    uint len = Uncompress(dest, (uchar*)src + 2);

    // -- get adler32 checksum --

    uint a32 = *m_src++;
    a32 = 256*a32 + *m_src++;
    a32 = 256*a32 + *m_src++;
    a32 = 256*a32 + *m_src++;

    // -- check adler32 checksum --
#ifdef INFLATE_CHECK_CRC
    if (a32 != Adler32(dest, len))
        THROW(errDataNotValid);
#endif

    return len;
}
