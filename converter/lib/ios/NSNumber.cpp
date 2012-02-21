#include "NSNumber.h"

NSNumber* NSNumber::numberWithInt(int v)
{
    NSNumber* number = NSNumber::alloc();
    number->autorelease();

    number->_value = v;

    return number;
}

int NSNumber::intValue()
{
    return _value;
}
