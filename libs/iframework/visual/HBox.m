//
//  GLVBox.m
//  template
//
//  Created by Mac on 04.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HBox.h"
#import "Framework.h"

@implementation HBox

-(id)initWithOffset:(float)of Align:(int)a Height:(float)h
{
	if (self = [super init])
	{
		ASSERT(a == TOP || a == VCENTER || a == BOTTOM);
		offset = of;
		align = a;
		nextElementX = 0.0;
		height = h;
	}
	
	return self;
}

-(int)addChild:(BaseElement*)c
{
	int index = [childs getFirstEmptyIndex];
	[self addChild:c withID:index];
	return index;
}

-(void)addChild:(BaseElement*)c withID:(int)i
{
	[super addChild:c withID:i];
	
	if (align == LEFT)
	{
		c->anchor = c->parentAnchor = TOP | LEFT;
	}
	else if (align == VCENTER)
	{
		c->anchor = c->parentAnchor = VCENTER | LEFT;
	}
	else if (align == BOTTOM)
	{
		c->anchor = c->parentAnchor = BOTTOM | LEFT;
	}
	else
	{
		ASSERT(FALSE);
	}
	
	c->x = nextElementX;	
	nextElementX += c->width + offset;
	width = nextElementX - offset;
}

+(BaseElement*)createFromXML:(XMLNode*)xml
{
	XML_ASSERT_ATTR(@"offset", xml);
	XML_ASSERT_ATTR(@"align", xml);
	XML_ASSERT_ATTR(@"width", xml);	
	
	float o = [xml floatAttr:@"offset"];
	int a = [self parseAlignmentString:[xml stringAttr:@"align"]];
	float w = [xml floatAttr:@"width"];
	
	HBox* element = [[HBox allocAndAutorelease] initWithOffset:o Align:a Width:w];	
	return element;
}

@end
