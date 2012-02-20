//
//  GameScene.h
//  champions
//
//  Created by Mac on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <Box2D.h>
#import "BaseElement.h"
#import "AnimationsPool.h"
#import "Text.h"
#import "GLES-Render.h"
#import "MapParser.h"
#import "Joystick.h"
#import "Bonus.h"
#import "FPCamera2D.h"
#import "Arc.h"
#import "GameTimer.h"
#import "Baloon.h"

#define CAMERA_SPEED 300
#define RETURN_CAMERA_DELAY 2

class MyContactListener;

@protocol GameSceneDelegate
-(void)gameWon; 
-(void)gameLost; 
@optional
-(void)startTimer;
-(void)stopTimer;
@end

@interface GameScene : BaseElement <JoystickProtocol, BaloonDelegate>
{
	id <GameSceneDelegate> delegate;
	b2World* world;
//	GLESDebugDraw *m_debugDraw;
	MapParser* mapParser;
	int physIterations;
	FPCamera2D* camera;
	float maxCameraPosY;
	float returnCameraDelay;
	b2Vec2 mouseJointLocation;
	FPBody* focusBody;
	MyContactListener* contact_listener;
	DynamicArray* px;
	DynamicArray* jointsQueue;
	DynamicArray* shockWaves;
	DynamicArray* deleteQueue;

	BOOL updatePhysics;
	BOOL manualCamera;
	float cameraOffsetX;
	float cameraOffsetY;
	int score;
	int bonusesCollected;
	RGBAColor touchzoneColor;
	FPBody* queuedObject;
	FPBody* egg;
	b2MouseJoint* queueMouseJoint;
	BOOL focusOnMouseJoint;
	b2Vec2 queuedObjectlastPos;
	//Эталонное время прохождения
	float modelTime;
	AnimationsPool* particlesContainer;
	GameTimer* gameTimer;
	//egg specific
	Image* eggAnimation;
	Image* eggTrace;
#ifdef CHEAT
	int cheatTouches;
#endif
@public
	b2MouseJoint* m_mouseJoint;
	
	// achievement helpers
	//////////////////////////////////////////////////////////////////////
	bool queuedObjectTaken;
	bool skipMagnet;
}

-(void)createWinParticles;
-(void)reset;
-(void)initPhysics;
-(void)createObjects;
-(void)addObjectAtX:(float)tx Y:(float)ty;
-(b2Body*)createBody:(FPBody*)b;
-(void)createShape:(FPShape*)shape forBody:(FPBody*)fpBody;
-(void)makeMouseJoint:(b2Body*)body point:(b2Vec2)p;
-(void)destroyMouseJoint;
-(void)computeMass:(FPBody*)b;
-(void)destroyBlock:(FPBody*)body;
-(void)processJointQueue;
-(void)processDeleteQueue;
-(void)moveShockWaves:(float)cDelta;
-(void)addObjectToDeleteQueue:(FPBody*)body;
-(void)ApplyForceForBody:(FPBody*)b;

-(void)cameraAutoFocus;
-(void)setNextQueuedObject;
-(void)drawGradient;
-(void)drawBack;
-(void)drawParallaxObjects;
-(BOOL)checkLooseConditions;
-(BOOL)checkWinConditions;
-(void)winCameraScroll;
-(BOOL)checkWinContact:(const b2ContactPoint*)contact;
-(void)bonusCollected:(Bonus*)bonus;
-(void)bonusUncollected:(Bonus*)bonus;
-(void)updateBonuses:(TimeType)delta;
-(float)calculcateModelTime;

-(void)timerFinished;
-(void)addExplodableParticles:(b2Body*)b;
-(void)processCamera:(TimeType)delta;
-(b2AABB)computeBodyBB:(b2Body*)body;

// achievement methods
-(void)handleBlockBreaked;
-(void)handleStarCollected;
-(void)handleBumperStriked;
-(void)handleBlockStacked;
-(void)handleBlockExploded;
-(void)handleMagnetConnected;
-(void)handleExpertLevelsCountBefore:(int)bc After:(int)ac;
-(void)handleNewWin;
-(void)handleNewLose;

+(void)handleBeatenOwnScore; 
+(void)handleBeatenOwnTime;

#ifdef CHEAT
-(void)cheatWinGame;
#endif
@property (assign) Image *eggAnimation;
@property (assign) DynamicArray *jointsQueue, *shockWaves, *deleteQueue;
@property (assign) id <GameSceneDelegate> delegate;
@property (nonatomic, retain) MapParser* mapParser;
@property (retain) GameTimer* gameTimer;
@end
