//
//  XMLDocument.h
//  template
//
//  Created by Efim Voinov on 18.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XMLParser.h"
#include "DynamicArray.h"

// simple dom-style xml parser, supports only basic elements
@interface XMLNode : NSObject
{
@public
	XMLNode* parent;
	NSString* name;

	NSDictionary* attributes;
	NSString* data;
	DynamicArray* childs;
}

-(id)initWithName:(NSString*)n Attributes:(NSDictionary*)a andParent:(XMLNode*)p;
-(void)addChild:(XMLNode*)n;
-(void)setData:(NSString*)d;

-(XMLNode*)findChildWithTagName:(NSString*)s Recursively:(bool)r;

-(bool)hasAttr:(NSString*)n;
-(int)intAttr:(NSString*)n;
-(float)floatAttr:(NSString*)n;
-(NSString*)stringAttr:(NSString*)n;
@end


@interface XMLDocument : XMLParser 
{
@public
	XMLNode* root;
	
@private
	XMLNode* currentParent;
	XMLNode* currentNode;
}

NSString* xmlStackTrace(XMLNode* xml);

#define XML_ASSERT_MSG(cond, msg, xml) ASSERT_MSG((cond), FORMAT_STRING(@"XML error: %@, xml stack: %@", msg, xmlStackTrace((xml))));
#define XML_ASSERT_ATTR(name, xml) ASSERT_MSG(([(xml) hasAttr:name]), FORMAT_STRING(@"XML error: no attribute %@, xml stack: %@", (name), xmlStackTrace((xml))));
#define XML_ASSERT_DATA(xml) ASSERT_MSG((xml->data), FORMAT_STRING(@"XML error: no data, xml stack: %@", xmlStackTrace((xml))));
#define XML_ASSERT_CHILDS(xml) ASSERT_MSG((xml->childs), FORMAT_STRING(@"XML error: no childs, xml stack: %@", xmlStackTrace((xml))));

@end
