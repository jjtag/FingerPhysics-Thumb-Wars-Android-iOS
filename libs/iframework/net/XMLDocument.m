//
//  XMLDocument.m
//  template
//
//  Created by Efim Voinov on 18.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XMLDocument.h"
#import "Framework.h"

NSString* xmlStackTrace(XMLNode* xml)
{
	NSMutableString* str = [NSMutableString create];
	XMLNode* n = xml;
	while(n)
	{
		if (n != xml)
		{
			[str appendString:@"<-"];
		}
		[str appendString:n->name];
		n = n->parent;
	}
	return str;	
}

@implementation XMLNode

-(id)initWithName:(NSString*)n Attributes:(NSDictionary*)a andParent:(XMLNode*)p
{
	if (self = [super init])
	{
		ASSERT(!parent && !name && !attributes);
		parent = p;
		name = [n copy];
		attributes = [a retain];
	}
	
	return self;
}

-(void)addChild:(XMLNode*)n
{
	if (!childs)
	{
		childs = [[DynamicArray alloc] init];
	}
	[childs addObject:n];
}

-(void)setData:(NSString*)d
{
	if (!data)
	{
		data = [d retain];
	}
	else
	{
		[data release];
		data = [[data stringByAppendingString:d] retain];
	}
}

-(XMLNode*)findChildWithTagName:(NSString*)s Recursively:(bool)r
{
	if (!childs)
	{
		return nil;
	}
	
	for (XMLNode* c in childs)
	{
		if ([c->name isEqualToString:s])
		{
			return c;
		}
		
		if (r && c->childs)
		{
			XMLNode* cn = [c findChildWithTagName:s Recursively:r];
			if (cn)
			{
				return cn;
			}
		}
	}
	
	return nil;
}

-(bool)hasAttr:(NSString*)n
{
	if (!attributes)
	{
		return nil;
	}
	NSString* obj = [attributes objectForKey:n];
	return (obj != nil);
}

-(int)intAttr:(NSString*)n
{
	NSString* obj = [self stringAttr:n];
	return [obj intValue];
}

-(float)floatAttr:(NSString*)n
{
	NSString* obj = [self stringAttr:n];
	return [obj floatValue];	
}

-(NSString*)stringAttr:(NSString*)n
{
	ASSERT(attributes);
	NSString* obj = [attributes objectForKey:n];
	ASSERT(obj);
	return obj;
}

-(void)dealloc
{
	[name release];
	[attributes release];
	[data release];
	[childs release];
	[super dealloc];
}

@end

@implementation XMLDocument

-(id)init
{
	if (self = [super init])
	{
		root = nil;
		currentParent = nil;
		currentNode = nil;
		delegate = self;
	}
	
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	XMLNode* node = [[XMLNode alloc] initWithName:elementName Attributes:attributeDict andParent:currentParent];

	if (!root)
	{
		root = [node retain];
	}
		
	[currentParent addChild:node];
	currentNode = node;	
	currentParent = currentNode;
	
	[node release];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString*)string
{
	[currentNode setData:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{	
	currentNode = currentParent;
	currentParent = currentNode->parent;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	ASSERT_MSG(FALSE, @"XML parse error");
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
	ASSERT_MSG(FALSE, @"XML parse error");	
}
	
-(void)dealloc
{
	[root release];
	[super dealloc];
}

@end
