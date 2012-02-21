/*
 */

#ifndef __inflate_h__
#define __inflate_h__

#include "basetypes.h"

#undef INFLATE_CHECK_CRC
#undef GZIP_CHECK_CRC
#undef INFLATE_SANITY_CHECKS

class Inflate
{
public:
    Inflate();

    uint Uncompress(void *dest, const void *src);
    uint GzipUncompress(void *dest, const void *src, uint srcLen);
    uint GetGzipUncompressedSize(void* src, uint srcLen);
    uint ZLibUncompress(void *dest, const void *src);

#ifdef INFLATE_CHECK_CRC
    static uint Adler32(const void *data, uint len);
#endif // INFLATE_CHECK_CRC

#ifdef GZIP_CHECK_CRC
    uint Crc32(const void *data, uint len);
#endif // GZIP_CHECK_CRC

public:
    static const int cFText = 1;
    static const int cFHCrc = 2;
    static const int cFExtra = 4;
    static const int cFName = 8;
    static const int cFComment = 16;

private:
    static const int cA32Base = 65521;
    static const uint cA32NMax = 5552;

#ifdef GZIP_CHECK_CRC
    static const uint cCrc32Tab[16];
#endif // GZIP_CHECK_CRC
    static const uchar cClcidx[19];

    struct InflateTree
    {
        /// Code length table.
        ushort m_table[16];

        /// Translation table from Code to Symbol.
        ushort m_trans[288];
    };

    InflateTree m_sltree;
    InflateTree m_sdtree;

    uchar m_lenBits[30];
    ushort m_lenBase[30];

    uchar  m_distBits[30];
    ushort m_distBase[30];


    const uchar* m_src;
    uint m_tag;
    uint m_bitcount;

    uchar* m_dest;
    uint m_len;

    InflateTree m_ltree;
    InflateTree m_dtree;

    uchar m_lengths[288+32];

private:
    void BuildBitsBase(uchar* bits, ushort* base, int delta, int first);
    void BuildFixedTrees(InflateTree* lt, InflateTree* dt);
    void BuildTree(InflateTree *t, const uchar *lengths, uint num);
    int GetBit();
    uint ReadBits(int num, int base);
    int DecodeSymbol(InflateTree *t);
    void DecodeTrees(InflateTree *lt, InflateTree *dt);
    void InflateBlockData(InflateTree *lt, InflateTree *dt);
    void InflateUncompressedBlock();
    void InflateFixedBlock();
    void InflateDynamicBlock();
};

#endif // __inflate_h__
