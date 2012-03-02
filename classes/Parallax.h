//
//  Parallax.h
//  frameworkTest
//
//  Created by reaxion on 20.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCanvas.h"
#import "GLDrawer.h"

@interface Parallax : NSObject
{
	float x, y, parallaxRatioX, parallaxRatioY;
	Texture2D* img;
	bool vertAliasing, reverseDirect;
}
-(id) initWithXPos:(float) xpos YPos:(float) ypos parallaxRatioX:(float) prX parallaxRatioY:(float) prY image:(Texture2D*) image vertAliasing:(bool) vA reverseDirection:(bool) rD;
-(void)drawWithOffsetX:(float) offsetX offsetY: (float) offsetY;
-(void)setXPos:(float) xpos YPos:(float) ypos;

@property (assign) float offX, offY, parallaxRatioX, parallaxRatioY;
@end
