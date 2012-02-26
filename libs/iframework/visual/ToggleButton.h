//
//  GLToggleButton.h
//  template
//
//  Created by Mac on 04.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Button.h"

enum {TOGGLE_BUTTON_FACE1, TOGGLE_BUTTON_FACE2};

// actually two buttons whose enabled state is swapped on every button press
@interface ToggleButton : BaseElement<ButtonDelegate>
{	
	id <ButtonDelegate> delegate;
	int buttonID;
	Button* b1;
	Button* b2;
}

@property (assign) id<ButtonDelegate> delegate;

-(id)initWithUpElement1:(BaseElement*)u1 DownElement1:(BaseElement*)d1 UpElement2:(BaseElement*)u2 DownElement2:(BaseElement*)d2
		andID:(int)bid;

-(void)setTouchIncreaseLeft:(float)l Right:(float)r Top:(float)t Bottom:(float)b;
-(void)toggle;
-(bool)on;
@end
