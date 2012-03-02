//
//  Mode2Scene.m
//  champions
//
//  Created by ikoryakin on 4/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Mode2Scene.h"
#import "ChampionsResourceMgr.h"
#import "Parallax.h"
#import "GameController.h"

@implementation Mode2Scene

-(id)init
{
	if(self = [super init])
	{
		float pxOffsetY = 5;
		
		Texture2D* tobj = [ChampionsResourceMgr getResource:IMG_CRANE_TUBE];
		Parallax* obj = [[[Parallax alloc] initWithXPos:-3 YPos:SCREEN_HEIGHT-750 parallaxRatioX:15 parallaxRatioY:2 image:tobj vertAliasing:FALSE reverseDirection:FALSE] autorelease];
		[px addObject:obj];
		
		tobj = [ChampionsResourceMgr getResource:IMG_BUILD_01];
		obj = [[[Parallax alloc] initWithXPos:-5 YPos:SCREEN_HEIGHT-tobj.realHeight+pxOffsetY parallaxRatioX:5 parallaxRatioY:pxOffsetY image:tobj vertAliasing:FALSE reverseDirection:FALSE] autorelease];
		[px addObject:obj];
		
		pxOffsetY += 5;
		tobj = [ChampionsResourceMgr getResource:IMG_FIELD_01];
		obj = [[[Parallax alloc] initWithXPos:-20 YPos:SCREEN_HEIGHT-tobj.realHeight+pxOffsetY parallaxRatioX:10 parallaxRatioY:pxOffsetY image:tobj vertAliasing:FALSE reverseDirection:FALSE] autorelease];
		[px addObject:obj];
		
		Image* field = [Image createWithResID:IMG_FIELD_02];
		field->x = -20;
		field->y = obj.y + field->height/2 + pxOffsetY;
		
		Image* tube = [Image createWithResID:IMG_CRANE_TUBE];
		tube->x = 10;
		tube->y = field->y - tube->height/2 + 10;
		tube->rotation = -10;
		[self addChild:tube];
		
		[self addChild:field];
		
		tobj = [ChampionsResourceMgr getResource:IMG_IRONNET_01];
		obj = [[[Parallax alloc] initWithXPos:-20 YPos:SCREEN_HEIGHT-tobj.realHeight+pxOffsetY parallaxRatioX:20 parallaxRatioY:pxOffsetY image:tobj vertAliasing:FALSE reverseDirection:FALSE] autorelease];
		[px addObject:obj];

		tobj = [ChampionsResourceMgr getResource:IMG_IRONNET_02];
		obj = [[[Parallax alloc] initWithXPos:SCREEN_WIDTH-tobj.realWidth+20 YPos:SCREEN_HEIGHT-tobj.realHeight+pxOffsetY parallaxRatioX:20 parallaxRatioY:pxOffsetY image:tobj vertAliasing:FALSE reverseDirection:FALSE] autorelease];
		[px addObject:obj];
		
		Image* base_line = [Image createWithResID:IMG_CRANE_04];
		base_line->y = SCREEN_HEIGHT - 1425;
		[self addChild:base_line];
		
		BaseElement* airplane = [ChampionsResourceMgr getResource:ELT_AIRSHIP];
		[base_line addChild:airplane];
		[airplane playTimeline:ELT_AIRSHIP_BASIC_TIMELINE];
		
		Image* crane_arm = [Image createWithResID:IMG_CRANE_05];
		crane_arm->y = SCREEN_HEIGHT - 1225;
		[self addChild:crane_arm];
		
		Image* crane_arm_detail = [Image createWithResID:IMG_CRANE_02];
		crane_arm_detail->anchor = crane_arm_detail->parentAnchor = BOTTOM | RIGHT;
		[crane_arm addChild:crane_arm_detail];
		
		BaseElement* arm_detail = [ChampionsResourceMgr getResource:ELT_CRANE_01];
		[arm_detail playTimeline:ELT_CRANE_01_BASIC_TIMELINE];
		[crane_arm_detail addChild:arm_detail];
		
	}
	return self;
}

-(void)initPhysics
{
	[super initPhysics];
	if(mapParser.settings.Height > SCREEN_HEIGHT)
	{
		[camera turnMaxPathPoints:3];
		[camera addPathPoint:vect(0, 0)];
		[camera addPathPoint:vect(0, mapParser.settings.Height-SCREEN_HEIGHT)];		
		[camera addPathPoint:vect(0, 0)];
	}
}

-(void)show
{
	[super show];
	[camera startPath];
}
-(void)drawParallaxObjects
{
	Accelerometer* acc = [Application sharedAccelerometer];
	Parallax* obj = [px objectAtIndex:0];
	float x1 = 83;
	float y1 = SCREEN_HEIGHT - 869;
	float x2 = obj.x+(acc.ax*obj.parallaxRatioX) + 95;
	float y2 = obj.y-(acc.ay*obj.parallaxRatioY) + 12;
	Texture2D* rope = [ChampionsResourceMgr getResource:IMG_ROPE];
	Texture2D* rope_shadow = [ChampionsResourceMgr getResource:IMG_ROPE_SHADOW];
	drawTexturedLine(x1+13, y1+3, x2+4, y2, 2, rope_shadow);
	
	[super drawParallaxObjects];	
	Texture2D* crane_detail = [ChampionsResourceMgr getResource:IMG_CRANE_03];

	drawTexturedLine(x1+9, y1+3, x2, y2, 2, rope);
	drawImage(crane_detail, x1, y1);	
}

-(void)drawBack
{
	glClear(GL_COLOR_BUFFER_BIT);
	Texture2D* back = [ChampionsResourceMgr getResource:IMG_TOWN_BACK_01];
	float xpos = -20;
	float ypos = SCREEN_HEIGHT - back.realHeight;
	drawImage(back, xpos, ypos);
	
	Texture2D* back2 = [ChampionsResourceMgr getResource:IMG_TOWN_BACK_02];
	ypos -= back2.realHeight;
	drawImage(back2, xpos, ypos);
	
	Texture2D* back3 = [ChampionsResourceMgr getResource:IMG_TOWN_BACK_03];
	ypos -= back3.realHeight;
	drawImage(back3, xpos, ypos);
}

-(BOOL)checkLooseConditions
{
	for (int i = 0; i < [mapParser.elements count]; i++)
	{
		FPBody* fpb = (FPBody*)[mapParser.elements objectAtIndex:i];
		b2Body* b = fpb.body;		
		if(b->IsStatic())continue;
		
		BOOL bodyIsOutOfBorders = FALSE;
		for(b2Shape* shape = b->GetShapeList(); shape; shape = shape->GetNext())
		{
			b2AABB aabb;
			shape->ComputeAABB(&aabb, b->GetXForm());
			if(
			   aabb.upperBound.x < 0 
			   || aabb.lowerBound.x*PTM_RATIO > mapParser.settings.Width
			   || aabb.lowerBound.y*PTM_RATIO - SCREEN_HEIGHT > 0
			   || aabb.upperBound.y*PTM_RATIO - SCREEN_HEIGHT < -mapParser.settings.Height
			   )
			{				
				bodyIsOutOfBorders = TRUE;
			}
			else
			{
				bodyIsOutOfBorders = FALSE;
				break;
			}
		}
		
		if(bodyIsOutOfBorders)
		{
//			[ChampionsSoundMgr playSound:SND_UPS];
			return TRUE;
		}
	}
	return FALSE;
}

//-(BOOL)checkWinConditions
//{
//	return FALSE;
//}

-(void)update:(TimeType)delta
{
	[super update:delta];
	if(updatePhysics)
	{
		if([mapParser.queuedElements count] == 0 && m_mouseJoint == NULL
		   && ((GameController*)delegate)->game_state == GAME_RESULT_NONE
		   )
		{
			if(bonusesCollected > 0)
			{
				[delegate startTimer];
			}
		}
	}
}

-(void)updateBonuses:(TimeType)delta
{
	for(int i = 0; i < [mapParser.bonuses count]; i++)
	{
		Bonus* bonus = [mapParser.bonuses objectAtIndex:i];
		[bonus update:delta];
		if(bonus.collected && updatePhysics)
		{
			if(bonus.timer > 0)
				bonus.timer -= delta;
		
			if(bonus.timer <= 0)
			{
				[self bonusUncollected:bonus];
				if(bonusesCollected <= 0)
				{
					[delegate stopTimer];
				}
			}
		}
	}
}

-(void)timerFinished
{	
	[self checkWinConditions];
}

-(float)calculcateModelTime
{
	int queuedBlocksBonus = [mapParser.queuedElements count] * 7 * 	ceil(mapParser.settings.Height / 480);
	int presettedBlocksBonus = 0;
	int pinnedBlocksBonus = 0;
	for (FPBody* body in mapParser.elements)
	{
//		if(body.isPinned)
//		{
//			pinnedBlocksBonus += 5;
//			continue;
//		}
		if(body.isTouchable && !body.isStatic)
			presettedBlocksBonus += ceil(mapParser.settings.Height/150);
	}
	
	for (FPJoint* joint in mapParser.joints)
	{
		if(joint->type == JOINT_GEARED || joint->type == JOINT_PINNED)
			pinnedBlocksBonus += 5;
			
	}
	return 	queuedBlocksBonus + presettedBlocksBonus + pinnedBlocksBonus;
}

-(void)cameraAutoFocus
{
	float maxCamPosY = 0;
	
	if(m_mouseJoint && focusOnMouseJoint)
	{
		b2Body* b = m_mouseJoint->GetBody2();
		for (b2Shape* shape = b->GetShapeList(); shape; shape = shape->GetNext()) 
		{
			b2AABB aabb;
			shape->ComputeAABB(&aabb, b->GetXForm());
			maxCamPosY = MAX(maxCamPosY, (-aabb.lowerBound.y*PTM_RATIO+SCREEN_HEIGHT));
		}
	}
	else
	{
		return;
	}
	
	maxCamPosY -= SCREEN_HEIGHT;
	maxCamPosY += SCREEN_HEIGHT/4;
	maxCamPosY = MIN(maxCamPosY, maxCameraPosY);
	
	if(maxCamPosY > 0)
	{
		[camera moveToX:camera->pos.x Y:maxCamPosY Immediate:FALSE];
	}
}

@end
