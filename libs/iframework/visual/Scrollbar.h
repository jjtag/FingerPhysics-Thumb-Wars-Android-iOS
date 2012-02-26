//
//  GLScrollbar.h
//  template
//
//  Created by Efim Voinov on 06.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"

@protocol ScrollbarProvider
-(void)provideScrollPos:(Vector*)sp MaxScrollPos:(Vector*)mp ScrollCoeff:(Vector*)sc;
@end

// basic scrollbar element
@interface Scrollbar : BaseElement 
{
	Vector sp;
	Vector mp;
	Vector sc;	
	
	id<ScrollbarProvider> provider;
	bool vertical;

@public
	RGBAColor backColor;
	RGBAColor scrollerColor;
}

@property (assign) id<ScrollbarProvider> provider;

-(id)initWithWidth:(float)w Height:(float)h Vertical:(bool)v;
@end
