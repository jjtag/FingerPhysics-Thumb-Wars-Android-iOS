//
//  GLVBox.m
//  template
//
//  Created by Mac on 04.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VBox.h"
#import "Framework.h"

@implementation VBox

-(id)initWithOffset:(float)of Align:(int)a Width:(float)w
{
	if (self = [super init])
	{
		ASSERT(a == LEFT || a == RIGHT || a == HCENTER);
		offset = of;
		align = a;
		nextElementY = 0.0;
		width = w;
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
	else if (align == RIGHT)
	{
		c->anchor = c->parentAnchor = TOP | RIGHT;
	}
	else if (align == HCENTER)
	{
		c->anchor = c->parentAnchor = TOP | HCENTER;
	}
	else
	{
		ASSERT(FALSE);
	}
	
	c->y = nextElementY;	
	nextElementY += c->height + offset;
	height = nextElementY - offset;
}

+(BaseElement*)createFromXML:(XMLNode*)xml
{
	XML_ASSERT_ATTR(@"offset", xml);
	XML_ASSERT_ATTR(@"align", xml);
	XML_ASSERT_ATTR(@"width", xml);	

	float o = [xml floatAttr:@"offset"];
	int a = [self parseAlignmentString:[xml stringAttr:@"align"]];
	float w = [xml floatAttr:@"width"];

	VBox* element = [[VBox allocAndAutorelease] initWithOffset:o Align:a Width:w];	
	return element;
}

@end
