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
@end
