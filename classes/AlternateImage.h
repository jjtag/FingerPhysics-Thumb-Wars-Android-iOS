//
//  AlternateImage.h
//  champions
//
//  Created by ikoryakin on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Framework.h"

enum BLENDING_MODES
{
	MODE_GL_ONE_GL_ONE_MINUS_SRC_ALPHA = 0,
	MODE_GL_SRC_ALPHA_GL_ONE_MINUS_SRC_ALPHA,
};

@interface AlternateImage : Image
{
	int mode;
}

@property (assign) int mode;

-(void)draw;

@end
