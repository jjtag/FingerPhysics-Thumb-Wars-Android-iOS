//
//  Slider.m
//  buck
//
//  Created by Mac on 01.04.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Slider.h"
#import "Framework.h"

@implementation Slider

-(id)initWithBack:(BaseElement*)b Fill:(BaseElement*)f Nub:(BaseElement*)n Min:(float)min Max:(float)max Step:(float)s
{
	if (self = [super init])
	{
		back = b;
		back->parentAnchor = TOP | LEFT;
		fill = f;
		fill->parentAnchor = TOP | LEFT;
		nub = n;
		nub->parentAnchor = TOP | LEFT;	
		
		// disable auto drawing
		back->visible = FALSE;
		fill->visible = FALSE;
		nub->visible = FALSE;

		[self addChild:back];
		[self addChild:fill];
		[self addChild:nub];		
		minValue = min;
		maxValue = max;
		[self setValue:minValue];
		step = s;
		vertical = FALSE;
		
		width = back->width;
		height = back->height;
	}
	
	return self;
}

-(void)setValue:(float)v
{
	ASSERT(v >= minValue && v <= maxValue);

	if (step != UNDEFINED)
	{
		for (float i = minValue; i <= maxValue; i += step)
		{
			if (v >= i && v <= i + step)
			{
				float d1 = ABS(v - i);
				float d2 = ABS(v - (i + step));
				if (d1 > d2)
				{
					value = i + step;					
				}
				else
				{
					value = i;					
				}
				break;
			}
		}
	}
	else
	{
		value = v;
	}
	
	if (!vertical)
	{
		nub->x = fill->x + (fill->width - nub->width) * (value - minValue) / (maxValue - minValue); 
	}
	else
	{
		nub->y = fill->y + (fill->height - nub->height) * (value - minValue) / (maxValue - minValue); 		
	}
}


-(void)draw
{
	[self preDraw];
	[self postDraw];

	[back draw];
	
	glEnable(GL_SCISSOR_TEST);

	if (!vertical)
	{
		setScissorRectangle(drawX, 0.0, nub->x + nub->width / 2.0, SCREEN_HEIGHT);
	}
	else
	{
		setScissorRectangle(0.0, drawY, SCREEN_WIDTH, nub->y + nub->height / 2.0);		
	}
	[fill draw];
	
	glDisable(GL_SCISSOR_TEST);	
	
	[nub draw];
}

-(bool)onTouchDownX:(float)tx Y:(float)ty
{
	if ([super onTouchDownX:tx Y:ty])
	{
		return TRUE;
	}
	
	if (pointInRect(tx, ty, nub->drawX, nub->drawY, nub->width, nub->height))
	{
		dragging = TRUE;
		draggingOffset = vect(tx - nub->drawX, ty - nub->drawY);
		return TRUE;
	}
	
	return FALSE;
}

-(bool)onTouchMoveX:(float)tx Y:(float)ty
{
	if ([super onTouchMoveX:tx Y:ty])
	{
		return TRUE;
	}

	if (!dragging) return FALSE;
	
	float relValue;
	if (!vertical)
	{
		tx = FIT_TO_BOUNDARIES(tx - draggingOffset.x, fill->drawX, fill->drawX + fill->width - nub->width);
		relValue = (tx - fill->drawX) / (fill->width - nub->width);
	}
	else
	{
		ty = FIT_TO_BOUNDARIES(ty - draggingOffset.y, fill->drawY, fill->drawY + fill->height - nub->height);
		relValue = (ty - fill->drawY) / (fill->height - nub->height);		
	}	
	[self setValue:(minValue + (maxValue - minValue) * relValue)];
	
	[delegate onSlider:self ValueChangedTo:value];
	
	return TRUE;
}

-(bool)onTouchUpX:(float)tx Y:(float)ty
{
	dragging = FALSE;
	
	if ([super onTouchUpX:tx Y:ty])
	{
		return TRUE;
	}
	
	return FALSE;
}


@end
