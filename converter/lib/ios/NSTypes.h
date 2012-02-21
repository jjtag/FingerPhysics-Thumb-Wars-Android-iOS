#ifndef __NSTypes_h__
#define __NSTypes_h__

typedef float CGFloat;
typedef bool BOOL;
typedef wchar_t unichar;
typedef double CFAbsoluteTime;

const BOOL YES = true;
const BOOL NO = false;

struct CGSize
{
    CGFloat width;
    CGFloat height;
};
typedef struct CGSize CGSize;

inline CGSize CGSizeMake(CGFloat w, CGFloat h)
{
    CGSize sz;
    sz.width = w;
    sz.height = h;
    return sz;
}

struct CGPoint
{
    CGFloat x;
    CGFloat y;
};
typedef struct CGPoint CGPoint;

struct CGRect
{
    CGPoint origin;
    CGSize size;
};
typedef struct CGRect CGRect;

inline CGRect CGRectMake(CGFloat x, CGFloat y, CGFloat w, CGFloat h)
{
    CGRect r;
    r.origin.x = x;
    r.origin.y = y;
    r.size.width = w;
    r.size.height = h;
    return r;
}

typedef enum
{
    UITextAlignmentLeft = 0,
    UITextAlignmentCenter,
    UITextAlignmentRight
} UITextAlignment;

#endif // __NSTypes_h__
