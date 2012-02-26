//
//  GLParticleSystems.m
//  frameworkTest
//
//  Created by Mac on 13.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ParticlesFactory.h"

@implementation GLGlassBreak

-(id) initWithImageGrid:(Image*)image
{
	return [self initWithTotalParticles:50 andImageGrid:image];
}

-(id) initWithTotalParticles:(int)p andImageGrid:(Image*)image
{
	if(!(self=[super initWithTotalParticles:p andImageGrid:image]))
	{
		return nil;
	}

	// additive
	blendAdditive = TRUE;	
	
	// duration
	duration = 0;
	
	// gravity
	gravity.x = 0;
	gravity.y = 200;
	
	// angle
	angle = 90;
	angleVar = 360;
	
	// speed of particles
	speed = 70;
	speedVar = 5;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 0;
	
	// tagential
	tangentialAccel = 0;
	tangentialAccelVar = 0;
	
	// emitter position
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 1;
	lifeVar = 1;
	
	// size, in pixels
	size = 0.7f;
	sizeVar = 0.3f;
	
	// emits per second
	emissionRate = totalParticles / life;
	
	// color of particles
	startColor.r = 1.0f;
	startColor.g = 1.0f;
	startColor.b = 1.0f;
	startColor.a = 1.0f;
	startColorVar.r = 0.0f;
	startColorVar.g = 0.0f;
	startColorVar.b = 0.2f;
	startColorVar.a = 0.1f;
	endColor.r = 0.0f;
	endColor.g = 0.0f;
	endColor.b = 0.0f;
	endColor.a = 1.0f;
	endColorVar.r = 0.0f;
	endColorVar.g = 0.0f;
	endColorVar.b = 0.0f;
	endColorVar.a = 0.0f;
	
	return self;		
}

@end

@implementation GLTest

-(id) initWithTotalParticles:(int) p andImageGrid:(Image*)grid
{
	if(!(self=[super initWithTotalParticles:p andImageGrid:grid]))
	{		
		return nil;
	}
	
	
	// additive
	blendAdditive = TRUE;	
	
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = 90;
	angleVar = 360;
	
	// speed of particles
	speed = 50;
	speedVar = 20;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 0;
	
	// tagential
	tangentialAccel = 0;
	tangentialAccelVar = 0;
	
	// emitter position
	posVar.x = 30;
	posVar.y = 30;
	
	// life of particles
	life = 1;
	lifeVar = 0.5;
	
	// size, in pixels
	size = 1.0f;
	sizeVar = 1.0f;
	
	// emits per second
	emissionRate = totalParticles / life;
	
	// color of particles
	startColor.r = 1.0f;
	startColor.g = 1.0f;
	startColor.b = 1.0f;
	startColor.a = 1.0f;
	startColorVar.r = 0.0f;
	startColorVar.g = 0.0f;
	startColorVar.b = 0.2f;
	startColorVar.a = 0.1f;
	endColor.r = 0.0f;
	endColor.g = 0.0f;
	endColor.b = 0.0f;
	endColor.a = 1.0f;
	endColorVar.r = 0.0f;
	endColorVar.g = 0.0f;
	endColorVar.b = 0.0f;
	endColorVar.a = 0.0f;
	
	return self;		
}

@end

@implementation GLVulcanoParticles

-(id) initWithTotalParticles:(int) p andImageGrid:(Image*)grid
{
	if(!(self=[super initWithTotalParticles:p andImageGrid:grid]))
	{		
		return nil;
	}
	
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = -1;
	
	// angle
	angle = -90;
	angleVar = 5;
	
	// speed of particles
	speed = 5;
	speedVar = 1;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 1;
	
	// tagential
	tangentialAccel = 0;
	tangentialAccelVar = 1;
	
	// emitter position
	posVar.x = SCREEN_WIDTH / 2;
	posVar.y = 0;
	
	// life of particles
	life = 20;
	lifeVar = 10;
	
	// size, in pixels
	size = 1.5f;
	sizeVar = 0.5f;
	
	// emits per second
	emissionRate = 10;
	
	// color of particles
	startColor.r = 1.0f;
	startColor.g = 1.0f;
	startColor.b = 1.0f;
	startColor.a = 1.0f;
	startColorVar.r = 0.0f;
	startColorVar.g = 0.0f;
	startColorVar.b = 0.0f;
	startColorVar.a = 0.0f;
	endColor.r = 0.0f;
	endColor.g = 0.0f;
	endColor.b = 0.0f;
	endColor.a = 0.0f;
	endColorVar.r = 0.0f;
	endColorVar.g = 0.0f;
	endColorVar.b = 0.0f;
	endColorVar.a = 0.0f;

	// additive
	blendAdditive = TRUE;
	
	return self;		
}

@end

@implementation GLBubbleParticles

-(id) initWithTotalParticles:(int) p andImageGrid:(Image*)grid
{
	if(!(self=[super initWithTotalParticles:p andImageGrid:grid]))
	{		
		return nil;
	}
	
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = -1;
	
	// angle
	angle = -90;
	angleVar = 5;
	
	// speed of particles
	speed = 5;
	speedVar = 1;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 1;
	
	// tagential
	tangentialAccel = 0;
	tangentialAccelVar = 1;
	
	// emitter position
	posVar.x = SCREEN_WIDTH / 2;
	posVar.y = 0;
	
	// life of particles
	life = 20;
	lifeVar = 10;
	
	// size, in pixels
	size = 1.5f;
	sizeVar = 0.5f;
	
	// emits per second
	emissionRate = 10;
	
	// color of particles
	startColor.r = 1.0f;
	startColor.g = 1.0f;
	startColor.b = 1.0f;
	startColor.a = 1.0f;
	startColorVar.r = 0.0f;
	startColorVar.g = 0.0f;
	startColorVar.b = 0.0f;
	startColorVar.a = 0.0f;
	endColor.r = 1.0f;
	endColor.g = 1.0f;
	endColor.b = 1.0f;
	endColor.a = 1.0f;
	endColorVar.r = 0.0f;
	endColorVar.g = 0.0f;
	endColorVar.b = 0.0f;
	endColorVar.a = 0.0f;
	
	// additive
	blendAdditive = FALSE;
	
	return self;		
}

@end


@implementation GLFireworks

-(id) initWithTotalParticles:(int) p andImageGrid:(Image*)grid
{
	if(!(self=[super initWithTotalParticles:p andImageGrid:grid]))
	{		
		return nil;
	}
	
	// additive
	blendAdditive = TRUE;	
	
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = 500;
	
	// angle
	angle = -280;
	angleVar = 40;
	
	// speed of particles
	speed = 350;
	speedVar = 50;
	
	// radial
	radialAccel = 0;
	radialAccelVar = 0;
	
	// tagential
	tangentialAccel = 0;
	tangentialAccelVar = 0;
	
	// emitter position
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 2;
	lifeVar = 0.5;
	
	// size, in pixels
	size = 0.2f;
	sizeVar = 0.1f;
	
	// emits per second
	emissionRate = totalParticles * 2 / life;
	
	// color of particles
	startColor.r = 1.0f;
	startColor.g = 1.0f;
	startColor.b = 1.0f;
	startColor.a = 1.0f;
	startColorVar.r = 0.0f;
	startColorVar.g = 0.0f;
	startColorVar.b = 0.2f;
	startColorVar.a = 0.1f;
	endColor.r = 0.0f;
	endColor.g = 0.0f;
	endColor.b = 0.0f;
	endColor.a = 1.0f;
	endColorVar.r = 0.0f;
	endColorVar.g = 0.0f;
	endColorVar.b = 0.0f;
	endColorVar.a = 0.0f;
	
	return self;		
}

@end

@implementation GLSun

-(id) initWithTexture:(Texture2D*)t
{
	if (self = [self initWithTotalParticles:150])
	{		
		texture = [t retain];
	}
	
	return self;
}

-(id) initWithTotalParticles:(int) p
{
	if(!(self=[super initWithTotalParticles:p]))
	{		
		return nil;
	}
	
	// additive
	blendAdditive = TRUE;
	
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = 90;
	angleVar = 360;
	
	// radial acceleration
	radialAccel = 0;
	radialAccelVar = 0;	
	
	// emitter position
	posVar.x = 0;
	posVar.y = 0;
	
	// life of particles
	life = 1;
	lifeVar = 0.5f;
	
	// speed of particles
	speed = 20;
	speedVar = 5;
	
	// size, in pixels
	size = 30.0f;
	sizeVar = 10.0f;
	
	// emits per seconds
	emissionRate = totalParticles/life;
	
	// color of particles
	startColor.r = 0.76f;
	startColor.g = 0.25f;
	startColor.b = 0.12f;
	startColor.a = 1.0f;
	startColorVar.r = 0.0f;
	startColorVar.g = 0.0f;
	startColorVar.b = 0.0f;
	startColorVar.a = 0.0f;
	endColor.r = 0.0f;
	endColor.g = 0.0f;
	endColor.b = 0.0f;
	endColor.a = 1.0f;
	endColorVar.r = 0.0f;
	endColorVar.g = 0.0f;
	endColorVar.b = 0.0f;
	endColorVar.a = 0.0f;
	
	return self;	
}
@end 

//
// ParticleSmoke
//
@implementation GLSmokeParticles

-(id)initWithTexture:(Texture2D*)t
{
	if (self = [self initWithTotalParticles:50])
	{		
		texture = [t retain];
	}
	
	return self;
}


-(id) initWithTotalParticles:(int)p
{
	if(!(self=[super initWithTotalParticles:p]))
	{		
		return nil;
	}
	// duration
	duration = -1;
	
	// gravity
	gravity.x = 0;
	gravity.y = 0;
	
	// angle
	angle = -90.0;
	angleVar = 5;
	
	// radial acceleration
	radialAccel = 0;
	radialAccelVar = 0;
	
	// emitter position
//	position.x = 160;
//	position.y = 0;
	posVar.x = 15;
	posVar.y = 0;
	
	// life of particles
	life = 8;
	lifeVar = 4;
	
	// speed of particles
	speed = 20;
	speedVar = 7;
	
	// size, in pixels
	size = 60.0f;
	sizeVar = 10.0f;
	
	// emits per frame
	emissionRate = totalParticles/life;
	
	// color of particles
//	startColor.r = 0.7f;
//	startColor.g = 0.7f;
//	startColor.b = 0.7f;
//	startColor.a = 1.0f;
//	startColorVar.r = 0.02f;
//	startColorVar.g = 0.02f;
//	startColorVar.b = 0.02f;
//	startColorVar.a = 0.0f;
	startColor.r = 1.0f;
	startColor.g = 1.0f;
	startColor.b = 1.0f;
	startColor.a = 1.0f;
	startColorVar.r = 0.0f;
	startColorVar.g = 0.0f;
	startColorVar.b = 0.0f;
	startColorVar.a = 0.0f;
	
	endColor.r = 1.0f;
	endColor.g = 1.0f;
	endColor.b = 1.0f;
	endColor.a = 0.0f;
	endColorVar.r = 0.0f;
	endColorVar.g = 0.0f;
	endColorVar.b = 0.0f;
	endColorVar.a = 0.0f;
	
//	texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.png"];
//	[texture retain];
	
	// additive
	blendAdditive = TRUE;
	
	return self;
}
@end