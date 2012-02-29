//
//  GLElementFactory.h
//  template
//
//  Created by Mac on 30.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"

@class XMLNode;

// generates baseelements from XML descriptions
@interface ElementFactory : NSObject 
{
	DynamicArray* postLink;
}

-(BaseElement*)generateElement:(XMLNode*)xml;

-(void)setBasicParams:(XMLNode*)xml forElement:(BaseElement*)e;
-(Timeline*)createTimeline:(XMLNode*)timeline forElement:(BaseElement*)e;
-(void)createKeyFrame:(XMLNode*)n forTimeline:(Timeline*)t ofType:(int)type Element:(BaseElement*)e;
-(BaseElement*)generateElementsRecursively:(XMLNode*)xml;

@end

@interface PostLinkData: NSObject
{
@public
	BaseElement** address;
	NSString* name;
}

-(id)initWithAddress:(BaseElement**)a andName:(NSString*)n;
@end