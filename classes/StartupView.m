//
//  StartupView.m
//  blockit
//
//  Created by Mac on 02.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StartupView.h"
#import "Debug.h"

@implementation StartupView

-(void)draw
{	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	[self preDraw];
	[self postDraw];
	
	float fillPercent = (float)[[Application sharedResourceMgr] getPercentLoaded];
	if(fillPercent < 100 || [[Application sharedResourceMgr] hasResource:PACK_COMMON[1]])
	{
		Texture2D* loaderBar = [ChampionsResourceMgr getResource:IMG_LOADERBAR_FULL];
		Rectangle r = MakeRectangle(0, 0, (276.0 * fillPercent) / 100.0, 10);
		drawImagePart(loaderBar, r, 22, 426);		
	}
	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);	
}
@end
