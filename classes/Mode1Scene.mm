//
//  Mode1Scene.m
//  champions
//
//  Created by ikoryakin on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Mode1Scene.h"
#import "ChampionsResourceMgr.h"
#import "Parallax.h"

@implementation Mode1Scene

-(id)init
{
	if (self = [super init])
	{	
		Image* starlingHouse = [Image createWithResID:IMG_BIRD_HOUSE];
		starlingHouse->x = 90;
		starlingHouse->y = 210;
		[self addChild:starlingHouse];
		
		BaseElement* bird = [ChampionsResourceMgr getResource:ELT_BIRD];
		[bird playTimeline:ELT_BIRD_BASIC_TIMELINE];
		[starlingHouse addChild:bird];
		
		Image* cloud01 = [Image createWithResID:IMG_CLOUD_001];
		cloud01->x = 30;
		cloud01->y = -762+SCREEN_HEIGHT;
		[self addChild:cloud01];
		
		Image* cloud02 = [Image createWithResID:IMG_CLOUD_002];
		cloud02->x = 218;
		cloud02->y = -736+SCREEN_HEIGHT;
		[self addChild:cloud02];
		
		Image* cloud03 = [Image createWithResID:IMG_CLOUD_003];
		cloud03->x = 70;
		cloud03->y = -666+SCREEN_HEIGHT;
		[self addChild:cloud03];
		
		Image* cloud04 = [Image createWithResID:IMG_CLOUD_004];
		cloud04->x = 216;
		cloud04->y = -608+SCREEN_HEIGHT;
		[self addChild:cloud04];
		
		Image* cloud05 = [Image createWithResID:IMG_CLOUD_005];
		cloud05->x = 33;
		cloud05->y = -579+SCREEN_HEIGHT;
		[self addChild:cloud05];
		
		Image* moon = [Image createWithResID:IMG_MOON];
		moon->x = 40;
		moon->y = SCREEN_HEIGHT - 1125;
		[self addChild:moon];
		
		BaseElement* branch01 = [ChampionsResourceMgr getResource:ELT_BRANCH_01];
		[branch01 playTimeline:ELT_BRANCH_01_BASIC_TIMELINE];
		[self addChild:branch01];
		
		BaseElement* branch02 = [ChampionsResourceMgr getResource:ELT_BRANCH_02];
		[branch02 playTimeline:ELT_BRANCH_02_BASIC_TIMELINE];
		[self addChild:branch02];
		
		BaseElement* branch03 = [ChampionsResourceMgr getResource:ELT_BRANCH_03];
		[branch03 playTimeline:ELT_BRANCH_03_BASIC_TIMELINE];
		[self addChild:branch03];
		
		float pxOffsetY = 5;
		Texture2D* tobj = [ChampionsResourceMgr getResource:IMG_TREE_FIELD_03];
		Parallax* obj = [[[Parallax alloc] initWithXPos:-30 YPos:SCREEN_HEIGHT-tobj.realHeight+pxOffsetY parallaxRatioX:10 parallaxRatioY:pxOffsetY image:tobj vertAliasing:FALSE reverseDirection:FALSE] autorelease];
		[px addObject:obj];
		
		tobj = [ChampionsResourceMgr getResource:IMG_TREE_FIELD_02];
		obj = [[[Parallax alloc] initWithXPos:190 YPos:SCREEN_HEIGHT-tobj.realHeight+pxOffsetY parallaxRatioX:15 parallaxRatioY:pxOffsetY image:tobj vertAliasing:FALSE reverseDirection:FALSE] autorelease];
		[px addObject:obj];
		
		tobj = [ChampionsResourceMgr getResource:IMG_TREE_FIELD_01];
		obj = [[[Parallax alloc] initWithXPos:23 YPos:SCREEN_HEIGHT-tobj.realHeight+pxOffsetY parallaxRatioX:20 parallaxRatioY:pxOffsetY image:tobj vertAliasing:FALSE reverseDirection:FALSE] autorelease];		
		[px addObject:obj];
		
		Image* flower01 = [Image createWithResID:IMG_FLOWER_01];
		flower01->x = 260;
		flower01->y = SCREEN_HEIGHT - 107;
		[self addChild:flower01];

		Image* flower02 = [Image createWithResID:IMG_FLOWER_02];
		flower02->x = 290;
		flower02->y = SCREEN_HEIGHT - 85;
		[self addChild:flower02];

		Image* flower03 = [Image createWithResID:IMG_FLOWER_03];
		flower03->x = 71;
		flower03->y = SCREEN_HEIGHT - 106;
		[self addChild:flower03];

		Image* flower04 = [Image createWithResID:IMG_FLOWER_04];
		flower04->x = 103;
		flower04->y = SCREEN_HEIGHT - 78;
		[self addChild:flower04];

		Image* flower05 = [Image createWithResID:IMG_FLOWER_05];
		flower05->x = 34;
		flower05->y = SCREEN_HEIGHT - 80;
		[self addChild:flower05];
		
		bumper = nil;
	}
	return self;
}

-(void)initPhysics
{
	[super initPhysics];
	
	for(int i = 0; i < [mapParser.elements count]; i++)
	{
		if (bumper && focusBody)
			break;
		
		FPBody* body = [mapParser.elements objectAtIndex:i];
		if([body.name isEqualToString:@"egg"])
		{
			focusBody = body;
			continue;
		}
		
		if([body.name isEqualToString:@"bumper"])
		{
			bumper = body;
			continue;
		}
	}
	
	if(mapParser.settings.height > SCREEN_HEIGHT && bumper && focusBody)
	{
		b2AABB bumperBB = [self computeBodyBB:bumper.body];
		b2AABB eggBB = [self computeBodyBB:focusBody.body];

		Vector eggPoint;
		Vector bumperPoint;

		//Если яйцо ниже бампера
		if(bumperBB.lowerBound.y < eggBB.lowerBound.y)
		{
			bumperPoint = vect(0, -(bumperBB.upperBound.y)*PTM_RATIO);	
			eggPoint = vect(0, -(eggBB.lowerBound.y)*PTM_RATIO + SCREEN_HEIGHT - SCREEN_HEIGHT/3);
		}		
		else
		{
			eggPoint = vect(0, -(eggBB.upperBound.y)*PTM_RATIO + SCREEN_HEIGHT/3);
			bumperPoint = vect(0, -(bumperBB.lowerBound.y)*PTM_RATIO + SCREEN_HEIGHT - SCREEN_HEIGHT/3);
		}
		
		//Проверяем точки на выход за границы карты
		eggPoint = vect(eggPoint.x, MIN(MAX(0, eggPoint.y), maxCameraPosY));
		bumperPoint = vect(bumperPoint.x, MIN(MAX(0, bumperPoint.y), maxCameraPosY));
		
		[camera turnMaxPathPoints:3];
		[camera addPathPoint:eggPoint];
		[camera addPathPoint:bumperPoint];
		[camera addPathPoint:eggPoint];
	}
}

-(void)show
{
	[super show];	
	[camera startPath];
}

-(void)drawBack
{
	Texture2D* back = [ChampionsResourceMgr getResource:IMG_BACK_01];
	float ypos = SCREEN_HEIGHT - back.realHeight;
	if(camera->pos.y < back.realHeight)
		drawImage(back, 0, ypos);
	
	Texture2D* back2 = [ChampionsResourceMgr getResource:IMG_BACK_02];
	ypos -= back2.realHeight;
	if(camera->pos.y > back.realHeight-SCREEN_HEIGHT && camera->pos.y < back.realHeight+back2.realHeight)
		drawImage(back2, 0, ypos);

	Texture2D* back3 = [ChampionsResourceMgr getResource:IMG_BACK_03];
	ypos -= back3.realHeight;
	if(camera->pos.y > back.realHeight+back2.realHeight-SCREEN_HEIGHT)
		drawImage(back3, 0, ypos);

	Texture2D* tile = [ChampionsResourceMgr getResource:IMG_BACK_TILE];	
	while(camera->pos.y + ypos >= 0 && ABS(ypos) <= mapParser.settings.height)
	{
		ypos -= tile.realHeight;
		drawImage(tile, 0, ypos);
	}
}

-(void)cameraAutoFocus
{
	if(camera->pathEnabled)return;
	float maxCamPosY = 0;
	if(!m_mouseJoint)
	{
		if(focusBody && !focusBody.body->IsSleeping())
		{
			b2Body* b = focusBody.body;
			for (b2Shape* shape = b->GetShapeList(); shape; shape = shape->GetNext()) 
			{
				b2AABB aabb;
				shape->ComputeAABB(&aabb, b->GetXForm());
				maxCamPosY = MAX(maxCamPosY, (-aabb.lowerBound.y+SCREEN_HEIGHT/PTM_RATIO)*PTM_RATIO);
			}
		}
		else
		{
			return;
		}
	}
	else
	{
		if(focusOnMouseJoint)
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

	}
	
	maxCamPosY -= SCREEN_HEIGHT;
	maxCamPosY += SCREEN_HEIGHT/4;
	maxCamPosY = MIN(maxCamPosY, maxCameraPosY);
	
	if(maxCamPosY > 0)
	{
		[camera moveToX:camera->pos.x Y:maxCamPosY Immediate:FALSE];
	}
}

-(BOOL)checkLooseConditions
{
	if(focusBody)
	{
		b2Body* b = focusBody.body;
		for(b2Shape* shape = b->GetShapeList(); shape; shape = shape->GetNext())
		{
			b2AABB aabb;
			shape->ComputeAABB(&aabb, b->GetXForm());
			if(aabb.upperBound.x < 0 
			   || aabb.lowerBound.x*PTM_RATIO > mapParser.settings.width
			   || aabb.lowerBound.y*PTM_RATIO - SCREEN_HEIGHT > 0 
			   || aabb.upperBound.y * PTM_RATIO - SCREEN_HEIGHT < -mapParser.settings.height )
			{
//				[ChampionsSoundMgr playSound:SND_UPS];
				return TRUE;
			}
		}
	}
	return FALSE;
}

-(float)calculcateModelTime
{
	float time = 0;
	for (FPBody* obj in mapParser.elements)
	{
		if([obj.name isEqualToString:@"bumper"])continue;
		
		if(obj.isBreakable && obj.isTouchable) time += 2;
		else
		{
			if(obj.isTouchable)
			{
				time += ceil(mapParser.settings.height / 150);
			}				
			else
				if(!obj.isStatic)
				{
					time += ceil(mapParser.settings.height / 120);
				}					
		}		
	}
	return time;
}

@end
