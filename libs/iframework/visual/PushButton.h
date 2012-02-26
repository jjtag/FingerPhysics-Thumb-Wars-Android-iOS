//
//  PushButton.h
//  barbie
//
//  Created by Mac on 18.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Button.h"

// Group of pushbuttons
@interface PushButtonGroup : BaseElement
{
}
-(void)pushButton:(int)n;
-(void)notifyPressed:(int)n;
@end


enum { BUTTON_PUSHED = 2 };

@protocol PushButtonDelegate
-(void)onButtonPressed:(int)n;
-(void)onButtonUnpushed:(int)n;
@end


// Button which stays in pressed state when pressed and released.
@interface PushButton : Button
{
@public
	PushButtonGroup* group;
	bool pushOnRelease; // button will be pushed when user releases the finger (like normal button)
	bool canBeUnpushed; // button will be unpushed when pressed in pushed state
}

-(void)setState:(int)s;

@end
