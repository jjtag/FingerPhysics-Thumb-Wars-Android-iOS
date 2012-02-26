//
//  GLParticles.h
//  blockit
//
//  Created by Efim Voinov on 08.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"
#import "Vector.h"
#import "GLDrawer.h"
#import "ImageMultiDrawer.h"

// particle system
//
// inherit from GLParticles if you want to use single-image particles, not larger than 64 pixels (GL_POINT restriction), this is faster.
// inherit from GLMultiParticles if you want to use multi-image particles and/or larger than 64 pixels

@class Particles;

// particle entity
typedef struct Particle
{
	Vector startPos;
	Vector pos;
	Vector dir;
	float radialAccel;
	float tangentialAccel;
	RGBAColor color;
	RGBAColor deltaColor;
	float size;
	float life;

	// used in multi-image particles
	float width;
	float height;
} Particle;

@protocol ParticleSystemDelegate
-(void)particlesFinished:(Particles*)p;
@end


// particle system base class
@interface Particles : BaseElement
{
@public
	// is the particle system active ?
	bool active;
	
	// duration in seconds of the system. -1 is infinity
	float duration;
	// time elapsed since the start of the system (in seconds)
	float elapsed;
	
	/// Gravity of the particles
	Vector gravity;
	
	// Position variance
	Vector posVar;
	
	// The angle (direction) of the particles measured in degrees
	float angle;
	// Angle variance measured in degrees;
	float angleVar;
	
	// The speed the particles will have.
	float speed;
	// The speed variance
	float speedVar;
	
	// Tangential acceleration
	float tangentialAccel;
	// Tangential acceleration variance
	float tangentialAccelVar;
	
	// Radial acceleration
	float radialAccel;
	// Radial acceleration variance
	float radialAccelVar;
	
	// Size of the particles
	float size;
	// Size variance
	float sizeVar;
	
	// How many seconds will the particle live
	float life;
	// Life variance
	float lifeVar;
	
	// Start color of the particles
	RGBAColor startColor;
	// Start color variance
	RGBAColor startColorVar;
	// End color of the particles
	RGBAColor endColor;
	// End color variance
	RGBAColor endColorVar;
	
	// Array of particles
	Particle *particles;
	// Maximum particles
	int totalParticles;
	// Count of active particles
	int particleCount;
	
	// additive color or blend
	bool blendAdditive;
	// color modulate
	bool colorModulate;
	
	// How many particles can be emitted per second
	float emissionRate;
	float emitCounter;
	
	// Texture of the particles
	Texture2D* texture;
	
	// Array of (x,y,size) 
	PointSprite* vertices;
	// Array of colors
	RGBAColor* colors;
	// vertices buffer id
	GLuint verticesID;
	// colors buffer id
	GLuint colorsID;

	//  particle idx
	int particleIdx;
	
	id<ParticleSystemDelegate> particlesDelegate;
}

@property (readonly) bool active;
@property (readonly) int totalParticles;
@property (readonly) int particleCount;
@property (assign) id<ParticleSystemDelegate> particlesDelegate;
@property (assign) Vector posVar;

// Initializes a system with a fixed number of particles
-(id) initWithTotalParticles:(int) numberOfParticles;
// Add a particle to the emitter
-(bool) addParticle;
// Update all particles
// Initializes a particle
-(void) initParticle: (Particle*) particle;
// start the running system with number of pre-created particles
-(void) startSystem:(int)initialParticles;
// stop the running system
-(void) stopSystem;
// reset the system
-(void) resetSystem;
// is the system full ?
-(bool) isFull;
-(void) setBlendAdditive:(bool)b;
@end

// particle system which allows multiple images for particles
@interface MultiParticles : Particles
{
	ImageMultiDrawer* drawer;
	Image* imageGrid;
}

-(id) initWithTotalParticles:(int) numberOfParticles andImageGrid:(Image*)image;

@end

// container which automatically deletes child particles when they are finished
@interface GLParticlesContainer : BaseElement
{
}

@end

