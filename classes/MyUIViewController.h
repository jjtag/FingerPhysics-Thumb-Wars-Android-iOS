//
//  MyUIViewController.h
//  blockit
//
//  Created by ikoryakin on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdWhirlDelegateProtocol.h"

@class AdWhirlView;
#define kAdWhirlAppKey @"430d5ce756d545f5b0e4e5ee102161fe"

@interface MyUIViewController : UIViewController <AdWhirlDelegate>
{
	AdWhirlView *adView;
	UIInterfaceOrientation currLayoutOrientation;
	BOOL alreadyShowingBanner;
}

-(void)setBanner;
-(void)showBanner;
-(void)hideBanner;
-(void)adjustAdSize;

@property (nonatomic,retain) AdWhirlView *adView;
@end
