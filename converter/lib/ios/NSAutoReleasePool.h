#ifndef __NSAutoReleasePool_h__
#define __NSAutoReleasePool_h__

#include "NSObject.h"

class NSAutoReleasePool
{
public:
    friend class NSObject;

    static IID addToAutorelease(IID object);
    static void performAutorelease();

    // Просто освобождает pool без release'а объектов
    static void clearPool();

private:
    struct Node
    {
        IID object;
        Node* next;
    };

    static Node* root;
};

#endif // __NSAutoReleasePool_h__
