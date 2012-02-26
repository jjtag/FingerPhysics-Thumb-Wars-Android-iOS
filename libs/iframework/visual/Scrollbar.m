//
//  GLScrollbar.m
//  template
//
//  Created by Efim Voinov on 06.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Scrollbar.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Debug.h"
#import "GLDrawer.h"

@implementation Scrollbar

@synthesize provider;

-(id)initWithWidth:(float)w Height:(float)h Vertical:(bool)v
{
	if (self = [super init])
	{
		ASSERT(w > 0 && h > 0);
		width = w;
		height = h;
		vertical = v;
		
		sp = vectUndefined;
		mp = vectUndefined;
		sc = vectUndefined;
		
		backColor = MakeRGBA(1.0, 1.0, 1.0, 0.5);
		scrollerColor = MakeRGBA(0.0, 0.0, 0.0, 0.5);
	}	
	
	return self;
}

-(void)update:(TimeType)delta
{
	[super update:delta];

	[provider provideScrollPos:&sp MaxScrollPos:&mp ScrollCoeff:&sc];	
}

-(void)draw
{
	[super preDraw];
	if (vectEqual(sp,vectUndefined))
	{
		[provider provideScrollPos:&sp MaxScrollPos:&mp ScrollCoeff:&sc];			
	}
	
	glDisable(GL_TEXTURE_2D);		

	float fx;
	float fy;
	float fw;
	float fh;
	
	bool skipDraw = FALSE;
	
	if (vertical)
	{			
		fw = width - 2.0;
		fx = 1.0;
		fh = round((height - 2.0) / sc.y);
		float mult = (mp.y != 0) ? sp.y / mp.y : 1.0;
		fy = 1.0 + ((height - 2.0) - fh) * mult;
		if (fh > height) skipDraw = TRUE;		
	}
	else
	{
		fh = height - 2.0;
		fy = 1.0;
		fw = round((width - 2.0) / sc.x);			
		float mult = (mp.x != 0) ? sp.x / mp.x : 1.0;
		fx = 1.0 + ((width - 2.0) - fw) * mult;			
		if (fw > width) skipDraw = TRUE;
	}
		
	if (!skipDraw)
	{
		drawSolidRectWOBorder(drawX, drawY, width, height, backColor);
		drawSolidRectWOBorder(drawX + fx, drawY + fy, fw, fh, scrollerColor);		
	}
	
	glEnable(GL_TEXTURE_2D);	
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	[super postDraw];
}
@end
