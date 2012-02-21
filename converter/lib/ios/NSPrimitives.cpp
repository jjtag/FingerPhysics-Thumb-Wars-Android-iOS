#include "NSPrimitives.h"

NSInt* NSInt::intWithInt(int v)
{
	NSInt* number = NSInt::alloc();
    number->autorelease();

    number->_value = v;

    return number;
}

int NSInt::intValue()
{
    return _value;
}


NSFloat* NSFloat::floatWithFloat(float v)
{
	NSFloat* number = NSFloat::alloc();
    number->autorelease();

    number->_value = v;

    return number;
}

float NSFloat::floatValue()
{
    return _value;
}

NSBool* NSBool::boolWithBool(bool v)
{
	NSBool* number = NSBool::alloc();
    number->autorelease();

    number->_value = v;

    return number;
}

bool NSBool::boolValue()
{
    return _value;
}
