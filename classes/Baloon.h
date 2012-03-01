//
//  Baloon.h
//  champions
//
//  Created by Mac on 21.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Button.h"
#import "Image.h"
#import "View.h"

@class Baloon;

@protocol BaloonDelegate
-(void)baloonClosed:(Baloon*)baloon;
@end

enum {BALOON_STATIC, BALOON_SINGLE, BALOON_MULTIPLE_FIRST, BALOON_MULTIPLE_NEXT, BALOON_MULTIPLE_LAST};
enum {BUTTON_CLOSE};

// Singleton baloon with text and image
@interface Baloon : BaseElement <ButtonDelegate, TimelineDelegate>
{
@public
	int baloonID;
@protected
	Image* charImage;
	Image* baloonBack;	
	id <BaloonDelegate> delegate;
	bool blocking;
	int type;
}

+(void)showBaloonWithID:(int)bID Text:(NSString*)text Image:(Image*)im Blocking:(bool)bl Type:(int)tp inView:(BaseElement*)v Delegate:(id<BaloonDelegate>)dl;
+(void)hideBaloonInView:(BaseElement*)v;
+(bool)hasBaloonInView:(BaseElement*)v;

+(void)setBaloonAnimations:(Baloon*)activeBaloon;

@end

enum {BUTTON_BANNER = 1};

// baloon with image banner
@interface BannerBaloon : Baloon
{
@public
	NSString* url;
}

+(void)showBaloonWithID:(int)bID Banner:(Texture2D*)banner URL:(NSString*)u Image:(Image*)im Blocking:(bool)bl Type:(int)tp inView:(BaseElement*)v Delegate:(id<BaloonDelegate>)dl;
@end

