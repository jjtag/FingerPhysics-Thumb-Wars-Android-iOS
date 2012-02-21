#ifndef __XMLParser_h__
#define __XMLParser_h__

#include "NSObject.h"
#include "NSDictionary.h"
#include "NSMutableDictionary.h"

#define XML_ASSERT_ATTR(x,y)
#define XML_ASSERT_MSG(x,y,z)
#define XML_ASSERT_DATA(x)

class XMLNode : public NSObject
{
public:
    NSOBJ(XMLNode);

    NSString* name;
    NSString* data;

    NSArray* _childs;
    NSMutableDictionary* _attributes;

    virtual IID init();
    virtual void dealloc();

    virtual NSArray* childs();

    virtual NSDictionary* attributes();

    virtual bool hasAttr(NSString* name);

    virtual float floatAttr(NSString* name);
    virtual NSString* stringAttr(NSString* name);

    virtual XMLNode* findChildWithTagNameRecursively(NSString* tag, bool recursively);

    virtual int intAttr(NSString* key);
};

class XMLDocument : public NSObject
{
public:
    NSOBJ(XMLDocument);

    XMLNode* root;

    virtual void dealloc();

    virtual void parseData(NSData* data);
};

#endif // __XMLParser_h__
