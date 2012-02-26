//
//  InteractiveAnimatable.m
//  blockit
//
//  Created by Efim Voinov on 26.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Framework.h"
#import <objc/runtime.h>

// general actions
const NSString* ACTION_SET_VISIBLE = @"ACTION_SET_VISIBLE";
const NSString* ACTION_SET_TOUCHABLE = @"ACTION_SET_TOUCHABLE";
const NSString* ACTION_SET_UPDATEABLE = @"ACTION_SET_UPDATEABLE";

const NSString* ACTION_PLAY_TIMELINE = @"ACTION_PLAY_TIMELINE";
const NSString* ACTION_PAUSE_TIMELINE = @"ACTION_PAUSE_TIMELINE";
const NSString* ACTION_STOP_TIMELINE = @"ACTION_STOP_TIMELINE";
const NSString* ACTION_JUMP_TO_TIMELINE_FRAME = @"ACTION_JUMP_TO_TIMELINE_FRAME";

void calculateTopLeft(BaseElement* e)
{
	// align to parent
	if (e->parentAnchor != UNDEFINED)
	{		
		if (e->parentAnchor & LEFT)
		{
			e->drawX = e->parent->drawX + e->x;
		}
		else if (e->parentAnchor & HCENTER)
		{
			e->drawX = e->parent->drawX + e->x + (e->parent->width >> 1);
		}
		else if (e->parentAnchor & RIGHT)
		{
			e->drawX = e->parent->drawX + e->x + e->parent->width;
		}
		
		if (e->parentAnchor & TOP)
		{
			e->drawY = e->parent->drawY + e->y;
		}
		else if (e->parentAnchor & VCENTER)
		{
			e->drawY = e->parent->drawY + e->y + (e->parent->height >> 1);
		}
		else if (e->parentAnchor & BOTTOM)
		{
			e->drawY = e->parent->drawY + e->y + e->parent->height;
		}		
	}
	else
	{
		e->drawX = e->x;
		e->drawY = e->y;		
	}
	
	// align self anchor
	if (!(e->anchor & TOP))
	{
		if (e->anchor & VCENTER)
		{
			e->drawY -= (e->height >> 1);
		}
		else if (e->anchor & BOTTOM)
		{
			e->drawY -= e->height;
		}
	}
	
	if (!(e->anchor & LEFT))
	{
		if (e->anchor & HCENTER)
		{
			e->drawX -= e->width >> 1;
		}
		else if (e->anchor & RIGHT)
		{
			e->drawX -= e->width;
		}
	}	
}

void restoreTransformations(BaseElement* t)
{			
	// if any transformation
	if (t->rotation != 0.0 || t->scaleX != 1.0 || t->scaleY != 1.0 || t->translateX != 0.0 || t->translateY != 0.0)
	{
		glPopMatrix();
	}	
}

void restoreColor(BaseElement* t)
{			
	if (!RGBAEqual(t->color, solidOpaqueRGBA))
	{
		glColor4f(solidOpaqueRGBA.r, solidOpaqueRGBA.g, solidOpaqueRGBA.b, solidOpaqueRGBA.a);	
	}
}

@implementation BaseElement

@synthesize parent;

-(id)init
{
	if (self = [super init])
	{
		ASSERT(!childs);
		visible = TRUE;
		touchable = TRUE;
		updateable = TRUE;
		
		name = nil;
		
		x = 0;
		y = 0;
		
		drawX = 0;
		drawY = 0;
		
		width = 0;
		height = 0;
		
		rotation = 0.0;
		rotationCenterX = 0.0;
		rotationCenterY = 0.0;
		scaleX = 1.0;
		scaleY = 1.0;
		color = solidOpaqueRGBA;
		translateX = 0.0;
		translateY = 0.0;		
		
		parentAnchor = UNDEFINED;		
		parent = nil;
		
		anchor = TOP | LEFT;
		
		childs = [[DynamicArray alloc] init];		
		
		timelines = [[DynamicArray alloc] init];	
		currentTimeline = nil;
		currentTimelineIndex = UNDEFINED;
		
		passTransformationsToChilds = TRUE;
		passColorToChilds = TRUE;
		passTouchEventsToAllChilds = FALSE;		
	}
	
	return self;
}

-(void)preDraw
{
	calculateTopLeft(self);
	
	bool changeScale = (scaleX != 1.0 || scaleY != 1.0);
	bool changeRotation = (rotation != 0.0);
	bool changeTranslate = (translateX != 0.0 || translateY != 0.0);
	
	// apply transformations
	if (changeScale || changeRotation || changeTranslate)
	{			
		glPushMatrix();
		
		if (changeScale || changeRotation)
		{
			float rotationOffsetX = drawX + (width >> 1) + rotationCenterX;
			float rotationOffsetY = drawY + (height >> 1) + rotationCenterY;

			glTranslatef(rotationOffsetX, rotationOffsetY, 0.0);

			if (changeRotation)
			{
				glRotatef(rotation, 0.0, 0.0, 1.0);
			}
			
			if (changeScale)
			{
				glScalef(scaleX, scaleY, 1.0);		
			}	
			glTranslatef(-rotationOffsetX, -rotationOffsetY, 0.0);		
		}
		
		if (changeTranslate)
		{
			glTranslatef(translateX, translateY, 0.0);
		}		
	}
	
	if (!RGBAEqual(color, solidOpaqueRGBA))
	{
		glColor4f(color.r, color.g, color.b, color.a);	
	}
}

-(void)draw
{
	[self preDraw];
	[self postDraw];
}

-(void)postDraw
{	
	if (!passTransformationsToChilds)
	{
		restoreTransformations(self);
	}

	if (!passColorToChilds)
	{
		restoreColor(self);
	}	
		
	int count = [childs count];
	for (int i = 0; i < count && childs != nil; i++)
	{
		BaseElement* c = (BaseElement*)childs->map[i];
		if (c && c->visible)
		{
			[c draw];
		}
	}	

	if (passTransformationsToChilds)
	{
		restoreTransformations(self);
	}
	
	if (passColorToChilds)
	{
		restoreColor(self);
	}	
}

-(void)update:(TimeType)delta
{
	if (currentTimeline)
	{
		updateTimeline(currentTimeline, delta);
	}
	
	int count = [childs count];
	for (int i = 0; i < count && childs != nil; i++)
	{
		BaseElement* c = (BaseElement*)childs->map[i];
		if (c && c->updateable)
		{
			[c update:delta];
		}
	}
}

-(BaseElement*)getChildWithName:(NSString*)n
{
	ASSERT(n);
	int count = [childs count];
	for (int i = 0; i < count && childs != nil; i++)
	{
		BaseElement* c = (BaseElement*)childs->map[i];
		if (c && [c->name isEqualToString:n])
		{
			return c;
		}
	}	
	
	return nil;
}

-(void)setSizeToChildsBounds
{
	calculateTopLeft(self);
	
	float minX = drawX;
	float minY = drawY;
	float maxX = drawX + width;
	float maxY = drawY + height;
	
	int count = [childs count];
	for (int i = 0; i < count && childs != nil; i++)
	{
		BaseElement* c = (BaseElement*)childs->map[i];
		calculateTopLeft(c);
		if (c->drawX < minX) minX = c->drawX;
		if (c->drawY < minY) minY = c->drawY;
		if (c->drawX + c->width > maxX) maxX = c->drawX + c->width;
		if (c->drawX + c->height > maxY) maxY = c->drawY + c->height;
	}	
	
	width = (maxX - minX);
	height = (maxY - minY);	
}

-(bool)handleAction:(ActionData)a
{
	if ([a.actionName isEqualToString:(NSString*)ACTION_SET_VISIBLE])
	{
		self->visible = a.actionSubParam != 0;
	}
	else if ([a.actionName isEqualToString:(NSString*)ACTION_SET_UPDATEABLE])
	{
		self->updateable = a.actionSubParam != 0;		
	}
	else if ([a.actionName isEqualToString:(NSString*)ACTION_SET_TOUCHABLE])
	{
		self->touchable = a.actionSubParam != 0;		
	}
	else if ([a.actionName isEqualToString:(NSString*)ACTION_PLAY_TIMELINE])
	{
		[self playTimeline:a.actionSubParam];
	}
	else if ([a.actionName isEqualToString:(NSString*)ACTION_PAUSE_TIMELINE])
	{
		[self pauseCurrentTimeline];
	}
	else if ([a.actionName isEqualToString:(NSString*)ACTION_STOP_TIMELINE])
	{
		[self stopCurrentTimeline];
	}	
	else if ([a.actionName isEqualToString:(NSString*)ACTION_JUMP_TO_TIMELINE_FRAME])
	{
		[[self getCurrentTimeline] jumpToTrack:a.actionParam KeyFrame:a.actionSubParam];
	}		
	else
	{
		return FALSE;
	}

	return TRUE;
}

+(BaseElement*)createFromXML:(XMLNode*)xml
{
	BaseElement* element = [BaseElement create];
	
	return element;
}

+(int)parseAlignmentString:(NSString*)s
{
	int a = 0;
	if ([s rangeOfString:@"LEFT"].length > 0)
	{
		a = LEFT;
	}
	else if ([s rangeOfString:@"HCENTER"].length > 0 || [s isEqualToString:@"CENTER"])
	{
		a = HCENTER;
	}
	else if ([s rangeOfString:@"RIGHT"].length > 0)
	{
		a = RIGHT;
	}

	if ([s rangeOfString:@"TOP"].length > 0)
	{
		a |= TOP;
	}
	else if ([s rangeOfString:@"VCENTER"].length > 0 || [s isEqualToString:@"CENTER"])
	{
		a |= VCENTER;
	}
	else if ([s rangeOfString:@"BOTTOM"].length > 0)
	{
		a |= BOTTOM;
	}
	
	return a;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(int)addChild:(BaseElement*)c
{
	ASSERT(c);
	int index = [childs getFirstEmptyIndex];
	[self addChild:c withID:index];
	return index;
}

-(void)addChild:(BaseElement*)c withID:(int)i
{
	ASSERT(i >= [childs count] || [childs objectAtIndex:i] == nil);
	c.parent = self;
	[childs setObject:c At:i];	
}

-(void)removeChildWithID:(int)i
{
	BaseElement* c = [childs objectAtIndex:i];
	ASSERT(c != nil);
	ASSERT(c.parent != nil);
	c.parent = nil;
	[childs setObject:nil At:i];	
}

-(void)removeAllChilds
{
	[childs release];
	childs = [[DynamicArray alloc] init];	
}

-(void)removeChild:(BaseElement*)c
{
	int index = [childs getObjectIndex:c];
	ASSERT(index != UNDEFINED);
	[self removeChildWithID:index];
}

-(BaseElement*)getChild:(int)i
{
	return [childs objectAtIndex:i];
}

-(int)childsCount
{
	return [childs count];
}

-(DynamicArray*)getChilds
{
	return childs;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(int)addTimeline:(Timeline*)t
{
	ASSERT(t);
	int index = [timelines getFirstEmptyIndex];
	[self addTimeline:t withID:index];
	return index;
}

-(void)addTimeline:(Timeline*)t withID:(int)i
{
	ASSERT(i >= [timelines count] || [timelines objectAtIndex:i] == nil);
	t->element = self;
	[timelines setObject:t At:i];
}

-(void)playTimeline:(int)t
{
	ASSERT(t >= 0 && t < [timelines count]);
	if (currentTimeline)
	{
		if (currentTimeline->state != TIMELINE_STOPPED)
		{
			[currentTimeline stopTimeline];
		}
	}
	currentTimelineIndex = t;
	currentTimeline = [timelines objectAtIndex:t];
	[currentTimeline playTimeline];
}

-(void)pauseCurrentTimeline
{
	ASSERT(currentTimeline);
	[currentTimeline pauseTimeline];
}

-(void)stopCurrentTimeline
{
	ASSERT(currentTimeline);
	[currentTimeline stopTimeline];
	currentTimeline = nil;
	currentTimelineIndex = UNDEFINED;
}

-(Timeline*)getCurrentTimeline
{
	return currentTimeline;
}

-(int)getCurrentTimelineIndex
{
	return currentTimelineIndex;
}

-(Timeline*)getTimeline:(int)n
{
	ASSERT(n >= 0 && n < [timelines count]);
	return [timelines objectAtIndex:n];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(bool)onTouchDownX:(float)tx Y:(float)ty
{
	bool ret = FALSE;
	int count = [childs count];
	for (int i = count - 1; i >= 0 && childs != nil; i--)
	{
		BaseElement* c = (BaseElement*)childs->map[i];
		if (c && c->touchable)
		{
			if ([c onTouchDownX:tx Y:ty] && ret == FALSE)
			{
				ret = TRUE;
				if (!passTouchEventsToAllChilds)
				{
					return ret;
				}
			}
		}
	}
	return ret;
}

-(bool)onTouchUpX:(float)tx Y:(float)ty
{
	bool ret = FALSE;
	int count = [childs count];
	for (int i = count - 1; i >= 0 && childs != nil; i--)
	{
		BaseElement* c = (BaseElement*)childs->map[i];
		if (c && c->touchable)			
		{
			if ([c onTouchUpX:tx Y:ty] && ret == FALSE)
			{
				ret = TRUE;
				if (!passTouchEventsToAllChilds)
				{
					return ret;
				}
				
			}
		}
	}
	
	return ret;
}

-(bool)onTouchMoveX:(float)tx Y:(float)ty
{
	bool ret = FALSE;
	int count = [childs count];
	for (int i = count - 1; i >= 0 && childs != nil; i--)
	{
		BaseElement* c = (BaseElement*)childs->map[i];
		if (c && c->touchable)			
		{
			if ([c onTouchMoveX:tx Y:ty] && ret == FALSE)
			{
				ret = TRUE;
				if (!passTouchEventsToAllChilds)
				{
					return ret;
				}				
			}
		}
	}
	
	return ret;
}

-(void)setEnabled:(bool)e
{
	visible = e;
	touchable = e;
	updateable = e;
}

-(bool)isEnabled
{
	return (visible && touchable && updateable);
}

-(void)setName:(NSString*)n
{
	ASSERT(!name);
	name = [n retain];
}

-(void)show
{
	int count = [childs count];
	for (int i = 0; i < count && childs != nil; i++)
	{
		BaseElement* c = (BaseElement*)childs->map[i];
		if (c && c->visible)
		{
			[c show];
		}
	}
}

-(void)hide
{
	int count = [childs count];
	for (int i = 0; i < count && childs != nil; i++)
	{
		BaseElement* c = (BaseElement*)childs->map[i];
		if (c && c->visible)
		{
			[c hide];
		}
	}	
}

-(void)dealloc
{
	[childs release];
	childs = nil;
	[timelines release];
	[name release];
	[super dealloc];
}					

@end
