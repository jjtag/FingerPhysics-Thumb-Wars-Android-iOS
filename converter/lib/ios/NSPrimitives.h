#ifndef NSPRIMITIVES_H_
#define NSPRIMITIVES_H_

#include "NSObject.h"

class NSInt : public NSObject
{
public:
    NSOBJ(NSInt);

    static NSInt* intWithInt(int v);

    virtual int intValue();

public:
    int _value;
};


class NSFloat : public NSObject
{
public:
    NSOBJ(NSFloat);

    static NSFloat* floatWithFloat(float v);

    virtual float floatValue();

public:
    float _value;
};


class NSBool : public NSObject
{
public:
    NSOBJ(NSBool);

    static NSBool* boolWithBool(bool v);

    virtual bool boolValue();

public:
    bool _value;
};

#endif /* NSPRIMITIVES_H_ */
