#include "NSObject.h"
#include "NSAutoReleasePool.h"
#include <string.h>

NSObject::NSObject() : _retainCount(1)
{
}

NSObject::~NSObject()
{
}

IID NSObject::init()
{
    return this;
}

bool NSObject::isEquals(NSObject* obj)
{
    return this == obj;
}

int NSObject::hash()
{
    return (int)this;
}

IID NSObject::retain()
{
    _retainCount++;
    return this;
}

void NSObject::release()
{
	if(_retainCount > 0)
		_retainCount--;
    if (_retainCount <= 0)
        dealloc();
}

void NSObject::dealloc()
{
    delete this;
}

IID NSObject::autorelease()
{
    NSAutoReleasePool::addToAutorelease(this);
    return this;
}

void* NSObject::operator new(size_t sz)
{
    void* data = (void*)new char[sz];
    bzero(data, sz);
    return data;
}

void NSObject::operator delete(void* obj)
{
    delete[] (char*)obj;
}
