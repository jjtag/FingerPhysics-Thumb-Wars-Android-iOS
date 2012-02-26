//
//  GameObject.m
//  buck
//
//  Created by Mac on 26.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"
#import "ResourceMgr.h"
#import "XMLDocument.h"

#define MAX_MOVER_CAPACITY 50

bool objectsIntersect(GameObject* o1, GameObject* o2)
{	
	float o1x = o1->drawX + o1->bb.x;
	float o1y = o1->drawY + o1->bb.y;
	float o2x = o2->drawX + o2->bb.x;
	float o2y = o2->drawY + o2->bb.y;
	
	return (rectInRect(o1x, o1y, o1x + o1->bb.w, o1y + o1->bb.h, o2x, o2y, o2x + o2->bb.w, o2y + o2->bb.h));
}

bool objectsIntersectRotated(GameObject* o1, GameObject* o2)
{	
	Vector o1tl = vect(o1->drawX + o1->rbb.tlX, o1->drawY + o1->rbb.tlY);
	Vector o1tr = vect(o1->drawX + o1->rbb.trX, o1->drawY + o1->rbb.trY);
	Vector o1br = vect(o1->drawX + o1->rbb.brX, o1->drawY + o1->rbb.brY);
	Vector o1bl = vect(o1->drawX + o1->rbb.blX, o1->drawY + o1->rbb.blY);
	
	Vector o2tl = vect(o2->drawX + o2->rbb.tlX, o2->drawY + o2->rbb.tlY);
	Vector o2tr = vect(o2->drawX + o2->rbb.trX, o2->drawY + o2->rbb.trY);
	Vector o2br = vect(o2->drawX + o2->rbb.brX, o2->drawY + o2->rbb.brY);
	Vector o2bl = vect(o2->drawX + o2->rbb.blX, o2->drawY + o2->rbb.blY);
	
	return (obbInOBB(o1tl, o1tr, o1br, o1bl, o2tl, o2tr, o2br, o2bl));
}

bool pointInObject(Vector p, GameObject* o)
{
	float ox = o->drawX + o->bb.x;
	float oy = o->drawY + o->bb.y;

	return pointInRect(p.x, p.y, ox, oy, ox + o->bb.w, oy + o->bb.h);
}

@implementation GameObject

-(id)initWithTexture:(Texture2D*)t
{
	if (self = [super initWithTexture:t])
	{
		bb = MakeRectangle(0.0, 0.0, width, height);
		rbb = MakeQuad2D(bb.x, bb.y, bb.w, bb.h);
		anchor = CENTER;
		
		rotatedBB = FALSE;
		topLeftCalculated = FALSE;
	}
	
	return self;
}

-(id)initWithTextureID:(int)t xOff:(int)tx yOff:(int)ty XML:(XMLNode*)xml
{
	if (self = [self initWithTexture:[ResourceMgr getResource:t]])
	{
		float sx = (float)[[xml->attributes objectForKey:@"x"] intValue];
		float sy = (float)[[xml->attributes objectForKey:@"y"] intValue];	
		
		x = tx + sx;
		y = ty + sy;
		type = t;				
		
		NSString* bbStr = [xml->attributes objectForKey:@"bb"];		
		if (bbStr)
		{
			NSArray* a = [bbStr componentsSeparatedByString:@","];
			bb = MakeRectangle([[a objectAtIndex:0] intValue], [[a objectAtIndex:1] intValue], 
							   [[a objectAtIndex:2] intValue], [[a objectAtIndex:3] intValue]);			
		}
		else
		{
			bb = MakeRectangle(0.0, 0.0, width, height);
		}

		rbb = MakeQuad2D(bb.x, bb.y, bb.w, bb.h);
		[self parseMover:xml];
	}
	
	return self;
}

-(void)parseMover:(XMLNode*)xml
{
	NSString* path = [xml->attributes objectForKey:@"path"];
	if (path)
	{
		int moverCapacity = MAX_MOVER_CAPACITY;		
		if ([path characterAtIndex:0] == 'R')
		{
			NSString* newPath = [path substringFromIndex:2];
			int rad = [newPath intValue];
			moverCapacity = rad / 2 + 1;
		}		
		
		Mover* m = [[[Mover alloc] initWithPathCapacity:moverCapacity MoveSpeed:([[xml->attributes objectForKey:@"moveSpeed"] floatValue]) 
											RotateSpeed:[[xml->attributes objectForKey:@"rotateSpeed"] floatValue]] autorelease];				
		[m setPathFromString:path andStart:vect(x, y)];
		[self setMover:m];
		[m start];
	}
}

-(void)setMover:(Mover*)m
{
	ASSERT(!mover);
	mover = [m retain];
}

-(void)update:(TimeType)delta
{
	[super update:delta];
	
	if (!topLeftCalculated)
	{
		calculateTopLeft(self);
		topLeftCalculated = TRUE;
	}
	
	if (mover)
	{
		[mover update:delta];
		
		x = mover->pos.x;
		y = mover->pos.y;
		
		if (rotatedBB)
		{
			[self rotateWithBB:mover->angle];
		}
		else
		{
			rotation = mover->angle;
		}
	}
}

-(void)rotateWithBB:(float)a
{
	if (!rotatedBB)
	{
		rotatedBB = TRUE;
	}
	rotation = a;
	
	Vector tl = vect(bb.x, bb.y);
	Vector tr = vect(bb.x + bb.w, bb.y);
	Vector br = vect(bb.x + bb.w, bb.y + bb.h);
	Vector bl = vect(bb.x, bb.y + bb.h);
	
	tl = vectRotateAround(tl, DEGREES_TO_RADIANS(a), width / 2.0 + rotationCenterX, height / 2.0 + rotationCenterY);
	tr = vectRotateAround(tr, DEGREES_TO_RADIANS(a), width / 2.0 + rotationCenterX, height / 2.0 + rotationCenterY);
	br = vectRotateAround(br, DEGREES_TO_RADIANS(a), width / 2.0 + rotationCenterX, height / 2.0 + rotationCenterY);
	bl = vectRotateAround(bl, DEGREES_TO_RADIANS(a), width / 2.0 + rotationCenterX, height / 2.0 + rotationCenterY);

	rbb.tlX = tl.x;
	rbb.tlY = tl.y;
	rbb.trX = tr.x;
	rbb.trY = tr.y;
	rbb.brX = br.x;
	rbb.brY = br.y;
	rbb.blX = bl.x;
	rbb.blY = bl.y;
}

-(void)drawBB
{
	glDisable(GL_TEXTURE_2D);
	if (rotatedBB)
	{
		drawSegment(drawX + rbb.tlX, drawY + rbb.tlY, drawX + rbb.trX, drawY + rbb.trY, redRGBA);
		drawSegment(drawX + rbb.trX, drawY + rbb.trY, drawX + rbb.brX, drawY + rbb.brY, redRGBA);
		drawSegment(drawX + rbb.brX, drawY + rbb.brY, drawX + rbb.blX, drawY + rbb.blY, redRGBA);
		drawSegment(drawX + rbb.blX, drawY + rbb.blY, drawX + rbb.tlX, drawY + rbb.tlY, redRGBA);
	}
	else
	{
		drawRect(drawX + bb.x, drawY + bb.y, bb.w, bb.h, redRGBA);
	}
	glEnable(GL_TEXTURE_2D);	
	glColor4f(1.0, 1.0, 1.0, 1.0);			
}

-(void)draw
{
	[super draw];
	if (isDrawBB)
	{
		[self drawBB];
	}
}

-(void)dealloc
{
	[mover release];
	[super dealloc];
}


@end
