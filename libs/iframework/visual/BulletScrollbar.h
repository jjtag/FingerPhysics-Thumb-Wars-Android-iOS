//
//  GLBulletScrollbar.h
//  template
//
//  Created by Efim Voinov on 06.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Scrollbar.h"

@class Texture2D;

// horizontal "bullet" scrollbar
@interface BulletScrollbar : Scrollbar
{
	Texture2D* bullet;
}
// should be texture with 2 frames for unselected and selected state
-(id)initWithBulletTexture:(Texture2D*)t andTotalBullets:(int)tb;
@end
