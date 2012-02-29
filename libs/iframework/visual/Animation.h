//
//  AnimationStrip.h
//  blockit
//
//  Created by Efim Voinov on 24.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Image.h"
#import "DynamicArray.h"
#import "FrameworkTypes.h"

@class Animation;

// animation element based on timelines
@interface Animation : Image 
{		
}

-(int)addAnimationDelay:(float)d Loop:(int)l First:(int)s Last:(int)e;
-(void)addAnimationWithID:(int)aid Delay:(float)d Loop:(int)l First:(int)s Last:(int)l;
-(int)addAnimationWithDelay:(float)d Looped:(bool)l Count:(int)c Sequence:(int)s,...;
-(void)addAnimationWithID:(int)aid Delay:(float)d Loop:(int)l Count:(int)c Sequence:(int)s,...;

-(void)setAction:(NSString*)action Target:(BaseElement*)t Param:(int)p SubParam:(int)sp AtIndex:(int)i forAnimation:(int)a;
-(void)setPauseAtIndex:(int)i forAnimation:(int)a;
-(void)setDelay:(TimeType)d atIndex:(int)i forAnimation:(int)a;
-(void)switchToAnimation:(int)a2 atEndOfAnimation:(int)a1 Delay:(TimeType)d;

// go to the specified sequence frame of the current animation
-(void)jumpTo:(int)i;

-(void)addAnimationWithID:(int)aid Delay:(float)d Loop:(int)l Count:(int)c First:(int)s Last:(int)e ArgumentList:(va_list)al;

@end
