
#import <OpenGLES/ES1/gl.h>
#import "Particles.h"
#import "MathHelper.h"
#import "FrameworkTypes.h"
#import "Debug.h"

@implementation Particles

@synthesize active;
@synthesize totalParticles;
@synthesize particleCount;

@synthesize particlesDelegate;
@synthesize posVar;

-(id) initWithTotalParticles:(int) numberOfParticles
{
	if( !(self = [super init]) )
	{		
		return nil;
	}
	
	width = SCREEN_WIDTH;
	height = SCREEN_HEIGHT;
	
	totalParticles = numberOfParticles;
	
	particles = malloc(sizeof(Particle) * totalParticles);
	vertices = malloc(sizeof(PointSprite) * totalParticles);
	colors = malloc (sizeof(RGBAColor) * totalParticles);
	
	if(!(particles && vertices && colors))
	{
		LOG(@"Particle system: not enough memory");
		if(particles)
		{
			free(particles);
		}
		if(vertices)
		{
			free(vertices);
		}
		if(colors)
		{
			free(colors);
		}
		return nil;
	}
	
	bzero(particles, sizeof(Particle) * totalParticles);
	
	// default, not active
	active = FALSE;
	
	// default: additive
	blendAdditive = FALSE;
	
	// default: modulate
	// XXX: not used
	//	colorModulate = TRUE;

	glGenBuffers(1, &verticesID);
	glGenBuffers(1, &colorsID);	
	
	return self;
}

-(void)dealloc
{
	free(particles);
	free(vertices);
	free(colors);
	glDeleteBuffers(1, &verticesID);
	glDeleteBuffers(1, &colorsID);
	
	[texture release];
	
	[super dealloc];
}

-(bool)addParticle
{
	if([self isFull])
	{
		return FALSE;
	}
	
	Particle * particle = &particles[particleCount];
	
	[self initParticle: particle];		
	particleCount++;
	
	return TRUE;
}

-(void)initParticle: (Particle*) particle
{
	Vector v;
	
	// position
	particle->pos.x = x + posVar.x * RND_MINUS1_1;
	particle->pos.y = y + posVar.y * RND_MINUS1_1;
	
	particle->startPos = particle->pos;
	
	// direction
	float a = (float)DEGREES_TO_RADIANS(angle + (angleVar * RND_MINUS1_1));
	v.y = sinf(a);
	v.x = cosf(a);
	float s = speed + speedVar * RND_MINUS1_1;
	particle->dir = vectMult(v, s);
	
	// radial accel
	particle->radialAccel = radialAccel + radialAccelVar * RND_MINUS1_1;
	
	// tangential accel
	particle->tangentialAccel = tangentialAccel + tangentialAccelVar * RND_MINUS1_1;
	
	// life
	particle->life = life + lifeVar * RND_MINUS1_1;
	
	// Color
	RGBAColor start;
	start.r = startColor.r + startColorVar.r * RND_MINUS1_1;
	start.g = startColor.g + startColorVar.g * RND_MINUS1_1;
	start.b = startColor.b + startColorVar.b * RND_MINUS1_1;
	start.a = startColor.a + startColorVar.a * RND_MINUS1_1;
	
	RGBAColor end;
	end.r = endColor.r + endColorVar.r * RND_MINUS1_1;
	end.g = endColor.g + endColorVar.g * RND_MINUS1_1;
	end.b = endColor.b + endColorVar.b * RND_MINUS1_1;
	end.a = endColor.a + endColorVar.a * RND_MINUS1_1;
	
	particle->color = start;
	particle->deltaColor.r = (end.r - start.r) / particle->life;
	particle->deltaColor.g = (end.g - start.g) / particle->life;
	particle->deltaColor.b = (end.b - start.b) / particle->life;
	particle->deltaColor.a = (end.a - start.a) / particle->life;
	
	// size
	particle->size = size + sizeVar * RND_MINUS1_1;	
}

-(void)update:(TimeType)delta
{
	[super update:delta];

	if (particlesDelegate)
	{
		if (particleCount == 0 && !active)
		{
			[particlesDelegate particlesFinished:self];
			return;
		}
	}
	
	if (!vertices) 
	{
		return;
	}
	
	if (active && emissionRate) 
	{
		float rate = 1.0f / emissionRate;
		emitCounter += delta;
		while (particleCount < totalParticles && emitCounter > rate) 
		{
			[self addParticle];
			emitCounter -= rate;
		}
		
		elapsed += delta;
		if(duration != -1 && duration < elapsed)
		{
			[self stopSystem];
		}
	}
	
	particleIdx = 0;
	
	while( particleIdx < particleCount )
	{
		Particle* p = &particles[particleIdx];
		
		if( p->life > 0 ) 
		{			
			Vector tmp, radial, tangential;
			
			radial = vectZero;
			// radial acceleration
			if(p->pos.x || p->pos.y)
			{
				radial = vectNormalize(p->pos);
			}
			
			tangential = radial;
			radial = vectMult(radial, p->radialAccel);
			
			// tangential acceleration
			float newy = tangential.x;
			tangential.x = -tangential.y;
			tangential.y = newy;
			tangential = vectMult(tangential, p->tangentialAccel);
			
			// (gravity + radial + tangential) * delta
			tmp = vectAdd(vectAdd( radial, tangential), gravity);
			tmp = vectMult(tmp, delta);
			p->dir = vectAdd(p->dir, tmp);
			tmp = vectMult(p->dir, delta);
			p->pos = vectAdd(p->pos, tmp );
			
			p->color.r += (p->deltaColor.r * delta);
			p->color.g += (p->deltaColor.g * delta);
			p->color.b += (p->deltaColor.b * delta);
			p->color.a += (p->deltaColor.a * delta);
			
			p->life -= delta;
			
			// place vertices and colos in array
			vertices[particleIdx].x = p->pos.x;
			vertices[particleIdx].y = p->pos.y;
			vertices[particleIdx].size = p->size;
			
			// colors
			colors[particleIdx] = p->color;
			
			// update particle counter
			particleIdx++;
			
		} 
		else 
		{
			// life < 0
			if( particleIdx != particleCount-1 )
			{
				particles[particleIdx] = particles[particleCount-1];
			}
			particleCount--;
		}
	}	
	
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(PointSprite) * totalParticles, vertices, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, colorsID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(RGBAColor) * totalParticles, colors, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)startSystem:(int)initialParticles
{
	ASSERT(initialParticles <= totalParticles);
	particleCount = 0;
	while (particleCount < initialParticles) 
	{
		[self addParticle];
	}	
	active = TRUE;	
}

-(void)stopSystem
{
	active = FALSE;
	elapsed = duration;
	emitCounter = 0;
}

-(void)resetSystem
{
	elapsed = duration;
	emitCounter = 0;
}

-(void)draw
{
	[self preDraw];
	//	int blendSrc, blendDst;
	//	int colorMode;	
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);	
	//glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, [texture name]);
	
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );
	
	//glEnableClientState(GL_VERTEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);
	glVertexPointer(2, GL_FLOAT, sizeof(PointSprite), 0);
	
	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	glPointSizePointerOES(GL_FLOAT, sizeof(PointSprite), (GLvoid*) (sizeof(GL_FLOAT) * 2));
	
	glEnableClientState(GL_COLOR_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, colorsID);
	glColorPointer(4, GL_FLOAT, 0, 0);
	
	// save blend state
	//	glGetIntegerv(GL_BLEND_DST, &blendDst);
	//	glGetIntegerv(GL_BLEND_SRC, &blendSrc);
	if(blendAdditive)
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	}
	else
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	// save color mode
#if 0
	glGetTexEnviv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, &colorMode);
	if(colorModulate)
	{
		glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	}
	else
	{
		glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
	}
#endif

	glDrawArrays(GL_POINTS, 0, particleIdx);		

	// restore blend state
	//	glBlendFunc( blendSrc, blendDst );
	// XXX: restoring the default blend function
	// XXX: this should be in sync with Director setAlphaBlending
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
#if 0
	// restore color mode
	glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, colorMode);
#endif
	
	// unbind VBO buffer
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	//glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	glDisableClientState(GL_COLOR_ARRAY);
	//glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SPRITE_OES);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	[self postDraw];	
}

-(bool) isFull
{
	return (particleCount == totalParticles);
}

-(void) setBlendAdditive:(bool)b
{
	blendAdditive = b;
}
@end

@implementation MultiParticles

-(id) initWithTotalParticles:(int) numberOfParticles andImageGrid:(Image*)image
{
	if(!(self = [super init]))
	{		
		return nil;
	}

	imageGrid = [image retain];
	
	drawer = [[ImageMultiDrawer alloc] initWithImage:imageGrid andCapacity:numberOfParticles];
	
	width = SCREEN_WIDTH;
	height = SCREEN_HEIGHT;
	
	totalParticles = numberOfParticles;
	
	particles = malloc(sizeof(Particle) * totalParticles);
	colors = malloc(sizeof(RGBAColor) * 4 * totalParticles);
	
	if(!(particles && colors))
	{
		LOG(@"Particle system: not enough memory");
		if(particles)
		{
			free(particles);
		}
		if(colors)
		{
			free(colors);
		}
		ASSERT(FALSE);
		return nil;
	}
	
	bzero(particles, sizeof(Particle) * totalParticles);
	
	// default, not active
	active = FALSE;
	
	// default: additive
	blendAdditive = FALSE;
	
	// default: modulate
	// XXX: not used
	//	colorModulate = TRUE;
	
	//glGenBuffers(1, &verticesID);
	glGenBuffers(1, &colorsID);	
	
	return self;
}

-(void)initParticle:(Particle*)particle
{
	Image* image = imageGrid;	
	
	int n = RND(image->texture->quadsCount - 1);
	Quad2D* tquad =	&(image->texture->quads[n]);
	Quad3D vquad = MakeQuad3D(0, 0, 0, 0, 0);
	
	[drawer setTextureQuad:tquad atVertexQuad:&vquad atIndex:particleCount];	
	
	[super initParticle:particle];	
	
	particle->width = image->width * particle->size;		
	particle->height = image->height * particle->size;		
}

-(void)update:(TimeType)delta
{
	[super update:delta];
	
	if (active && emissionRate) 
	{
		float rate = 1.0f / emissionRate;
		emitCounter += delta;
		while (particleCount < totalParticles && emitCounter > rate) 
		{
			[self addParticle];
			emitCounter -= rate;
		}
		
		elapsed += delta;
		if(duration != -1 && duration < elapsed)
		{
			[self stopSystem];
		}
	}
	
	particleIdx = 0;
	
	while( particleIdx < particleCount )
	{
		Particle* p = &particles[particleIdx];
		
		if( p->life > 0 ) 
		{			
			Vector tmp, radial, tangential;
			
			radial = vectZero;
			// radial acceleration
			if(p->pos.x || p->pos.y)
			{
				radial = vectNormalize(p->pos);
			}
			tangential = radial;
			radial = vectMult(radial, p->radialAccel);
			
			// tangential acceleration
			float newy = tangential.x;
			tangential.x = -tangential.y;
			tangential.y = newy;
			tangential = vectMult(tangential, p->tangentialAccel);
			
			// (gravity + radial + tangential) * delta
			tmp = vectAdd(vectAdd(radial, tangential), gravity);
			tmp = vectMult(tmp, delta);
			p->dir = vectAdd(p->dir, tmp);
			tmp = vectMult(p->dir, delta);
			p->pos = vectAdd(p->pos, tmp);
			
			p->color.r += (p->deltaColor.r * delta);
			p->color.g += (p->deltaColor.g * delta);
			p->color.b += (p->deltaColor.b * delta);
			p->color.a += (p->deltaColor.a * delta);
			
			p->life -= delta;
			
			// place vertices and colos in array			
			drawer->vertices[particleIdx] = MakeQuad3D(p->pos.x - p->width / 2, p->pos.y - p->height / 2, 0.0, p->width, p->height);
			
			// colors
			for (int i = 0; i < 4; i++)
			{
				colors[particleIdx * 4 + i] = p->color;
			}
			
			// update particle counter
			particleIdx++;
			
		} 
		else 
		{
			// life < 0
			if( particleIdx != particleCount - 1 )
			{
				particles[particleIdx] = particles[particleCount - 1];
				drawer->vertices[particleIdx] = drawer->vertices[particleCount - 1];
				drawer->texCoordinates[particleIdx] = drawer->texCoordinates[particleCount - 1];							
			}
			particleCount--;
		}
	}	
	
	//glBindBuffer(GL_ARRAY_BUFFER, verticesID);
	//glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 4 * totalParticles, vertices, GL_DYNAMIC_DRAW);	
	glBindBuffer(GL_ARRAY_BUFFER, colorsID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(RGBAColor) * 4 * totalParticles, colors, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)draw
{
	[self preDraw];
	
	if(blendAdditive)
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	}
	else
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	glBindTexture(GL_TEXTURE_2D, [drawer->image->texture name]);
	glVertexPointer(3, GL_FLOAT, 0, drawer->vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, drawer->texCoordinates);
	glEnableClientState(GL_COLOR_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, colorsID);
	glColorPointer(4, GL_FLOAT, 0, 0);
	glDrawElements(GL_TRIANGLES, particleIdx * 6, GL_UNSIGNED_SHORT, drawer->indices);	
	
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
		
	// unbind VBO buffer
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glDisableClientState(GL_COLOR_ARRAY);
	
	[self postDraw];	
}

-(void)dealloc
{
	[drawer release];
	[imageGrid release];
	
	[super dealloc];
}

@end

@implementation GLParticlesContainer

-(void)update:(TimeType)delta
{
	[super update:delta];
	
	// remove finished particles
	for (int i = 0; i < [self childsCount]; i++)
	{
		Particles* p = (Particles*)[self getChild:i];
		if (p && p.particleCount == 0 && !p.active)
		{
			[self removeChildWithID:i];
		}
	}	
}

@end
