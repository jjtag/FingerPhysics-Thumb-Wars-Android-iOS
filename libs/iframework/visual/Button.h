//
//  GLButton.h
//  blockit
//
//  Created by Efim Voinov on 27.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"
#import "../support/Texture2D.h"

@protocol ButtonDelegate
@optional
-(void)onButtonPressed:(int)n;
@end

enum {BUTTON_UP = 0, BUTTON_DOWN = 1};

// simple button which can use two elements for presenting UP and DONW states
@interface Button : BaseElement
{
@public
	int buttonID;

@protected
	int state;
	id delegate;

	float touchLeftInc;
	float touchRightInc;
	float touchTopInc;
	float touchBottomInc;
	
	Rectangle forcedTouchZone;
}

@property (assign) id delegate;

// helper for quick creation of button with 2 images for states
+(Button*)createWithTextureUp:(Texture2D*)up Down:(Texture2D*)down ID:(int)bID;

-(id)initWithID:(int)n;
-(id)initWithUpElement:(BaseElement*)up DownElement:(BaseElement*)down andID:(int)n;
-(void)setTouchIncreaseLeft:(float)l Right:(float)r Top:(float)t Bottom:(float)b;
// set implicit touch zone for the button
-(void)forceTouchRect:(Rectangle)r;

-(void)setState:(int)s;
-(bool)isInTouchZoneX:(float)tx Y:(float)ty;

@end
