//
//  GLScrollableContainer.m
//  rogatka
//
//  Created by Mac on 28.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ScrollableContainer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Debug.h"
#import "Mover.h"
#import "MathHelper.h"
#import "Framework.h"

const Vector impossibleTouch = {-1000, -1000};

#define DEFAULT_BOUNCE_MOVEMENT_DIVIDE 2.0
#define DEFAULT_BOUNCE_DURATION 0.1
#define DEFAULT_DEACCELERATION 40.0
#define DEFAULT_INERTIAL_TIMEOUT 0.1
#define DEFAULT_SCROLL_TO_POINT_DURATION 0.35
#define MIN_SCROLL_POINTS_MOVE 50.0
#define CALC_NEAREST_DEFAULT_TIMEOUT 0.1
#define DEFAULT_MAX_TOUCH_MOVE_LENGTH 40.0
#define DEFAULT_TOUCH_PASS_TIMEOUT 0.1
#define AUTO_RELEASE_TOUCH_TIMEOUT 0.2

@interface ScrollableContainer (Private)
-(void)moveToPoint:(Vector)tsp Delta:(TimeType)delta Duration:(float)scrollDuration;
@end


@implementation ScrollableContainer

@synthesize delegate;

-(id)init
{
	ASSERT(FALSE);
	return self;
}

-(id)initWithWidth:(float)w Height:(float)h Container:(BaseElement*)c
{
	if (self = [super init])
	{
		ASSERT(w > 0 && h > 0);
		
		spoints = nil;
		spointsNum = UNDEFINED;
		spointsCapacity = UNDEFINED;
		targetSpoint = UNDEFINED;
		lastTargetSpoint = UNDEFINED;
		
		deaccelerationSpeed = DEFAULT_DEACCELERATION;
		inertiaTimeout = DEFAULT_INERTIAL_TIMEOUT;
		scrollToPointDuration = DEFAULT_SCROLL_TO_POINT_DURATION;
		canSkipScrollPoints = FALSE;
		shouldBounceHorizontally = FALSE;
		shouldBounceVertically = FALSE;
		
		touchMoveIgnoreLength = 0.0;
		maxTouchMoveLength = DEFAULT_MAX_TOUCH_MOVE_LENGTH;
		
		touchPassTimeout = DEFAULT_TOUCH_PASS_TIMEOUT;
		
		resetScrollOnShow = TRUE;
		
		untouchChildsOnMove = FALSE;
		
		dontHandleTouchDownsHandledByChilds = FALSE;
		dontHandleTouchMovesHandledByChilds = FALSE;
		dontHandleTouchUpsHandledByChilds = FALSE;
		
		touchTimer = 0.0;
		passTouches = FALSE;
		touchReleaseTimer = 0.0;

		move = vectZero;
		
		container = c;
		width = w;
		height = h;
		container->parentAnchor = TOP | LEFT;
		container.parent = self;
		[childs setObject:container At:0];	
		
		dragStart = impossibleTouch;
		touchState = TOUCH_STATE_UP;
	}
	
	return self;	
}

-(id)initWithWidth:(float)w Height:(float)h ContainerWidth:(float)cw Height:(float)ch
{
	container = [[[BaseElement alloc] init] autorelease];
	container->width = cw;
	container->height = ch;
	
	if (self = [self initWithWidth:w Height:h Container:container])
	{
	}
	
	return self;
}

-(void)addChild:(BaseElement*)c withID:(int)i
{
	[container addChild:c withID:i];
	c->parentAnchor = TOP | LEFT;
}

-(int)addChild:(BaseElement*)c
{
	c->parentAnchor = TOP | LEFT;	
	return [container addChild:c];	
}

-(void)removeChildWithID:(int)i
{
	[container removeChildWithID:i];
}

-(void)removeChild:(BaseElement*)c
{
	[container removeChild:c];
}

-(BaseElement*)getChild:(int)i
{
	return [container getChild:i];
}

-(int)childsCount
{
	return [container childsCount];	
}

-(void)draw
{
	[super preDraw];
	glEnable(GL_SCISSOR_TEST);

	setScissorRectangle(drawX, drawY, width, height);
	
	[self postDraw];
	glDisable(GL_SCISSOR_TEST);
}


-(void)postDraw
{
	if (!passTransformationsToChilds)
	{
		restoreTransformations(self);
	}

	[container preDraw];

	if (!container->passTransformationsToChilds)
	{
		restoreTransformations(container);
	}	
	
	for (BaseElement* c in [container getChilds])
	{
		float cx = c->x + container->drawX;
		float cy = c->y + container->drawY;
		
		if (c && c->visible && rectInRect(cx, cy, cx + c->width, cy + c->height, 
										  drawX, drawY, drawX + width, drawY + height))
		{
			[c draw];
		}
		else
		{
			[c preDraw];
		}
	}	
	
	if (container->passTransformationsToChilds)
	{
		restoreTransformations(container);
	}	
	
	if (passTransformationsToChilds)
	{
		restoreTransformations(self);
	}	
}

-(void)moveToPoint:(Vector)tsp Delta:(TimeType)delta Duration:(float)scrollDuration
{
	float xMoveSpeed = MAX(MIN_SCROLL_POINTS_MOVE, ABS(container->x - tsp.x) / scrollDuration);
	float yMoveSpeed = MAX(MIN_SCROLL_POINTS_MOVE, ABS(container->y - tsp.y) / scrollDuration);
	
	moveVariableToTarget(&container->x, tsp.x, xMoveSpeed, delta);
	moveVariableToTarget(&container->y, tsp.y, yMoveSpeed, delta);
}

-(void)update:(TimeType)delta
{
	[super update:delta];
	
	if (touchTimer > 0.0)
	{
		touchTimer -= delta;
		if (touchTimer <= 0.0)
		{
			touchTimer = 0.0;
			passTouches = TRUE;
			[super onTouchDownX:savedTouch.x Y:savedTouch.y];
		}
	}	
	
	if (touchReleaseTimer > 0.0)
	{
		touchReleaseTimer -= delta;
		if (touchReleaseTimer <= 0.0)
		{
			touchReleaseTimer = 0.0;
			[super onTouchUpX:savedTouch.x Y:savedTouch.y];
		}
	}
	
	if (movingByInertion)
	{		
		Vector prevMove = move;
		moveVariableToTarget(&move.x, 0.0, deaccelerationSpeed, delta);
		moveVariableToTarget(&move.y, 0.0, deaccelerationSpeed, delta);
		
		if (move.x == 0 && move.y == 0)
		{
			movingByInertion = FALSE;
		}
		else
		{
			[self moveContainerBy:move];
		}
	}

	if (touchState == TOUCH_STATE_UP)
	{
		if (shouldBounceHorizontally)
		{
			if (container->x > 0.0)
			{
				[self moveToPoint:vect(0.0, container->y) Delta:delta Duration:DEFAULT_BOUNCE_DURATION];					
				movingByInertion = FALSE;				
			}		
			else if (container->x < -container->width + width && container->x < 0.0)
			{
				[self moveToPoint:vect(-container->width + width, container->y) Delta:delta Duration:DEFAULT_BOUNCE_DURATION];								
				movingByInertion = FALSE;				
			}			
		}
		
		if (shouldBounceVertically)
		{
			if (container->y > 0.0)
			{
				[self moveToPoint:vect(container->x, 0.0) Delta:delta Duration:DEFAULT_BOUNCE_DURATION];	
				movingByInertion = FALSE;				
			}		
			else if (container->y < -container->height + height && container->y < 0.0)
			{
				[self moveToPoint:vect(container->x, -container->height + height) Delta:delta Duration:DEFAULT_BOUNCE_DURATION];								
				movingByInertion = FALSE;				
			}		
		}
	}

	if (movingToSpoint)
	{
		calcNearesetSpointTimout -= delta;
		if (calcNearesetSpointTimout <= 0)
		{
			calcNearesetSpointTimout = CALC_NEAREST_DEFAULT_TIMEOUT;		
			[self calculateNearsetScrollPoint];
		}
		
		Vector tsp = spoints[targetSpoint];
		
		[self moveToPoint:tsp Delta:delta Duration:scrollToPointDuration * scrollToPointDurationMultiplier];
			
		if (container->x == tsp.x && container->y == tsp.y)
		{
			if ([(NSObject*)delegate respondsToSelector:@selector(scrollableContainer:reachedScrollPoint:)])
			{
				[delegate scrollableContainer:self reachedScrollPoint:targetSpoint];
			}
			
			movingToSpoint = FALSE;
			targetSpoint = UNDEFINED;
		}	
	}
	
	if (inertiaTimeoutLeft > 0.0)
	{
		inertiaTimeoutLeft -= delta;
	}
	
	// don't allow subpixel drawing
	container->x = round(container->x);
	container->y = round(container->y);	
}

-(void)show
{	
	touchTimer = 0.0;
	passTouches = FALSE;
	touchReleaseTimer = 0.0;	
	move = vectZero;	
	
	if (resetScrollOnShow)
	{
		[self setScroll:vectZero];
	}
}

-(bool)onTouchDownX:(float)tx Y:(float)ty
{	
	if (!pointInRect(tx, ty, drawX, drawY, width, height))
	{
		return FALSE;
	}	

	if (touchPassTimeout == 0)
	{
		bool childsResult = [super onTouchDownX:tx Y:ty];	
		if (dontHandleTouchDownsHandledByChilds && childsResult) return TRUE;		
	}
	else
	{
		touchTimer = touchPassTimeout;
		savedTouch = vect(tx, ty);
		totalDrag = vectZero;
		passTouches = FALSE;
	}
	
	touchState = TOUCH_STATE_DOWN;	
	
	movingByInertion = FALSE;
	movingToSpoint = FALSE;
	targetSpoint = UNDEFINED;
	dragStart = vect(tx, ty);
			
	return TRUE;
}

-(bool)onTouchMoveX:(float)tx Y:(float)ty
{	
	if (touchPassTimeout == 0 || passTouches)
	{
		bool childsResult = [super onTouchMoveX:tx Y:ty];	
		if (dontHandleTouchMovesHandledByChilds && childsResult) return TRUE;		
	}
	
	if (!pointInRect(tx, ty, drawX, drawY, width, height))
	{
		return FALSE;
	}	

	touchState = TOUCH_STATE_MOVING;	
	
	if (!vectEqual(dragStart, impossibleTouch))
	{
		Vector currentDrag = vect(tx, ty);
		Vector off = vectSub(currentDrag, dragStart);						
		dragStart = currentDrag;
		
		off.x = FIT_TO_BOUNDARIES(off.x, -maxTouchMoveLength, maxTouchMoveLength);
		off.y = FIT_TO_BOUNDARIES(off.y, -maxTouchMoveLength, maxTouchMoveLength);

		totalDrag = vectAdd(totalDrag, off);
		
		if (touchTimer > 0.0 || untouchChildsOnMove)
		{		
			if (vectLength(totalDrag) > touchMoveIgnoreLength) 
			{
				touchTimer = 0.0;
				passTouches = FALSE;
				[super onTouchUpX:UNDEFINED Y:UNDEFINED];				
			}
		}
		
		// ignore drag if container fits element
		if (container->width <= width) off.x = 0;
		if (container->height <= height) off.y = 0;
		
		if (shouldBounceHorizontally)
		{
			if (container->x > 0.0 || (container->x < -container->width + width))
			{
				off.x /= DEFAULT_BOUNCE_MOVEMENT_DIVIDE;				
			}
		}
		
		if (shouldBounceVertically)
		{
			if (container->y > 0.0 || (container->y < -container->height + height))
			{
				off.y /= DEFAULT_BOUNCE_MOVEMENT_DIVIDE;				
			}
		}
		
		[self moveContainerBy:off];
		inertiaTimeoutLeft = inertiaTimeout;
		return TRUE;
	}
		
	return FALSE;
}			

-(bool)onTouchUpX:(float)tx Y:(float)ty
{
	// don't pass touch to childs if we scrolled the container
	if (touchPassTimeout == 0 || passTouches)
	{
		bool childsResult = [super onTouchUpX:tx Y:ty];
		if (dontHandleTouchUpsHandledByChilds && childsResult) return TRUE;
	}
	
	if (touchTimer > 0.0)
	{
		bool childsResult = [super onTouchDownX:savedTouch.x Y:savedTouch.y];	
		touchReleaseTimer = AUTO_RELEASE_TOUCH_TIMEOUT;
		touchTimer = 0.0;
		if (dontHandleTouchDownsHandledByChilds && childsResult) return TRUE;		
	}
	
	if (touchState == TOUCH_STATE_UP)
	{
		return FALSE;
	}
	
	touchState = TOUCH_STATE_UP;

	if (inertiaTimeoutLeft > 0.0)
	{
		float denom = inertiaTimeoutLeft / inertiaTimeout;
		move = vectMult(move, denom);
		movingByInertion = TRUE;
	}
	
	if (spointsNum > 0)
	{
		movingToSpoint = TRUE;
		scrollToPointDurationMultiplier = 1.0;
		calcNearesetSpointTimout = CALC_NEAREST_DEFAULT_TIMEOUT;
		[self calculateNearsetScrollPoint];
	}
	
	dragStart = impossibleTouch;
		
	return TRUE;
}

-(void)calculateNearsetScrollPoint
{	
	int c = UNDEFINED;
	float minLen = 9999999;
	for (int i = 0; i < spointsNum; i++)
	{
		float len = vectDistance(spoints[i], vect(container->x, container->y));
		if (len < minLen)
		{
			c = i;
			minLen = len;
		}
	}
	
	ASSERT(c != UNDEFINED);		
	targetSpoint = c;	
	
	if (!canSkipScrollPoints && targetSpoint != lastTargetSpoint)
	{
		movingByInertion = FALSE;
		scrollToPointDurationMultiplier = 1.0 / (MAX(10.0, vectLength(move)) / 5.0);
	}

	if (lastTargetSpoint != targetSpoint && targetSpoint != UNDEFINED)
	{
		if ([(NSObject*)delegate respondsToSelector:@selector(scrollableContainer:changedTargetScrollPoint:)])
		{
			[delegate scrollableContainer:self changedTargetScrollPoint:targetSpoint];
		}
	}	
	
	lastTargetSpoint = targetSpoint;
}

-(void)moveContainerBy:(Vector)off
{
	float nx = container->x + off.x;
	float ny = container->y + off.y;
	
	if (!shouldBounceHorizontally)
	{
		nx = MIN(MAX(-container->width + width, nx), 0.0);
	}
	
	if (!shouldBounceVertically)
	{
		ny = MIN(MAX(-container->height + height, ny), 0.0);
	}
	
	move = vectSub(vect(nx, ny), vect(container->x, container->y));
	container->x = nx;
	container->y = ny;	
}

-(void)turnScrollPointsOnWithCapacity:(int)n
{
	ASSERT(n > 0);
	ASSERT(!spoints);

	spointsCapacity = n;
	spoints = malloc(sizeof(Vector) * spointsCapacity);
	spointsNum = 0;
}

-(int)addScrollPointAtX:(float)sx Y:(float)sy
{
	[self addScrollPointAtX:sx Y:sy withID:spointsNum];
	return spointsNum - 1;
}

-(void)addScrollPointAtX:(float)sx Y:(float)sy withID:(int)i
{
	ASSERT(sx >= 0 && sx < container->width);
	ASSERT(sy >= 0 && sy < container->height);
	ASSERT(i < spointsCapacity);
	spoints[i] = vect(-sx, -sy);
	if (i > spointsNum - 1)
	{
		spointsNum = i + 1;
	}
}

-(Vector)getScroll
{
	return vect(-container->x, -container->y);
}

-(Vector)getMaxScroll
{
	return vect(container->width - width, container->height - height);
}

-(void)setScroll:(Vector)s
{
	move = vectZero;
	container->x = -s.x;
	container->y = -s.y;
	movingToSpoint = FALSE;
	targetSpoint = UNDEFINED;
	lastTargetSpoint = UNDEFINED;
}

-(void)placeToScrollPoint:(int)sp
{
	ASSERT(sp >= 0 && sp < spointsNum);
	move = vectZero;
	container->x = spoints[sp].x;
	container->y = spoints[sp].y;	
	movingToSpoint = FALSE;
	targetSpoint = UNDEFINED;
	lastTargetSpoint = sp;
	
	[delegate scrollableContainer:self reachedScrollPoint:sp];
}

// provided to scrollbar
-(void)provideScrollPos:(Vector*)sp MaxScrollPos:(Vector*)mp ScrollCoeff:(Vector*)sc
{
	ASSERT(sp && mp && sc);
	*sp = [self getScroll];
	*mp = [self getMaxScroll];
	float scx = (float)container->width / (float)width;
	float scy = (float)container->height / (float)height;
	*sc = vect(scx, scy);
}

-(void)dealloc
{	
	if (spoints)
	{
		free(spoints);
	}
	[super dealloc];
}

@end
