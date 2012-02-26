//
//  GLAnimationsPool.h
//  rogatka
//
//  Created by Efim Voinov on 06.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"
#import "Animation.h"
#import "Particles.h"

// Animatable objects container which automatically deletes them when they are finished
@interface AnimationsPool : BaseElement <TimelineDelegate, ParticleSystemDelegate>
{
	DynamicArray* removeList;
}

@end
