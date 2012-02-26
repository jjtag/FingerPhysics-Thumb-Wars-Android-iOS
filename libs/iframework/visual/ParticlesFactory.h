//
//  GLParticleFactory.h
//  frameworkTest
//
//  Created by Efim Voinov on 13.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Particles.h"

// sun particle system
@interface GLSun : Particles
{
}
@end

@interface GLFireworks : MultiParticles
{
}
@end

@interface GLTest : MultiParticles
{
}
@end

@interface GLVulcanoParticles : MultiParticles
{
}
@end

@interface GLBubbleParticles : MultiParticles
{
}
@end

@interface GLSmokeParticles : Particles
{
}
@end

// glass particle system
@interface GLGlassBreak : MultiParticles
{
}
-(id)initWithImageGrid:(Image*)image;
@end
