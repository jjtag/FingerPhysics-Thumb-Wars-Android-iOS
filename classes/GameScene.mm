//
//  GameScene.m
//  champions
//
//  Created by Mac on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "ChampionsResourceMgr.h"
#import "ChampionsSoundMgr.h"
#import "FPSettings.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "MyContactListener.h"
#import "Parallax.h"
#import "FPJoint.h"
#import "ShockWave.h"
#import "ChampionsPreferences.h"

//TEMP
#import "GameController.h"
#import "GameView.h"
#import "ChampionsRootController.h"
#import "TextScores.h"
///TEMP

RGBAColor magnetBackBlueColor = RGBA_FROM_HEX(39, 96, 255, 255);
RGBAColor magnetBackRedColor = RGBA_FROM_HEX(255, 81, 95, 255);
RGBAColor magnetRedColor = RGBA_FROM_HEX(255, 109, 121, 255);
RGBAColor magnetBlueColor = RGBA_FROM_HEX(77, 129, 255, 255);

@implementation GameScene

@synthesize jointsQueue, shockWaves, deleteQueue;
@synthesize eggAnimation;
@synthesize mapParser;
@synthesize gameTimer;
@synthesize delegate;

-(id)init
{
	if (self = [super init])
	{						
		width = SCREEN_WIDTH;
		height = SCREEN_HEIGHT;
				
		physIterations = 10;
		camera = [[FPCamera2D alloc] initWithSpeed:CAMERA_SPEED andType:CAMERA_SPEED_PIXELS];
		//Temp
		GameController* gc = (GameController*)[[Application sharedRootController] getChild:CHILD_GAME];
		GameView* view = (GameView*)[gc getView:0];
		Image* menu = (Image*)[view getChild:VIEW_ELEMENT_WIN_MENU];
		Text* text = (Text*)[menu getChild:1];
		[text setString:FORMAT_STRING(NSLocalizedString(@"STR_SCORE", @"Score: %i"), score)];
		//Temp
		
		px = [[DynamicArray alloc] init];
		jointsQueue = [[DynamicArray alloc] init];
		shockWaves = [[DynamicArray alloc] init];
		deleteQueue = [[DynamicArray alloc] init];
		
		particlesContainer = [[AnimationsPool alloc] init];
		focusOnMouseJoint = TRUE;
		
		eggTrace = [Image createWithResID:IMG_EGG_TRACE_SMALL];
		eggTrace->anchor = CENTER;
		[eggTrace retain];
		[self reset];	
	}
	
	return self;
}

-(void)reset
{
	bonusesCollected = 0;
	score = 0;
	modelTime = 0;
	queuedObjectTaken = FALSE;
	skipMagnet = FALSE;
}

-(void)show
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	int tutorialLevel = rc.user.tutorialLevel;
	if (tutorialLevel >= TUTORIAL_LEVELS_COUNT)
		rc.user.tutorialLevel = UNDEFINED;
	
	if (tutorialLevel != UNDEFINED)
	{			
		const int TUTORIAL_STRINGS[] = 
		{
			STR_TUTORIAL_TUTORIAL_01_01,
			STR_TUTORIAL_TUTORIAL_02,
			STR_TUTORIAL_TUTORIAL_03,
			STR_TUTORIAL_TUTORIAL_04,
			STR_TUTORIAL_TUTORIAL_05,
			STR_TUTORIAL_TUTORIAL_06,
			STR_TUTORIAL_TUTORIAL_07,
			STR_TUTORIAL_TUTORIAL_08,
			STR_TUTORIAL_TUTORIAL_09,
			STR_TUTORIAL_TUTORIAL_10_01,
			STR_TUTORIAL_TUTORIAL_11,
			STR_TUTORIAL_TUTORIAL_12,
			STR_TUTORIAL_TUTORIAL_13,
			STR_TUTORIAL_TUTORIAL_14,
			STR_TUTORIAL_TUTORIAL_15,
		};
		
		View* view = [[[Application sharedRootController] getCurrentController] activeView];
		
		int strID = TUTORIAL_STRINGS[tutorialLevel];

		int type = BALOON_SINGLE;
		if (strID == STR_TUTORIAL_TUTORIAL_01_01 || strID == STR_TUTORIAL_TUTORIAL_10_01) type = BALOON_MULTIPLE_FIRST;
		[Baloon showBaloonWithID:strID Text:TUTORIAL[strID] 
						   Image:[Image createWithResID:IMG_PERSONAGES Quad:IMG_PERSONAGES_dude01] Blocking:TRUE Type:type inView:view Delegate:self];
		
	}
	
	//[camera moveToX:0 Y:0 Immediate:TRUE];
}

-(void)baloonClosed:(Baloon*)baloon
{
	View* view = [[[Application sharedRootController] getCurrentController] activeView];	

	switch (baloon->baloonID)
	{
		case STR_TUTORIAL_TUTORIAL_01_01:
			[Baloon showBaloonWithID:STR_TUTORIAL_TUTORIAL_01_02 Text:NSLocalizedString(@"STR_TUTORIAL_TUTORIAL_01_02", @"Glass blocks break if you touch them.") 
							   Image:[Image createWithResID:IMG_PERSONAGES Quad:IMG_PERSONAGES_dude01] Blocking:TRUE Type:BALOON_MULTIPLE_LAST inView:view Delegate:self];
			break;			
			
		case STR_TUTORIAL_TUTORIAL_10_01:
			[Baloon showBaloonWithID:STR_TUTORIAL_TUTORIAL_10_02 Text:NSLocalizedString(@"STR_TUTORIAL_TUTORIAL_10_02", @"Built a tower, reach them stars and win!") 
							   Image:[Image createWithResID:IMG_PERSONAGES Quad:IMG_PERSONAGES_dude01] Blocking:TRUE Type:BALOON_MULTIPLE_LAST inView:view Delegate:self];
			break;						
			
		case STR_TUTORIAL_TUTORIAL_01_WIN:
		case STR_TUTORIAL_TUTORIAL_15_WIN:
			[self winCameraScroll];				
			break;
		case STR_TUTORIAL_TUTORIAL_02:
		case STR_TUTORIAL_TUTORIAL_05:
		{
			View* view = [[[Application sharedRootController] getCurrentController] activeView];
			BaseElement* joystick = [view getChild:VIEW_ELEMENT_CAMERA];
			[joystick playTimeline:0];
			break;
		}	
			
	}
}	

-(void)hide
{
}

-(void)cameraAutoFocus
{
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
			for (int i = 0; i < [mapParser.elements count]; i++)
			{
				FPBody* fpb = [mapParser.elements objectAtIndex:i];
				b2Body* b = fpb.body;

				if(b->IsStatic()) continue;
				for (b2Shape* shape = b->GetShapeList(); shape; shape = shape->GetNext()) 
				{
					b2AABB aabb;
					shape->ComputeAABB(&aabb, b->GetXForm());
					maxCamPosY = MAX(maxCamPosY, (-aabb.lowerBound.y+SCREEN_HEIGHT/PTM_RATIO)*PTM_RATIO);
				}
			}
		}
	}
	else
	{
//		b2Body* b = m_mouseJoint->GetBody2();
//		for (b2Shape* shape = b->GetShapeList(); shape; shape = shape->GetNext()) 
//		{
//			b2AABB aabb;
//			shape->ComputeAABB(&aabb, b->GetXForm());
//			maxCamPosY = MAX(maxCamPosY, (-aabb.lowerBound.y*PTM_RATIO+SCREEN_HEIGHT));
//		}
	}
	maxCamPosY -= SCREEN_HEIGHT;
	maxCamPosY += SCREEN_HEIGHT/4;
	maxCamPosY = MIN(maxCamPosY, maxCameraPosY);
	
	if(maxCamPosY > 0)
	{
		[camera moveToX:camera->pos.x Y:maxCamPosY Immediate:FALSE];
	}
}

-(void)updateBonuses:(TimeType)delta
{
	for(int i = 0; i < [mapParser.bonuses count]; i++)
	{
		Bonus* bonus = [mapParser.bonuses objectAtIndex:i];
		[bonus update:delta];
	}
}

-(void)processCamera:(TimeType)delta
{
	if(manualCamera)
	{
		float coffsetX = 0;//MIN(camera->pos.x + cameraOffsetX, mapParser.settings.width); 
		float coffsetY = MIN(MAX(0, camera->pos.y - cameraOffsetY), maxCameraPosY);
		[camera moveToX:coffsetX Y:coffsetY Immediate:FALSE];
		returnCameraDelay = RETURN_CAMERA_DELAY;
	}
	else
	{
		[self cameraAutoFocus];
	}
	[camera update:delta];
	
}

-(void)update:(TimeType)delta
{	
	[super update:delta];
	[particlesContainer update:delta];
	[self moveShockWaves:delta];

	for(int i = 0; i < [mapParser.elements count]; i++)
	{
		FPBody* body = [mapParser.elements objectAtIndex:i];
		[body update:delta];
		if(updatePhysics && body && !body.isStatic)
		{
			[self ApplyForceForBody:body];
		}
	}		
	
	if(updatePhysics)
	{		
		[self processJointQueue];
		[self processDeleteQueue];
		[self processCamera:delta];
		
		if(!camera->pathEnabled)
		{
			View* view = [[[Application sharedRootController] getCurrentController] activeView];			
			if (![Baloon hasBaloonInView:view])
			{
				if(gameTimer) gameTimer->time += delta;
			}
		}

		world->Step(1/60.0f, physIterations);
	
		if(m_mouseJoint)
		{
			b2Vec2 location = b2Vec2(mouseJointLocation.x / PTM_RATIO, (mouseJointLocation.y - camera->pos.y) / PTM_RATIO);
			m_mouseJoint->SetTarget(location);
		}
		
		if([self checkLooseConditions])
		{
			[delegate stopTimer];
			[self handleNewLose];			
			[delegate gameLost];
		}
	}
	[self updateBonuses:delta];
	
	if(queueMouseJoint && queuedObject)
	{
		b2Vec2 target;// =	//queuedObject.body->GetLocalCenter();
		target = queuedObject.body->GetLocalCenter() + b2Vec2(0, -camera->pos.y/PTM_RATIO);
		queueMouseJoint->SetTarget(target);
	}
}

-(void)drawTouchzone
{
	glColor4f(touchzoneColor.r, touchzoneColor.g, touchzoneColor.b, touchzoneColor.a);
	
	if([mapParser.queuedElements count] == 0 && touchzoneColor.a > 0)
	{
		touchzoneColor.r -= 0.05f;
		touchzoneColor.g -= 0.05f;
		touchzoneColor.b -= 0.05f;
		touchzoneColor.a -= 0.05f;
	}
	
	if([mapParser.queuedElements count] > 0 || touchzoneColor.a > 0)	
	{
		Texture2D* touchzone = [ChampionsResourceMgr getResource:IMG_TOUCHZONE];
		drawImage(touchzone, 0, 0);
	}

	glColor4f(1, 1, 1, 1);
}

-(void) drawGradient
{
	glPushMatrix();
	glLoadIdentity();
	Texture2D* shadow = [ChampionsResourceMgr getResource:IMG_SHADOW_LEFT_RIGHT];
	for(int i = 0; i<5; i++)
	{
		drawImage(shadow, 0, i*shadow.realHeight);
	}
	
	float Xpos = SCREEN_WIDTH-shadow.realWidth;
	float Ypos = 0;
	float offX = Xpos+shadow.realWidth/2;
	float offY = Ypos+shadow.realHeight/2;
	glPushMatrix();
	glTranslatef(offX, offY, 0);
	glRotatef(180, 0, 0, 1);
	glTranslatef(-offX, -offY, 0);
	for(int i = 0; i<5; i++)
		drawImage(shadow, Xpos, Ypos-i*shadow.realHeight+5);
	glPopMatrix();
	glPopMatrix();
}

-(void)drawBack
{
	glClearColor(1, 0, 1, 1);
	glClear(GL_COLOR_BUFFER_BIT); 
}

-(void)drawParallaxObjects
{
	Accelerometer* acc = [Application sharedAccelerometer];
	for (int i = 0; i < [px count]; i++)
	{
		Parallax* obj = [px objectAtIndex:i];
		if(obj)
			[obj drawWithOffsetX:acc.x offsetY:acc.y];
	}
}

-(void)drawJoints
{
	for (b2Joint* joint = world->GetJointList(); joint; joint = joint->GetNext())
	{
		b2Vec2 p1 = joint->GetAnchor1();
		p1 *= PTM_RATIO;
		
		switch (joint->GetType())
		{
//			case e_distanceJoint:
//				break;
//				
//			case e_mouseJoint:
//				break;
//				
//			case e_prismaticJoint:
//				break;
				
			case e_revoluteJoint:
				b2RevoluteJoint* j = (b2RevoluteJoint*)joint;
				Texture2D* pin;
				float angle = 0;
				if(j->m_enableMotor)
				{
					FPBody* fpbody = (FPBody*)j->GetBody1()->GetUserData();
					if([fpbody.name isEqualToString:@"bumper"])
					{
						pin = [ChampionsResourceMgr getResource:IMG_BUMPER_PIN];
					}
					else 
					{
						angle = RADIANS_TO_DEGREES(fpbody.body->GetAngle());
						pin = [ChampionsResourceMgr getResource:IMG_TEXTURE_GEAR];
						float offX = p1.x;//-pin.realWidth/2;
						float offY = p1.y;//-pin.realHeight/2;
						glPushMatrix();
						glTranslatef(offX, offY, 0);
						glRotatef(angle, 0, 0, 1);
						glTranslatef(-offX, -offY, 0);
						drawImage(pin, offX-pin.realWidth/2, offY-pin.realHeight/2);
						glPopMatrix();
						break;
					}					
				}
				else
				{
					pin = [ChampionsResourceMgr getResource:IMG_CENTER_DOT];
				}				
				drawImage(pin, p1.x - pin.realWidth/2, p1.y - pin.realHeight/2);
				break;
				
//			case e_pulleyJoint:
//				break;
//				
//			case e_gearJoint:
//				break;	
		}
	}
}
-(void)syncColor:(RGBAColor*)color1 withColor:(RGBAColor)color2 step:(float)step
{
	if(RGBAEqual(*color1, color2))return;
	float dR = color1->r - color2.r;
	float dG = color1->g - color2.g;
	float dB = color1->b - color2.b;
	float dA = color1->a - color2.a;
	dR = MIN(step, dR);
	dG = MIN(step, dG);
	dB = MIN(step, dB);
	dA = MIN(step, dA);
	color1->r -= dR;
	color1->g -= dG;
	color1->b -= dB;
	color1->a -= dA;
}

-(void)draw
{	
	[self preDraw];

//	glEnable(GL_LIGHTING);
//	glEnable(GL_LIGHT0);
//	GLfloat pos[] = {100, 100};
//	const GLfloat light0Position[] = {100.0, 100.0, 0.0, 0.0}; 
//	glLightf(GL_LIGHT0, GL_POSITION, light0Position[4]);
//
//	const GLfloat light0Diffuse[] = {1, 1, 1, 1.0};
//    glLightf(GL_LIGHT0, GL_SPECULAR, light0Diffuse[4]);
//	glEnable(GL_LINE_SMOOTH);
	glEnable(GL_TEXTURE_2D);	
	glTranslatef(camera->pos.x, camera->pos.y, 0);
	[self drawBack];
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);			
	[self postDraw];
	[self drawParallaxObjects];
	[self drawGradient];
	[particlesContainer draw];
	glDisable(GL_TEXTURE_2D);
	int shockWavesCount = [shockWaves count];
	for (int i = 0; i < shockWavesCount; i++)
	{
		ShockWave* sw = [shockWaves objectAtIndex:i];
		if (sw->currentRadius < 1000)
		{
			[sw draw];
		}
	}
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glTranslatef(15, 15, 0);
	for(int i = 0; i< [mapParser.elements count]; i++)
	{
		FPBody* body = [mapParser.elements objectAtIndex:i];
		[body drawShapesShadow];
	}
	glTranslatef(-15, -15, 0);
	glColor4f(1, 1, 1, 1);
	glEnable(GL_TEXTURE_2D);
	for(int i = 0; i< [mapParser.bonuses count]; i++)
	{
		Bonus* bonus = [mapParser.bonuses objectAtIndex:i];
		[bonus drawShadow];
	}
	
	if(egg && eggAnimation && eggTrace)
	{
		if(eggAnimation->drawX != 0 && eggAnimation->drawY != 0)
		{
			float filterFactor = 0.1f;
			float newX = eggAnimation->drawX+eggAnimation->width/2;
			float newY = eggAnimation->drawY+eggAnimation->height/2;
			if(eggTrace->x == 0)eggTrace->x = newX;
			if(eggTrace->y == 0)eggTrace->y = newY;
			float offsetX = ( (newX * filterFactor) + (eggTrace->x * (1.0 - filterFactor)) ) - newX;
			float offsetY = ( (newY * filterFactor) + (eggTrace->y * (1.0 - filterFactor)) ) - newY;
			int limit = 7;
			offsetX = MAX(MIN(offsetX, limit), -limit);
			offsetY = MAX(MIN(offsetY, limit), -limit);
			eggTrace->x = newX + offsetX;
			eggTrace->y = newY + offsetY;
			[eggTrace draw];
		}
	}	
		
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	for(int i = 0; i < [mapParser.elements count]; i++)
	{
		FPBody* body = [mapParser.elements objectAtIndex:i];
		[body draw];
		if(body->charge != 0)
		{
			if (body->charge < 0)
			{
				[self syncColor:&body->blockColor withColor:magnetRedColor step:0.01];
				[self syncColor:&body->blockBackColor withColor:magnetBackRedColor step:0.01];
			}
			else
			{
				[self syncColor:&body->blockColor withColor:magnetBlueColor step:0.01];
				[self syncColor:&body->blockBackColor withColor:magnetBackBlueColor step:0.01];
			}
		}
		
//		for (b2ContactEdge* ce = body.body->GetContactList(); ce; ce = ce->next)
//		{
//			b2Contact* contact = ce->contact;			
//			b2Manifold* manifolds = contact->GetManifolds();
//			for (int32 j = 0; j < contact->GetManifoldCount(); ++j)
//			{
//				b2Manifold* manifold = manifolds + j;
//				for (int32 k = 0; k < manifold->pointCount; ++k)
//				{
//					b2ManifoldPoint* point = manifold->points + k;
//					b2Vec2 cp =  body.body->GetWorldPoint(point->localPoint1);
//					cp *= PTM_RATIO;
//					drawPoint(cp.x, cp.y, 5, redRGBA);
//				}
//			}
//		}
	}
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glPushMatrix();
	glLoadIdentity();
	[self drawTouchzone];
	glPopMatrix();
	[queuedObject draw];
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	[self drawJoints];
	
	for(int i = 0; i< [mapParser.bonuses count]; i++)
	{
		Bonus* bonus = [mapParser.bonuses objectAtIndex:i];
		[bonus draw];
	}
	
//	glDisable(GL_TEXTURE_2D);
//	world->DrawDebugData();
//	glEnable(GL_TEXTURE_2D);	
	glColor4f(1.0, 1.0, 1.0, 1.0);		
	glTranslatef(-camera->pos.x, -camera->pos.y, 0);
//	glDisable(GL_LIGHT0);
//	glDisable(GL_LINE_SMOOTH);
	

}

-(bool)onTouchDownX:(float)tx Y:(float)ty
{	
	[delegate stopTimer];
	if(m_mouseJoint)
	{
		return FALSE;
	}
//	else
//	{
//#ifdef CHEAT
//		if(pointInRect(tx, ty, 0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200))
//		{
//			cheatTouches++;
//		}
//		else
//		{
//			cheatTouches = 0;
//		}
//		
//		if(cheatTouches > 2)
//			[self cheatWinGame];		
//#endif
//	}
	
	b2Vec2 location = b2Vec2( (tx-camera->pos.x) / PTM_RATIO, (ty-camera->pos.y) / PTM_RATIO);
	mouseJointLocation = b2Vec2(tx, ty);

	if (pointInRect(tx, ty, 0, 0, 222, 120) && queuedObject && queueMouseJoint)
	{
		world->DestroyJoint(queueMouseJoint);
		queueMouseJoint = NULL;
		
		for (b2Shape* s = queuedObject.body->GetShapeList(); s; s = s->GetNext())
		{
			b2FilterData filter;
			filter.categoryBits = 0x0001;
			filter.maskBits = 0xFFFF;
			filter.groupIndex = 0;
			s->SetFilterData(filter);
			world->Refilter(s);
		}
		
		[mapParser.elements addObject:queuedObject];
		[mapParser.queuedElements removeObjectAtIndex:0];
		
		queuedObjectTaken = TRUE;
		
		[self makeMouseJoint:queuedObject.body point:location];
		
		[self setNextQueuedObject];
		if(ty < SCREEN_HEIGHT/3 || ty > SCREEN_HEIGHT - SCREEN_HEIGHT/3)
			focusOnMouseJoint = FALSE;
		else
			focusOnMouseJoint = TRUE;
		return FALSE;
	}

	BOOL breakLoop = FALSE;
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		for (b2Shape* shape = b->GetShapeList(); shape; shape = shape->GetNext()) {
			if(shape->TestPoint(b->GetXForm(), location))
			{
				FPBody* body = (FPBody*)b->GetUserData();
				if(body.isTouchable)
				{
					if(body.isBreakable)
					{
					
						b2Shape* s = b->GetShapeList();
						b2AABB aabb;
						s->ComputeAABB(&aabb, b->GetXForm());		
						
						b2Vec2 max = aabb.upperBound;
						b2Vec2 min = aabb.lowerBound;
						for (b2Shape* s = b->GetShapeList(); s; s = s->GetNext())
						{
							b2AABB aabb;
							s->ComputeAABB(&aabb, b->GetXForm());		
							min = b2Min(min, aabb.lowerBound);
							min = b2Min(min, aabb.upperBound);
							max = b2Max(max, aabb.lowerBound);
							max = b2Max(max, aabb.upperBound);
						}
						Image* ig = [[[Image alloc] initWithTexture:[ChampionsResourceMgr getResource:IMG_GLASS_PART]] autorelease];
						GLGlassBreak* gb = [[[GLGlassBreak alloc] initWithImageGrid:ig] autorelease];
						gb->anchor = CENTER;
						gb->parentAnchor = TOP | LEFT;
						Vector posVar;
						posVar.x = (max.x - min.x)/2;
						posVar.y = (max.y - min.y)/2;
						posVar = vectMult(posVar, PTM_RATIO);
						
						gb->x = min.x * PTM_RATIO + posVar.x;
						gb->y = max.y * PTM_RATIO - posVar.y;
						[gb setPosVar:posVar];
						[gb startSystem:gb.totalParticles];
						
						[particlesContainer addChild:gb];				
						[ChampionsSoundMgr playSound:SND_GLASS_BREAK];
						[self handleBlockBreaked];
						[self destroyBlock:body];
					}
					else
					{
						if(b->IsStatic()) continue;		
						[self makeMouseJoint:b point:location];
						if(ty < SCREEN_HEIGHT/3 || ty > SCREEN_HEIGHT - SCREEN_HEIGHT/3)
							focusOnMouseJoint = FALSE;
						else
							focusOnMouseJoint = TRUE;
					}
					breakLoop = true;		
					break;
				}
			}
		}
		if(breakLoop)break;
	}
//	if(!breakLoop)
//		[self addObjectAtX:location.x Y:location.y];
	return FALSE;
}

-(bool)onTouchUpX:(float)tx Y:(float)ty
{
	if (queuedObjectTaken)
	{
		queuedObjectTaken = FALSE;		
		[self handleBlockStacked];
	}
	
	[self destroyMouseJoint];
	return FALSE;
}

-(bool)onTouchMoveX:(float)tx Y:(float)ty
{
	b2Vec2 location = b2Vec2((tx - camera->pos.x) / PTM_RATIO, (ty-camera->pos.y) / PTM_RATIO);
	if (m_mouseJoint)
	{
		mouseJointLocation = b2Vec2(tx, ty);
		m_mouseJoint->SetTarget(location);
		if(!focusOnMouseJoint && ty > SCREEN_HEIGHT/3 && ty < SCREEN_HEIGHT - SCREEN_HEIGHT/3)
			focusOnMouseJoint = TRUE;
	}
	return FALSE;
}

-(void)dealloc
{
	[particlesContainer release];
	[eggTrace release];
	[deleteQueue release];
	[shockWaves release];
	[jointsQueue release];
	[px release];
	[mapParser release];
	delete world;
	world = NULL;
	delete contact_listener;
	contact_listener = nil;
	[camera release];
	[super dealloc];
}

#pragma mark -

-(void)createWinParticles
{
	int totalParticles = 300;
	Image* ig = [Image createWithResID:IMG_STARS_PARTICLES];
	GLFireworks* gb = [[[GLFireworks alloc] initWithTotalParticles:totalParticles andImageGrid:ig] autorelease];
	gb->anchor = CENTER;
	gb->parentAnchor = TOP | LEFT;
	gb->x = SCREEN_WIDTH/2;
	gb->y = SCREEN_HEIGHT-camera->pos.y;
	gb->size = 1;
	gb->sizeVar = 0;
	gb->gravity = vect(0, 70);
	gb->speed = 350;
	gb->angle = 270;
	gb->angleVar = 80;
	gb->life = 1.5;
	gb->posVar = vect(SCREEN_WIDTH/2, 0);
	gb->startColor = (RGBAColor)RGBA_FROM_HEX(255, 242, 0, 255);
	[gb startSystem:0];
	[particlesContainer addChild:gb];
}

-(b2AABB)computeBodyBB:(b2Body*)body
{
	b2Shape* s = body->GetShapeList();
	
	//Calc object bounding box
	b2AABB aabb;
	s->ComputeAABB(&aabb, body->GetXForm());		
	
	b2Vec2 max = aabb.upperBound;
	b2Vec2 min = aabb.lowerBound;
	for (b2Shape* s = body->GetShapeList(); s; s = s->GetNext())
	{
		b2AABB aabb;
		s->ComputeAABB(&aabb, body->GetXForm());		
		min = b2Min(min, aabb.lowerBound);
		min = b2Min(min, aabb.upperBound);
		max = b2Max(max, aabb.lowerBound);
		max = b2Max(max, aabb.upperBound);
	}
	aabb.lowerBound = b2Vec2(min.x, max.y);
	aabb.upperBound = b2Vec2(max.x, min.y);
	return aabb;
}

-(void)setNextQueuedObject
{
	if([mapParser.queuedElements count] > 0)
	{
		FPBody* fpb = [mapParser.queuedElements objectAtIndex:0];
//		fpb.pos.x = 0;
//		fpb.pos.y = 0;
        fpb.pos = vect(0, 0);
		[self createBody:fpb];

		b2Shape* s = fpb.body->GetShapeList();
		
		//Calc object bounding box
		b2AABB aabb;
		s->ComputeAABB(&aabb, fpb.body->GetXForm());		

		b2Vec2 max = aabb.upperBound;
		b2Vec2 min = aabb.lowerBound;
		for (b2Shape* s = fpb.body->GetShapeList(); s; s = s->GetNext())
		{
			b2AABB aabb;
			s->ComputeAABB(&aabb, fpb.body->GetXForm());		
			min = b2Min(min, aabb.lowerBound);
			min = b2Min(min, aabb.upperBound);
			max = b2Max(max, aabb.lowerBound);
			max = b2Max(max, aabb.upperBound);
			b2FilterData filter;
			filter.categoryBits = 0x0004;
			filter.maskBits = 0x0002;
			filter.groupIndex = 0;
			s->SetFilterData(filter);
			world->Refilter(s);
		}
		Texture2D* tz = [ChampionsResourceMgr getResource:IMG_TOUCHZONE];
		//Левый нижний угол
		b2Vec2 newPos = fpb.body->GetWorldPoint(b2Vec2_zero) - b2Vec2(min.x, max.y);
		//Смещаем в центр фигуры
		newPos += b2Vec2(-(max.x - min.x)/2,(max.y - min.y)/2);
		//Смещаем в центр тач зоны
		newPos += b2Vec2(((tz.realWidth/2)/PTM_RATIO), ((tz.realHeight/2)/PTM_RATIO));
		//Если объект по высоте больше тап зоны, то смещаем его вверх на половину разницы высот
		if(max.y-min.y >= tz.realHeight/PTM_RATIO)
		{
			newPos -= b2Vec2(0, (max.y-min.y-(tz.realHeight/PTM_RATIO))/2);
		}
		fpb.body->SetXForm(newPos, fpb.body->GetAngle());
		queuedObject = fpb;
		b2MassData massData = {1.0f, fpb.body->GetLocalCenter(), 0};
		fpb.body->SetMass(&massData);
		b2MouseJointDef md;
		md.body1 = world->GetGroundBody();
		md.body2 = fpb.body;
		md.target = fpb.body->GetLocalCenter();
		
		md.maxForce = 100000;// * fpb.body->GetMass();
		queueMouseJoint = (b2MouseJoint*)world->CreateJoint(&md);
		fpb.body->WakeUp();		
		fpb.body->SetAngularVelocity(0);
	}
	else
	{
		queuedObject = nil;
	}
}

-(void)initPhysics
{	
	modelTime = [self calculcateModelTime];
//	NSLog(@"model time %f", modelTime);
	
	maxCameraPosY = mapParser.settings.height-SCREEN_HEIGHT;
	
	b2AABB worldAABB;
	worldAABB.lowerBound.Set(-mapParser.settings.width*2 / PTM_RATIO, -mapParser.settings.height / PTM_RATIO);
	worldAABB.upperBound.Set(mapParser.settings.width*2 / PTM_RATIO, 100.0f);
	
	
	// Define the gravity vector.
	b2Vec2 gravity;
	gravity.Set(mapParser.settings.gravity.x, mapParser.settings.gravity.y);
	
	if(mapParser.settings.iterations > 0)
		physIterations = mapParser.settings.iterations;
	
	// Do we want to let bodies sleep?
	bool doSleep = true;
	
	// Construct a world object, which will hold and simulate the rigid bodies.
	world = new b2World(worldAABB, gravity, doSleep);
	
	world->SetContinuousPhysics(true);
	
//	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
//	world->SetDebugDraw(m_debugDraw);
	
	contact_listener = new MyContactListener;
	world->SetContactListener(contact_listener);
	contact_listener->SetGameScene(self);
//	uint32 flags = 0;
//	flags += b2DebugDraw::e_shapeBit;
	//		flags += b2DebugDraw::e_jointBit;
	//		flags += b2DebugDraw::e_aabbBit;
	//		flags += b2DebugDraw::e_pairBit;
//			flags += b2DebugDraw::e_centerOfMassBit;
//			flags += b2DebugDraw::e_coreShapeBit;
//	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
//	b2BodyDef groundBodyDef;
//	groundBodyDef.position.Set(SCREEN_WIDTH / 2.0f / PTM_RATIO, SCREEN_HEIGHT / PTM_RATIO); // bottom-left corner

	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
//	b2Body* groundBody = world->CreateBody(&groundBodyDef);
//
//	b2PolygonDef groundShapeDef;
//	groundShapeDef.SetAsBox(SCREEN_WIDTH / 2.0f /PTM_RATIO, 4.0f /PTM_RATIO);
//	
//	groundBody->CreateShape(&groundShapeDef);
	
	[self createObjects];
	[self setNextQueuedObject];

	if ([mapParser.queuedElements count] > 0)
	{
		touchzoneColor = (RGBAColor){1, 1, 1, 1};
	}
	else
	{			
		touchzoneColor = (RGBAColor){0, 0, 0, 0};
	}
	
	updatePhysics = TRUE;
	
//	for (int i = 0; i < [mapParser.joints count]; i++)
//	{
//		FPJoint* joint = [mapParser.joints objectAtIndex:i];
//		NSLog(@"joint #%i, %@ %@", i, joint->body1.name, joint->body2.name);
//	}
	
//	[delegate startTimer];
}

-(void)fillGenericShapeDef:(b2ShapeDef*)def forShape:(FPShape*)shape
{
	def->density = shape.density;
	def->friction = shape.friction;
	def->restitution = shape.restitution;
	def->isSensor = shape.isSensor;
}

-(void)createShape:(FPShape*)shape forBody:(FPBody*)fpBody
{
	if([shape isMemberOfClass:[FPCircleShape class]])
	{
		FPCircleShape* circleShape = (FPCircleShape*)shape;

		b2CircleDef def;
		[self fillGenericShapeDef:&def forShape:shape];
		def.radius = circleShape.radius;
		def.localPosition.Set(shape.offset.x, shape.offset.y);
		b2Shape* s = fpBody.body->CreateShape(&def);
		s->SetUserData(shape);		
	}
	
	if ([shape isMemberOfClass:[FPPolyShape class]]) {
		FPPolyShape* polyShape = (FPPolyShape*)shape;
		
		b2PolygonDef def;
		[self fillGenericShapeDef:&def forShape:shape];
		def.vertexCount = [polyShape.vertices count];
		ASSERT_MSG(def.vertexCount > 2 && def.vertexCount <= b2_maxPolygonVertices, FORMAT_STRING(@"Vertex count for poly shape must be more than 2 and less than %i.\n", b2_maxPolygonVertices));
		for (int i = 0; i < [polyShape.vertices count]; i++)
		{
			NSString* v = [polyShape.vertices objectAtIndex:i];
			Vector vect = [MapParser parseCoordinates:v];
			vect = vectRotate(vect, shape.angle);
			vect = vectAdd(vect, shape.offset);
			def.vertices[i].Set(vect.x, vect.y);
		}
		b2Shape* s = fpBody.body->CreateShape(&def);
		s->SetUserData(shape);
	}
}

-(void)computeMass:(FPBody*)b
{
	float totalDensity = 0;
	for (int i = 0; i < [b.shapes count]; i++)
	{
		FPShape* shape = [b.shapes objectAtIndex:i];
		totalDensity += shape.density;
	}
	if(!b.isStatic)
	{
		if(totalDensity > 0)
		{
			b.body->SetMassFromShapes();
		}
		else
		{
			b2MassData massData = {b.mass, b2Vec2(b.massCenter.x, b.massCenter.y), b.inertia};
			b.body->SetMass(&massData);
		}
	}
	
}

-(b2Body*)createBody:(FPBody*)b
{
	b2BodyDef bd;
	
	bd.position = b2Vec2(b.pos.x, b.pos.y);
	bd.fixedRotation = b.isFixedRotation;
	bd.userData = b;
	bd.angle = b.angle;
	b2Body* body = world->CreateBody(&bd);
	b.body = body;
	body->SetUserData(b);
	for (int i = 0; i < [b.shapes count]; i++)
	{
		FPShape* shape = [b.shapes objectAtIndex:i];
		[self createShape:shape forBody:b];
	}
	[self computeMass:b];
	
	if(!vectEqual(b->force, vectZero))
	{
		b->arrowTexture = [ChampionsResourceMgr getResource:IMG_TEXTURE_GRAVI_ARROW];
	}
	
	if (![b.name isEqualToString:@"bonus_star"])
	{
		if(b.isStatic)
		{
			Texture2D* t = [ChampionsResourceMgr getResource:IMG_TEXTURE_STATIC];
			[b setTexture:t];			
		}
		else
		{
			if(b.isTouchable)
			{
				Texture2D* t = [ChampionsResourceMgr getResource:IMG_TEXTURE];
				[b setTexture:t];
			}
			else
			{
				Texture2D* t = [ChampionsResourceMgr getResource:IMG_TEXTURE_SIMPLE];
				[b setTexture:t];	
			}
		}
		
		if(b.isTouchable && b.isBreakable)
		{

			b.blockBackColor =  (RGBAColor)RGBA_FROM_HEX(205, 241, 255, 255);
			b.blockColor = (RGBAColor)RGBA_FROM_HEX(231, 248, 255, 255);
			b.outlineColor = (RGBAColor)RGBA_FROM_HEX(190, 225, 250, 255);
		} else
			{
				if(b->charge != 0)
				{
					if(b->charge < 0)
					{
						b.blockBackColor = magnetBackRedColor;
						b.blockColor = magnetRedColor;
						b.outlineColor = (RGBAColor)RGBA_FROM_HEX(255, 21, 40, 255);
					}
					else
					{
						b.blockBackColor = magnetBackBlueColor;
						b.blockColor = magnetBlueColor;
						b.outlineColor = (RGBAColor)RGBA_FROM_HEX(24, 80, 237, 255);
					}
				}
				else
				{
					if(b->isExplodable)
					{
						b.blockBackColor = (RGBAColor)RGBA_FROM_HEX(255, 88, 0, 255);
						b.blockColor = (RGBAColor)RGBA_FROM_HEX(255, 132, 28, 255);
						b.outlineColor = (RGBAColor)RGBA_FROM_HEX(238, 64, 0, 255);
					}
					else
					{
						if(b.isStatic)
						{
							b.blockBackColor = (RGBAColor)RGBA_FROM_HEX(233, 193, 168, 255);
							b.blockColor = (RGBAColor)RGBA_FROM_HEX(242, 218, 199, 255);
							b.outlineColor = (RGBAColor)RGBA_FROM_HEX(212, 141, 114, 255);
						}
						else 
						{
							b.blockBackColor = (RGBAColor)RGBA_FROM_HEX(142, 255, 35, 255);
							b.blockColor = (RGBAColor)RGBA_FROM_HEX(187, 255, 87, 255);
							b.outlineColor = (RGBAColor)RGBA_FROM_HEX(126, 226, 31, 255);
						}
					}
				}
			}
//		b.blockBackColor = (RGBAColor){b.blockColor.r-0.1f, b.blockColor.g-0.1f, b.blockColor.b-0.1f, b.blockColor.a};
//		if(b.isTouchable && b.isBreakable)
//		{
//			b.blockBackColor = whiteRGBA;
//		}
		
//		[b setLightTexture:[ChampionsResourceMgr getResource:IMG_WHITE_SHADE]];
		
		if([b.name isEqualToString:@"bumper"])
		{
			Image* sprite = [Image createWithResID:IMG_BUMPER];
			sprite->anchor = CENTER;
			[b setSprite:sprite];
			
			b2RevoluteJointDef jointDef;
			jointDef.Initialize(b.body, world->GetGroundBody(), b.body->GetWorldCenter());
			jointDef.maxMotorTorque = 1000.0f;			
			jointDef.motorSpeed = DEGREES_TO_RADIANS(-360);
			jointDef.enableMotor = true;
			world->CreateJoint(&jointDef);
		}
		
		if([b.name isEqualToString:@"egg"])
		{
			Image* sprite = [Image createWithResID:IMG_EGG];
			[sprite setDrawQuad:IMG_EGG_NORMAL];
			sprite->anchor = CENTER;
			[b setSprite:sprite];
			
			eggAnimation = [Image createWithResID:IMG_EGG];
			eggAnimation->anchor = eggAnimation->parentAnchor = CENTER;
			[eggAnimation setDrawQuad:IMG_EGG_GLOW_1];
			[sprite addChild:eggAnimation];
			
			Timeline* tegg = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:4];
			[tegg addKeyFrame:makeColor(transparentRGBA, FRAME_TRANSITION_IMMEDIATE, 0)];
			[tegg addKeyFrame:makeColor(whiteRGBA, FRAME_TRANSITION_LINEAR, 0.2)];
			[tegg addKeyFrame:makeColor(transparentRGBA, FRAME_TRANSITION_LINEAR, 0.5)];
			[tegg setTimelineLoopType:TIMELINE_NO_LOOP];
			[eggAnimation addTimeline:tegg];
			eggAnimation->color = transparentRGBA;
			egg = b;
		}
	}
	return body;
}

-(void)ApplyForceForBody:(FPBody*)b
{
	if(!vectEqual(b->force, vectZero))
	{
		b2Body* body = b.body;		
		if(m_mouseJoint && m_mouseJoint->GetBody2() == body)return;
		b2Vec2 force = b2Vec2(b->force.x, b->force.y);
		b2Vec2 forceOffset = b2Vec2(b->forceOffset.x, b->forceOffset.y);
		b2Vec2 diff = force - body->GetLinearVelocity();
		{			
			diff *= body->GetMass();
			body->ApplyForce(diff, body->GetWorldCenter() - body->GetWorldPoint(b2Vec2_zero) + body->GetWorldPoint(forceOffset) );
		}
	}
}

-(FPBody*)getBodyWithId:(int)uniqId
{
	for (int i = 0; i < [mapParser.elements count]; i++)
	{
		FPBody* body = [mapParser.elements objectAtIndex:i];
		if(uniqId == body.uniqId)
		{
			return body;
		}
	}
	return nil;
}

-(void)makeJoint:(FPJoint*)joint
{
	if(joint->body1Id == 0)
		ASSERT_MSG(TRUE, @"body1Id could not be ground");
	
	b2Body* body1 = [self getBodyWithId:joint->body1Id].body;	
	b2Body* body2;
	
	if(joint->body2Id == 0)
	{
		body2 = world->GetGroundBody();
	}
	else
	{
		body2 = [self getBodyWithId:joint->body2Id].body;		
	}
	
	ASSERT(body1);
	ASSERT(body2);
	
	switch (joint->type)
	{
		case JOINT_NONE:
			break;			
		case JOINT_PINNED:
		case JOINT_GEARED:
		{
			b2RevoluteJointDef jointDef;
			jointDef.Initialize(body1, body2, body1->GetPosition() + b2Vec2(joint->rotationOffset.x, joint->rotationOffset.y));
			jointDef.collideConnected = joint->collideConnected;
			if(joint->type == JOINT_GEARED)
			{
				jointDef.maxMotorTorque = joint->maxMotorTorque;			
				jointDef.motorSpeed = DEGREES_TO_RADIANS(joint->rotationSpeed);
				jointDef.enableMotor = true;
				
			}
			world->CreateJoint(&jointDef);
			FPBody* fpbody = (FPBody*)body1->GetUserData();
			fpbody.isPinned = TRUE;
			break;
		}
		case JOINT_DISTANCE:
		{
			b2DistanceJointDef jointDef;	
			const b2Vec2 offset1 = b2Vec2(joint->offsetBody1.x,joint->offsetBody1.y);
			const b2Vec2 offset2 = b2Vec2(joint->offsetBody2.x, joint->offsetBody2.y);
			
			jointDef.Initialize(body1, body2, body1->GetPosition()+offset1, body2->GetPosition()+offset2);
			jointDef.dampingRatio = joint->dampingRatio;
			jointDef.frequencyHz = joint->freqHz;
			jointDef.collideConnected = joint->collideConnected;
			world->CreateJoint(&jointDef);						
			break;
		}
		
		default:
			break;
	}	
}

-(void)processJointQueue
{	
	for (int i = 0; i < [jointsQueue count]; i++)
	{
		FPJoint* joint = [jointsQueue objectAtIndex:i];
		if(joint)
		{
			[self makeJoint:joint];
			[jointsQueue removeObjectAtIndex:i];
		}
	}
}

-(void)processDeleteQueue
{
	for (int i = 0; i < [deleteQueue count]; i++)
	{
		FPBody* body = [deleteQueue objectAtIndex:i];
		if(body)
		{
			[self destroyBlock:body];
			[deleteQueue removeObjectAtIndex:i];
		}
	}
}

-(void)createObjects
{
	for (int i = 0; i < [mapParser.elements count]; i++) {
		FPBody* body = [mapParser.elements objectAtIndex:i];
//		NSLog(@"name = %@", body.name);
		[self createBody:body];
//		[self ApplyForceForBody:body];
	}
	
	for (int i = 0; i < [mapParser.bonuses count]; i++) {
		Bonus* bonus = [mapParser.bonuses objectAtIndex:i];
//		NSLog(@"name = %@", bonus.body.name);
		bonus.body.userData = bonus;
		[self createBody:bonus.body];
	}
	
	for(int i = 0; i < [mapParser.joints count]; i++)
	{
		FPJoint* joint = [mapParser.joints objectAtIndex:i];
		if(joint)
			[self makeJoint:joint];
	}
}

-(void)addObjectAtX:(float)tx Y:(float)ty
{
	if ([mapParser.queuedElements count] > 0)
	{
		FPBody* body = [mapParser.queuedElements objectAtIndex:0];
		if(body)
		{
			body.pos = vect(tx, ty);
			[self createBody:body];		 
			[mapParser.elements addObject:body];
			[mapParser.queuedElements removeObjectAtIndex:0];
			[self makeMouseJoint:body.body point:body.body->GetPosition()];
		}
	}
}

-(void)makeMouseJoint:(b2Body*)body point:(b2Vec2)p
{
	world->SetPositionCorrection(FALSE);
	FPBody* b = (FPBody*)body->GetUserData();
	b->gravity = FALSE;
//#ifndef DEBUG 	
	b2MassData massData = {mapParser.settings->mouseBodyMass, body->GetLocalCenter(), 0};
	body->SetMass(&massData);
//#endif
	b2MouseJointDef md;
	md.body1 = world->GetGroundBody();
	md.body2 = body;
	md.target = p;
	
	for (b2Shape* shape = body->GetShapeList(); shape; shape = shape->GetNext()) 
	{
		shape->SetFriction(0);
	}	
	
	md.maxForce = mapParser.settings.maxMouseForce * body->GetMass();
	m_mouseJoint = (b2MouseJoint*)world->CreateJoint(&md);
	body->WakeUp();

	body->SetAngularVelocity(0);
}

-(void)destroyMouseJoint
{
	world->SetPositionCorrection(TRUE);
	if (m_mouseJoint != NULL)
	{
		mouseJointLocation = b2Vec2_zero;
		b2Body* body = m_mouseJoint->GetBody2();
		FPBody* b = (FPBody*)body->GetUserData();
		b->gravity = TRUE;
		for (b2Shape* shape = body->GetShapeList(); shape; shape = shape->GetNext()) 
		{
			FPShape* s = (FPShape*)shape->GetUserData();
			shape->SetFriction(s.friction);
			world->Refilter(shape);
		}	
		[self computeMass:b];
		world->DestroyJoint(m_mouseJoint);
		m_mouseJoint = NULL;
	}
}

-(void)destroyBlock:(FPBody*)body
{
	if(m_mouseJoint && m_mouseJoint->GetBody2() == body.body)
	{
		[self destroyMouseJoint];
	}
	world->DestroyBody(body.body);	
	[mapParser.elements removeObject:body];
}

-(void)onJoyOffsetX:(float)ox OffsetY:(float)oy
{
	cameraOffsetX = ox;
	cameraOffsetY = oy;
	if(ox != 0 || oy != 0)
	{
		manualCamera = TRUE;
	}
	else
	{
		manualCamera = FALSE;
	}
}

-(void)winCameraScroll
{
	for(int i = 0; i < [mapParser.bonuses count]; i++)
	{
		Bonus* bonus = (Bonus*)[mapParser.bonuses objectAtIndex:i];
		if(bonus.collected)
			[bonus setMode:MODE_VANISH];
	}
	NSTimer* timer;
	timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:delegate selector:@selector(gameWon) userInfo:nil repeats:FALSE];
}

-(float)calculcateModelTime
{
	return [mapParser.elements count] * 10;
}

-(BOOL)checkWinConditions
{
	updatePhysics = FALSE;
	
	int bonuses = 0;
	for(Bonus* bonus in  mapParser.bonuses)
	{
		if(bonus.collected)
			bonuses++;
	}
	TimeType mapTime = 0;
	if(gameTimer)
		mapTime = gameTimer->time;
	int bonusTime = ceil(modelTime - mapTime);
	bonusTime = MAX(0, bonusTime);
	int bonusScore = 0;
	if(bonusTime > 0)
		bonusScore = ((score + bonusTime*100)*bonuses)/10;

	//TEMP
	GameController* gc = (GameController*)[[Application sharedRootController] getChild:CHILD_GAME];
	GameView* view = (GameView*)[gc getView:VIEW_GAME];
	Image* menu = (Image*)[view getChild:VIEW_ELEMENT_WIN_MENU];

	
	BaseElement* winBox = [menu getChildWithName:@"winBox"];
	
	TextScores* text = (TextScores*)[winBox getChildWithName:@"winScore"];
	[text turnMaxAnimSteps:5];
	[text addPointsAnim:0 inTime:0.5 prefix:@""];
	[text addPointsAnim:score inTime:1 prefix:@""];
	[text addPointsAnim:0 inTime:1.3 prefix:@""];
	[text addPointsAnim:bonusScore inTime:1 prefix:@""];
	[text start];
	score += bonusScore;
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];	

	int expertBefore = [rc.user getNumberOfExpertLevels];
	[rc.user addScore:score bumperMultiplier:1 starBonuses:bonuses totalBonuses:[mapParser.bonuses count] time:bonusTime forMap:rc.selectedMap];
	int expertAfter = [rc.user getNumberOfExpertLevels];
	
	[self handleExpertLevelsCountBefore:expertBefore After:expertAfter];
	[self handleNewWin];
	
	TextScores* bonusesAnimation = (TextScores*)[winBox getChildWithName:@"bonusesAnimation"];
	int animSteps = ((bonusTime > 0) ? 10 : 6);
	[bonusesAnimation turnMaxAnimSteps:animSteps];
	[bonusesAnimation setPoints:score-bonusScore prefix:NSLocalizedString(@"STR_PREF_STAR_BONUS", @"    Star bonus: ")];
	[bonusesAnimation addPointsAnim:0 inTime:0.5 prefix:NSLocalizedString(@"STR_PREF_STAR_BONUS", @"    Star bonus: ")];
	[bonusesAnimation addPointsAnim:-(score-bonusScore) inTime:1 prefix:NSLocalizedString(@"STR_PREF_STAR_BONUS", @"    Star bonus: ")];
	[bonusesAnimation addPointsAnim:0 inTime:0.4 prefix:NSLocalizedString(@"STR_PREF_STAR_BONUS", @"    Star bonus: ")];

	if(bonusTime > 0)
	{
		[bonusesAnimation addPointsAnim:bonusScore inTime:0.4 prefix:nil];
		[bonusesAnimation addPointsAnim:0 inTime:0.5 prefix:NSLocalizedString(@"STR_PREF_TIME_BONUS", @"    Time bonus: ")];	
		[bonusesAnimation addPointsAnim:-bonusScore inTime:1 prefix:NSLocalizedString(@"STR_PREF_TIME_BONUS", @"    Time bonus: ")];
		[bonusesAnimation addPointsAnim:0 inTime:0.5 prefix:NSLocalizedString(@"STR_PREF_TIME_BONUS", @"    Time bonus: ")];
	}
	else
		[bonusesAnimation addPointsAnim:0 inTime:2.4 prefix:NSLocalizedString(@"STR_PREF_NO_TIMEBONUS", @"    No time bonus            ")];
	[bonusesAnimation addPointsAnim:0 inTime:0.4 prefix:nil];
#ifndef FREE
	if(rc.user.countryId != 0)
		[bonusesAnimation addPointsAnim:0 inTime:0.01 prefix:NSLocalizedString(@"STR_PREF_SCORE_IMPROVED", @"Team score improved!               ")];
	else
#endif
		[bonusesAnimation addPointsAnim:0 inTime:0.01 prefix:NSLocalizedString(@"STR_PREF_FINAL_SCORE", @"   Your final score!               ")];
	[bonusesAnimation start];
	
	FPScores* scores = [rc.user getScoresForMap:gc.selectedMap];
	int medal = (scores == nil) ? 0 : scores->medal;
	int lightsTurnedOn = medal;
	if(lightsTurnedOn > 3)lightsTurnedOn = 10;
	if(lightsTurnedOn > 1 && lightsTurnedOn < 4)lightsTurnedOn = 5;
	
	HBox* lights = (HBox*)[winBox getChildWithName:@"lights"];
	for (int i = 0; i < [lights childsCount]; i++) 
	{
		if(lightsTurnedOn > i)
		{
			Image* light = (Image*)[lights getChild:i];
			[light setDrawQuad:0];
		}
	}
	
	TextScores* countryScores = (TextScores*)[winBox getChildWithName:@"countryScores"];
	if(countryScores)
	{
		[countryScores turnMaxAnimSteps:2];
		[countryScores addPointsAnim:0 inTime:4.3 prefix:@""];
		[countryScores addPointsAnim:score inTime:1 prefix:@""];
		[countryScores start];
	}

	TextScores* stateScores = (TextScores*)[winBox getChildWithName:@"stateScores"];
	if(stateScores)
	{
		[stateScores turnMaxAnimSteps:2];
		[stateScores addPointsAnim:0 inTime:4.3 prefix:@""];
		[stateScores addPointsAnim:score inTime:1 prefix:@""];
		[stateScores start];
	}
	//TEMP
//	[delegate gameWon];
//	[self createWinParticles];
		
	int tutorialLevel = rc.user.tutorialLevel;	
	if (tutorialLevel == 0 || tutorialLevel == 14)
	{			
		int strID = ((tutorialLevel == 0)? STR_TUTORIAL_TUTORIAL_01_WIN : STR_TUTORIAL_TUTORIAL_15_WIN);

		View* view = [[[Application sharedRootController] getCurrentController] activeView];		
		[Baloon showBaloonWithID:strID Text:TUTORIAL[strID] 
						   Image:[Image createWithResID:IMG_PERSONAGES Quad:IMG_PERSONAGES_dude01] Blocking:TRUE Type:BALOON_SINGLE inView:view Delegate:self];		
	}
	else
	{
		[self winCameraScroll];		
	}
	
	return TRUE;
}

-(b2Shape*)getShapeWithBodyName:(NSString*)bodyName fromContact:(const b2ContactPoint*)contact
{
	FPBody* b1 = (FPBody*)contact->shape1->GetBody()->GetUserData();
	FPBody* b2 = (FPBody*)contact->shape2->GetBody()->GetUserData();
	
	if([b1.name isEqualToString:bodyName])
	{
		return contact->shape1;
	}
	else if([b2.name isEqualToString:bodyName])
	{
		return contact->shape2;
	}
	return nil;
}

-(BOOL)checkWinContact:(const b2ContactPoint*)contact
{
	b2Shape* shape = [self getShapeWithBodyName:@"bumper" fromContact:contact];
	if (shape)
	{
		switch (shape->GetType())
		{
			case e_circleShape:
			{
				b2CircleShape* circle = (b2CircleShape*)shape;
				circle->GetLocalPosition();
				b2Vec2 center = b2Mul(circle->GetBody()->GetXForm(), circle->GetLocalPosition());
				b2Vec2 offset = center - contact->position;
				center *= PTM_RATIO;
				offset *= PTM_RATIO;
				float degrees = RADIANS_TO_DEGREES( atan2(offset.x, offset.y) );
				while(degrees < 0)
				{
					degrees+=360;
				}
//				NSLog(@"%f", degrees);
				break;
			}
			default:
				break;
		}		
	}
	
	b2Shape* eggShape = [self getShapeWithBodyName:@"egg" fromContact:contact];
	if(eggShape)
	{
		score += 10;
		[ChampionsSoundMgr playSound:SND_BUMPER];
		[self checkWinConditions];
		[self handleBumperStriked];
	}
	return FALSE;
}


-(BOOL)checkLooseConditions
{
	return FALSE;
}

-(void)bonusCollected:(Bonus*)bonus
{
	if(!bonus.collected)
	{
		[ChampionsSoundMgr playSound:SND_STARS];
		bonus->color = whiteRGBA;
		bonusesCollected++;
		bonus.collected = TRUE;
		[bonus setMode:MODE_ACTIVE];
		score += bonusesCollected*100;
//		NSLog(@"bonus %i", score);
		
		[self handleStarCollected];
	}
}

-(void)bonusUncollected:(Bonus*)bonus
{
	if(bonus.collected)
	{
//		bonus->color = MakeRGBA(1, 1, 1, 0.5);
		bonus.collected = FALSE;
		[bonus setMode:MODE_STATIC];
		score -= bonusesCollected*100;
		bonusesCollected--;
//		NSLog(@"%i", score);
	}
}

-(void)moveShockWaves:(float)cDelta
{
	int wavesCount = [shockWaves count];
	
	for(int i = 0; i < wavesCount; i++)
	{
		ShockWave* sw = [shockWaves objectAtIndex:i];
		float swSpeed = mapParser.settings->shockWaveSpeed;
		sw->currentRadius += swSpeed*cDelta;
		
		for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
		{
			b2Vec2 pos = b->GetWorldCenter();
			pos *= PTM_RATIO;
			b2Vec2 diff =  pos - b2Vec2(sw->position.x, sw->position.y);
			float dist = diff.Length();
			if( dist < sw->currentRadius && dist > (sw->currentRadius-sw->initialRadius) )
			{
				diff *= sw->initialImpulse/dist;
				if(b->GetLinearVelocity().Length() < mapParser.settings->maxShockWaveBodyVelocity)
					b->ApplyImpulse(diff, b->GetWorldCenter());
			}
		}
	}
	
	float maxRadius = mapParser.settings->shockWaveMaxRadius;
	wavesCount = [shockWaves count];	
	for(int i = wavesCount-1; i >= 0; i--)
	{
		ShockWave* sw = [shockWaves objectAtIndex:i];
		if (sw->currentRadius > maxRadius)
		{
			[shockWaves removeObjectAtIndex:i];
		}
	}	
}

-(void)addObjectToDeleteQueue:(FPBody*)body
{
	for (int i = 0; i < [deleteQueue count]; i++)
	{
		FPBody* b = [deleteQueue objectAtIndex:i];
		if(b == body)
			return;
	}
	
	if(![body.name isEqualToString:@"egg"] || ![body.name isEqualToString:@"bonus_star"])
		[deleteQueue addObject:body];
}

-(void)timerFinished
{	
//	NSLog(@"timer finished");
}

-(void)addExplodableParticles:(b2Body*)b
{
	[ChampionsSoundMgr playSound:SND_EXPLODE];
	
	b2Shape* s = b->GetShapeList();
	b2AABB aabb;
	s->ComputeAABB(&aabb, b->GetXForm());		
	
	b2Vec2 max = aabb.upperBound;
	b2Vec2 min = aabb.lowerBound;
	for (b2Shape* s = b->GetShapeList(); s; s = s->GetNext())
	{
		b2AABB aabb;
		s->ComputeAABB(&aabb, b->GetXForm());		
		min = b2Min(min, aabb.lowerBound);
		min = b2Min(min, aabb.upperBound);
		max = b2Max(max, aabb.lowerBound);
		max = b2Max(max, aabb.upperBound);
	}
	Image* ig = [[[Image alloc] initWithTexture:[ChampionsResourceMgr getResource:IMG_GLASS_PART]] autorelease];
	GLGlassBreak* gb = [[[GLGlassBreak alloc] initWithImageGrid:ig] autorelease];
//	gb->color = (RGBAColor)RGBA_FROM_HEX(255, 88, 0, 128);
	gb->startColor = (RGBAColor)RGBA_FROM_HEX(255, 88, 0, 128);
	gb->endColor = (RGBAColor)RGBA_FROM_HEX(255, 88, 0, 0);
	gb->anchor = CENTER;
	gb->parentAnchor = TOP | LEFT;
	Vector posVar;
	posVar.x = (max.x - min.x)/2;
	posVar.y = (max.y - min.y)/2;
	posVar = vectMult(posVar, PTM_RATIO);
	
	gb->x = min.x * PTM_RATIO + posVar.x;
	gb->y = max.y * PTM_RATIO - posVar.y;
	[gb setPosVar:posVar];
	[gb startSystem:gb.totalParticles];
	
	[particlesContainer addChild:gb];
}

#ifdef CHEAT
-(void)cheatWinGame
{
	if(updatePhysics)
	{
		for(Bonus* bonus in  mapParser.bonuses)
		{
			if(!bonus.collected)
			{
				[self bonusCollected:bonus];
			}
		}
		[self checkWinConditions];
	}
}
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)handleBlockBreaked
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;
	
	switch (++rc.user.brokenBlocks)
	{
		case 10:
			[GameController unlockAchievement:AC_Crow_Bar_Test];
			break;
			
		case 50:
			[GameController unlockAchievement:AC_Brickbreaker];
			break;

		case 100:
			[GameController unlockAchievement:AC_Pneumatic_Finger];
			break;

		case 1000:
			[GameController unlockAchievement:AC_Sledgehammer];
			break;									
	}	
}

-(void)handleStarCollected
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;

	switch (++rc.user.collectedStars)
	{
		case 100:
			[GameController unlockAchievement:AC_Junkie];
			break;
			
		case 500:
			[GameController unlockAchievement:AC_Star_Gazer];
			break;
			
		case 2000:
			[GameController unlockAchievement:AC_Astrologer];
			break;
			
		case 10000:
			[GameController unlockAchievement:AC_Astronaut];
			break;									
	}	
}

-(void)handleBumperStriked
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;

	switch (++rc.user.bumperStrikes)
	{
		case 10:
			[GameController unlockAchievement:AC_Golden_Wheel];
			break;
			
		case 50:
			[GameController unlockAchievement:AC_Russian_Roulette];
			break;
			
		case 100:
			[GameController unlockAchievement:AC_Spintastic];
			break;
			
		case 1000:
			[GameController unlockAchievement:AC_Spin_Master];
			break;									
	}	
}

-(void)handleBlockStacked
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;

	switch (++rc.user.blocksStacked)
	{
		case 100:
			[GameController unlockAchievement:AC_Laborer];
			break;
			
		case 500:
			[GameController unlockAchievement:AC_Builder];
			break;
			
		case 1000:
			[GameController unlockAchievement:AC_Engineer];
			break;
			
		case 5000:
			[GameController unlockAchievement:AC_Foreman];
			break;									
	}	
}

-(void)handleBlockExploded
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;

	switch (++rc.user.explodedBlocks)
	{
		case 10:
			[GameController unlockAchievement:AC_Minesweeper];
			break;
			
		case 50:
			[GameController unlockAchievement:AC_Fireworks];
			break;
			
		case 100:
			[GameController unlockAchievement:AC_Sapper];
			break;
			
		case 1000:
			[GameController unlockAchievement:AC_Bomb_Squad];
			break;									
	}	
}

-(void)handleMagnetConnected
{
	if (skipMagnet)
	{
		skipMagnet = FALSE;
		return;
	}
	
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;

	switch (++rc.user.connectedMagnets)
	{
		case 10:
			[GameController unlockAchievement:AC_Magnetic_Force];
			break;
			
		case 50:
			[GameController unlockAchievement:AC_Pole_Attraction];
			break;
			
		case 100:
			[GameController unlockAchievement:AC_Force_Field];
			break;
			
		case 1000:
			[GameController unlockAchievement:AC_North_Pole];
			break;									
	}	
	skipMagnet = TRUE;
}

-(void)handleExpertLevelsCountBefore:(int)bc After:(int)ac 
{
	if (bc == ac) return;

	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;
	
	switch (ac)
	{
		case 1:
			[GameController unlockAchievement:AC_Fingertip_Facile];
			break;
			
		case 10:
			[GameController unlockAchievement:AC_Handyman];
			break;
			
		case 20:
			[GameController unlockAchievement:AC_Phalange_Phenomenon];
			break;
			
		case 50:
			[GameController unlockAchievement:AC_Finger_Whiz];
			break;									
	}	
}

-(void)handleBeatenOwnScore 
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;

	switch (++rc.user.ownHighscoreBeatenCount)	
	{
		case 2:
			[GameController unlockAchievement:AC_Shadow_Fight];
			break;
			
		case 5:
			[GameController unlockAchievement:AC_5th_Power];
			break;
			
		case 10:
			[GameController unlockAchievement:AC_Altius_Citius_Fortius];
			break;
			
		case 50:
			[GameController unlockAchievement:AC_Beat_That];
			break;									
	}	
}

-(void)handleBeatenOwnTime 
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;

	switch (++rc.user.ownBestTimeBeatenCount)	
	{
		case 2:
			[GameController unlockAchievement:AC_Accelerator];
			break;
			
		case 5:
			[GameController unlockAchievement:AC_Chronometer];
			break;
			
		case 10:
			[GameController unlockAchievement:AC_Tick_Tock];
			break;
			
		case 50:
			[GameController unlockAchievement:AC_Time_Traveler];
			break;									
	}	
}

+(void)handleBeatenOwnScore 
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;
	
	switch (++rc.user.ownHighscoreBeatenCount)	
	{
		case 2:
			[GameController unlockAchievement:AC_Shadow_Fight];
			break;
			
		case 5:
			[GameController unlockAchievement:AC_5th_Power];
			break;
			
		case 10:
			[GameController unlockAchievement:AC_Altius_Citius_Fortius];
			break;
			
		case 50:
			[GameController unlockAchievement:AC_Beat_That];
			break;									
	}	
}

+(void)handleBeatenOwnTime 
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;
	
	switch (++rc.user.ownBestTimeBeatenCount)	
	{
		case 2:
			[GameController unlockAchievement:AC_Accelerator];
			break;
			
		case 5:
			[GameController unlockAchievement:AC_Chronometer];
			break;
			
		case 10:
			[GameController unlockAchievement:AC_Tick_Tock];
			break;
			
		case 50:
			[GameController unlockAchievement:AC_Time_Traveler];
			break;									
	}	
}

-(void)handleNewWin
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;

	if (++rc.user.levelsWoninARow == 3)
	{
		[GameController unlockAchievement:AC_Trial];
		rc.user.levelsWoninARow = 0;
	}
	
}

-(void)handleNewLose
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc.user.tutorialLevel != UNDEFINED)	return;

	if (rc.user.levelsWoninARow != 0)
	{
		rc.user.levelsWoninARow = 0;
	}
}

@end
