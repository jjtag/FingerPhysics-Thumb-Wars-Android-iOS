//
//  Joystick.h
//  champions
//
//  Created by ikoryakin on 3/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Framework.h>

@protocol JoystickProtocol
-(void)onJoyOffsetX:(float)ox OffsetY:(float)oy;
@end


@interface Joystick : Image {
	float maxOffsetX;
	float maxOffsetY;
	float startX;
	float startY;

@public
	float offsetX;
	float offsetY;
	BOOL active;

@protected
	id <JoystickProtocol> delegate;
	float touchLeftInc;
	float touchRightInc;
	float touchTopInc;
	float touchBottomInc;
	
}

+(Joystick*)create:(Texture2D*)t maxOffsetX:(float)maxX maxOffsetY:(float)maxY;
-(id)initWithMaxOffsetX:(float)maxX maxOffsetY:(float)maxY andTexture:(Texture2D*)t;

@property (assign) id <JoystickProtocol> delegate;

@end
