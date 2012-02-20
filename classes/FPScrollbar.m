//
//  FPScrollbar.m
//  champions
//
//  Created by ikoryakin on 6/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FPScrollbar.h"


@implementation FPScrollbar

@synthesize lift;

-(void)draw
{
	[super preDraw];
	if (vectEqual(sp,vectUndefined))
	{
		[provider provideScrollPos:&sp MaxScrollPos:&mp ScrollCoeff:&sc];			
	}
	if(lift)
	{	
		if(vertical)
		{
			float yPercent = sp.y/mp.y;
			lift->x = sp.x;
			lift->y = height*yPercent;
		}
		else
		{
			float xPercent = sp.x/mp.x;	
			lift->x = width*xPercent;
			lift->y = sp.y;
		}
		[lift draw];
	}
	[super postDraw];
}

-(void)dealloc
{
	[super dealloc];
	if(lift)
		[lift release];
}
@end
