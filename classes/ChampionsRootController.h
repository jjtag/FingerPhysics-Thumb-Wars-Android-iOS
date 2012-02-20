//
//  RootController.h
//  ;
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//#define MAP_PICKER

#import "RootController.h"
#import "FPUser.h"
#import <MessageUI/MessageUI.h>

#ifdef OPENFEINT
	#import "OpenFeint.h"
	#import "OFCloudStorageService.h" 
	#import "OFUser.h"
	#import "OFUserService.h"
	#import "OpenFeint+UserOptions.h"
#endif

#define FPC_FULL_LINK @"http://itunes.apple.com/us/app/finger-physics-thumb-wars/id380480463?mt=8"

#ifdef FREE
#import "MyUIViewController.h"

#import "GreystripeDelegate.h"
#import "GSAdView.h"
#import "GSAdEngine.h"

#endif

// controller childs list
enum 
{
	CHILD_START, 
	CHILD_MENU,
	CHILD_LOADING,
	CHILD_GAME,
	CHILD_MAPPICKER,
};

// the highest level controller, which doesn't display anything
@interface ChampionsRootController : RootController
< MFMailComposeViewControllerDelegate
#ifdef FREE
	, GreystripeDelegate
#endif
#ifdef OPENFEINT
	, OpenFeintDelegate
#endif
>

{
	NSString* selectedMap;
	FPUser* user;
	DynamicArray* mapsList;
	UIView* loadingView;
	UIActivityIndicatorView* spinner;
	int loadingRetainCount;
	
	Vector lastMode1Scroll;
	Vector lastMode2Scroll;	
	
#ifdef FREE
	UIView* banner;
	MyUIViewController* viewController;
	int bannerShowAttempts;
#endif
	NSDate* bannerDate;
}
+(void)loadNews;
-(void)loadNewsInBackground;
+(void)loadBanners;
-(void)loadBannersInBackground;
-(void)initializeOpenfeint;
-(void)saveGameProgress;
-(void)downloadUserPicture;

#ifdef OPENFEINT
-(void)uploadGameProgress;
-(void)downloadGameProgress;
#endif

#pragma mark Email code
+(MFMailComposeViewController*)mailWithSubject:(NSString*)subject body:(NSString*)emailBody to:(NSString*)to isHTML:(BOOL)isHtml delegate:(id)delegate;
+(void)sendEmailTo:(NSString*)to withSubject:(NSString*)subject withBody:(NSString*)body;
#pragma mark -
-(void)startLoadingAnimation;
-(void)stopLoadingAnimation;
-(void)resetProgress;
-(NSString*)nextLevel:(NSString*)currentLevel;
-(BOOL)allLevelsCompleted;

-(BOOL)shouldShowBanner;
-(void)saveBannerDate;
-(NSTimeInterval)diffFromPreviousBannerDate;
-(void)showGSBanner;
-(void)setAdWhirlBanner;
-(void)showAdWhirlBanner;
-(void)hideAdWhirlBanner;

@property (retain) NSDate* bannerDate;
@property (retain) NSString* selectedMap;
@property (assign) FPUser* user;
@end
