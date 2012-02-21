#include "XMLParser.h"
#include "NSData.h"
#include "xml/tinyxml.h"

static XMLNode* parseXmlElement(TiXmlElement* tiNode)
{
    XMLNode* node = XMLNode::alloc();
    node->init();

    node->name = NSString::alloc()->initWithUtf8(tiNode->Value());
//    if (node->name->isEqualToString(NSS("quads")))
//    {
//        int b = 1;
//    }

    TiXmlAttribute* attr = tiNode->FirstAttribute();
    while (attr)
    {
        NSString* key = NSString::alloc()->initWithUtf8(attr->Name());
        key->autorelease();
        NSString* value = NSString::alloc()->initWithUtf8(attr->Value());
        value->autorelease();

        node->_attributes->setObjectforKey(value, key);

        attr = attr->Next();
    }

    TiXmlElement* e = tiNode->FirstChildElement();

    if (e)
    {
        while (e)
        {
            XMLNode* n = parseXmlElement(e);
            node->_childs->addObject(n);
            NSREL(n);
            e = e->NextSiblingElement();
        }
    }
    else
    {
        TiXmlNode* n = tiNode->FirstChild();
        while (n)
        {
            TiXmlText* text = n->ToText();
            if (text)
            {
                node->data = NSString::alloc()->initWithUtf8(text->Value());
            }
            n = n->NextSibling();
        }
    }

    return node;
}


////////////////////////////////////////////////////////////////////////////

IID XMLNode::init()
{
    if (!NSObject::init())
        return nil;

    _childs = NSArray::alloc();
    _childs->init();

    _attributes = NSMutableDictionary::alloc();
    _attributes->init();
}

void XMLNode::dealloc()
{
    NSREL(_childs);
    NSREL(_attributes);
    NSREL(name);
    NSREL(data);

    NSObject::dealloc();
}

NSArray* XMLNode::childs()
{
    return _childs;
}

NSDictionary* XMLNode::attributes()
{
    return _attributes;
}

bool XMLNode::hasAttr(NSString* name)
{
    return _attributes->objectForKey(name) != nil;
}

float XMLNode::floatAttr(NSString* name)
{
    return stringAttr(name)->floatValue();
}

NSString* XMLNode::stringAttr(NSString* name)
{
    return (NSString*)_attributes->objectForKey(name);
}

XMLNode* XMLNode::findChildWithTagNameRecursively(NSString* tag, bool recursively)
{
    if (!_childs)
        return nil;

    FORIN(XMLNode, c, _childs)
    {
        if (c->name->isEqualToString(tag))
        {
            return c;
        }

        if (recursively && c->_childs)
        {
            XMLNode* cn = c->findChildWithTagNameRecursively(tag, recursively);
            if (cn)
            {
                return cn;
            }
        }
    }
    FORINEND;

	return nil;
}

int XMLNode::intAttr(NSString* key)
{
    return stringAttr(key)->intValue();
}

//////////////////////////////////////////////////////////////////////////////

void XMLDocument::parseData(NSData* data)
{
    NSREL(root);
    root = nil;

    char* xmlData = new char[data->length + 1];
    data->getBytes((void*)xmlData);
    xmlData[data->length] = 0;

    TiXmlDocument doc;
    doc.Parse(xmlData);

    TiXmlElement* e = doc.FirstChildElement();
    root = parseXmlElement(e);
}

void XMLDocument::dealloc()
{
    NSREL(root);
    NSObject::dealloc();
}
