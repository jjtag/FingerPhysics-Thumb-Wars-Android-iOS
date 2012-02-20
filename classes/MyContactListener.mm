/*
 *  MyContactListener.mm
 *  adventures
 *
 *  Created by ikoryakin on 2/5/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "MyContactListener.h"
#include "Bonus.h"
#include "ShockWave.h"
#import "res.h"
#import "ChampionsSoundMgr.h"

FPBody* GetBodyWithName(NSString* name, FPBody* body1, FPBody* body2)
{
	if(body1 && body2)
	{
		if([body1.name isEqualToString:name])
		{
			return body1;
		} else	if([body2.name isEqualToString:name])
		{
			return body2;
		}
	}	
	return nil;
}

void MyContactListener::Add(const b2ContactPoint* point)
{	
	b2Body* b1 = point->shape1->GetBody();
	b2Body* b2 = point->shape2->GetBody();
	FPBody* body1 = (FPBody*)b1->GetUserData();
	FPBody* body2 = (FPBody*)b2->GetUserData();
	FPBody *egg, *bumper, *bonus, *floor;
	
	if(body1 && body2)
	{
		egg = GetBodyWithName(@"egg", body1, body2);
		bumper = GetBodyWithName(@"bumper", body1, body2);
		bonus = GetBodyWithName(@"bonus_star", body1, body2);
		floor = GetBodyWithName(@"floor", body1, body2);
		
		if(egg && (bumper || floor))
		{
			if(gameScene)
			{
				Timeline* t = [gameScene.eggAnimation getCurrentTimeline];				
				if(!t || t->state != TIMELINE_PLAYING)
				{
					[gameScene.eggAnimation setDrawQuad:IMG_EGG_GLOW_2];
					[gameScene.eggAnimation playTimeline:0];
				}
				[gameScene checkWinContact:point];
			}
		}
		
		if(bonus && egg)
		{
			Timeline* t = [gameScene.eggAnimation getCurrentTimeline];				
			if(!t || t->state != TIMELINE_PLAYING)
			{
				[gameScene.eggAnimation setDrawQuad:IMG_EGG_GLOW_2];
				[gameScene.eggAnimation playTimeline:0];
			}
			if([bonus.userData isKindOfClass:[Bonus class]])
			{
				Bonus* b = bonus.userData;
				[gameScene bonusCollected:b];
			}
		}
#pragma mark Magnets		
		if(body1->charge != 0)
		{
			if(body2->charge == -body1->charge)
			{
				int jointsNum = 0;
				b2Vec2 anchor = b2Vec2_zero;
				for (b2JointEdge* j = b1->GetJointList(); j; j = j->next)
				{
					if(j->other == b2)
					{
						if(jointsNum == 0)
						{
							anchor = j->joint->GetAnchor1();
						}
						jointsNum++;
					}
					if(jointsNum > 1)break;
				}
				
				if(jointsNum < 2)
				{
					b2Vec2 sub = point->position - anchor;
					float slength = sub.Length();
					if(jointsNum == 0 || slength > gameScene.mapParser.settings->magnetMinJointDistance)
					{
						b2Vec2 offset = point->position - b1->GetPosition();
						b2Vec2 offset2 = point->position - b2->GetPosition();
						FPJoint* joint = [[[FPJoint alloc] init] autorelease];
						joint->type = 3;
						joint->body1Id = body1.uniqId;
						joint->body2Id = body2.uniqId;
						joint->rotationOffset = vect(offset.x, offset.y);
						joint->offsetBody1 = vect(offset.x, offset.y);
						joint->offsetBody2 = vect(offset2.x, offset2.y);
						joint->collideConnected = TRUE;
						joint->dampingRatio = gameScene.mapParser.settings->magnetDampingRatio;
						joint->freqHz = gameScene.mapParser.settings->magnetFreqHz;
						BOOL similar = FALSE;
						for (int i = 0; i < [gameScene.jointsQueue count]; i++)
						{
							FPJoint* j = [gameScene.jointsQueue objectAtIndex:i];
							if(joint->body1Id == j->body1Id && joint->body2Id == j->body2Id
							   && joint->type == j->type && 
								(vectDistance(joint->offsetBody1, j->offsetBody1) < gameScene.mapParser.settings->magnetMinJointDistance ||
								 vectDistance(joint->offsetBody2, j->offsetBody2) < gameScene.mapParser.settings->magnetMinJointDistance
								 )
							   )
							{
								similar = TRUE;
								break;
							}
						}
						
						if (!similar)
						{
							if(body1.isTouchable)
								body1.blockColor = whiteRGBA;
							else
								body1.blockBackColor = whiteRGBA;
							
							if(body2.isTouchable)
								body2.blockColor = whiteRGBA;
							else
								body2.blockBackColor = whiteRGBA;
							
							[gameScene.jointsQueue addObject:joint];
							[ChampionsSoundMgr playSound:SND_MAGNET_IO];
							[gameScene handleMagnetConnected];
						}

					}
				}
			}
			
			if (body1->charge == body2->charge)
			{
				b2Vec2 impulse;
				impulse = point->normal;
				impulse *= b1->GetMass();
				impulse *= -gameScene.mapParser.settings->magnetImpulseMultiplier;

				b2Vec2 impulse2;
				impulse2 = point->normal;
				impulse2 *= b2->GetMass();
				impulse2 *= gameScene.mapParser.settings->magnetImpulseMultiplier;
				
				b2Vec2 vel = b2->GetLinearVelocity();
				b1->ApplyImpulse(impulse, b1->GetWorldCenter());
				b2->ApplyImpulse(impulse2, b2->GetWorldCenter());
				
				if(body1.isTouchable)
					body1.blockColor = whiteRGBA;
				else
					body1.blockBackColor = whiteRGBA;
				
				if(body2.isTouchable)
					body2.blockColor = whiteRGBA;
				else
					body2.blockBackColor = whiteRGBA;
				
				[ChampionsSoundMgr playSound:SND_MAGNET_II];					
			}
		}
#pragma mark Explodable
		if(body1->isExplodable && body2->isExplodable && [gameScene.deleteQueue count] == 0)
		{
			[gameScene addObjectToDeleteQueue:body1];
			[gameScene addObjectToDeleteQueue:body2];
			float shockWidth = gameScene.mapParser.settings->shockWaveWidth;
			float shockWaveImpulseFactor = gameScene.mapParser.settings->shockWaveImpulseFactor;
			
			Vector pos = vect(point->position.x, point->position.y);
			pos = vectMult(pos, PTM_RATIO);
			ShockWave* sw = [[ShockWave alloc] initWith:pos andWidth:shockWidth andImpulseFactor:shockWaveImpulseFactor];				
			[gameScene.shockWaves addObject:sw];
			[sw release];
			[gameScene addExplodableParticles:b1];
			[gameScene addExplodableParticles:b2];
			
			[gameScene handleBlockExploded];
		}
	}
}

void MyContactListener::Persist(const b2ContactPoint* point)
{
	b2Body* b1 = point->shape1->GetBody();
	b2Body* b2 = point->shape2->GetBody();
	FPBody* body1 = (FPBody*)b1->GetUserData();
	FPBody* body2 = (FPBody*)b2->GetUserData();
	FPBody* bonus;
	
	if(body1 && body2)
	{
		bonus = GetBodyWithName(@"bonus_star", body1, body2);
		
		if(bonus && (gameScene.mapParser.settings.mode == 2))
		{
			if([bonus.userData isKindOfClass:[Bonus class]])
			{
				Bonus* b = bonus.userData;
				b.timer = 0.2;
//				if(!gameScene->m_mouseJoint)
					[gameScene bonusCollected:b];
			}
		}
	}
}

void MyContactListener::Remove(const b2ContactPoint* point)
{
//	b2Body* b1 = point->shape1->GetBody();
//	b2Body* b2 = point->shape2->GetBody();
//	FPBody* body1 = (FPBody*)b1->GetUserData();
//	FPBody* body2 = (FPBody*)b2->GetUserData();
//	FPBody *egg, *bumper, *bonus, *floor;
//	
//	if(body1 && body2)
//	{
//		egg = GetBodyWithName(@"egg", body1, body2);
//		bumper = GetBodyWithName(@"bumper", body1, body2);
//		bonus = GetBodyWithName(@"bonus_star", body1, body2);
//		floor = GetBodyWithName(@"floor", body1, body2);
//
//		if(bonus && gameScene.mapParser.settings.mode == 2)
//		{
//			if([bonus.userData isKindOfClass:[Bonus class]])
//			{
////				Bonus* b = bonus.userData;
////				NSLog(@"bonus is not colliding");
////				b.isColliding = FALSE;
////				NSLog(@"bonus removed");
////				[gameScene bonusUncollected:b];
//			}	
//		}		
//	}
}

void MyContactListener::Result(const b2ContactResult* point)
{
}