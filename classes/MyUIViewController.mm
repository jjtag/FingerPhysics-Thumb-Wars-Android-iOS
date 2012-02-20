//
//  MyUIViewController.m
//  blockit
//
//  Created by ikoryakin on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Framework.h"
#import "ChampionsRootController.h"
#import "MyUIViewController.h"
#import "AdWhirlView.h"

@implementation MyUIViewController

@synthesize adView;

-(id) init
{
	if(self = [super init])
	{
		self.view = [Application sharedCanvas];		
		currLayoutOrientation = UIInterfaceOrientationPortrait;
		alreadyShowingBanner = FALSE;
	}
	return self;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//	[((BlockitRootController*)[Application sharedRootController]) resume];
//	[super viewWillAppear:animated];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[((BlockitRootController*)[Application sharedRootController]) suspend];
//	[super viewWillDisappear:animated];
//}

//- (void)viewDidAppear:(BOOL)animated
//// Called when the view has been fully transitioned onto the screen. Default does nothing
//{
//	BlockitRootController* rc = (BlockitRootController*)[Application sharedRootController];
//	if([rc isSuspended])
//	{
//		[rc resume];
//	}
//	
//	[super viewDidAppear:animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
//{
//	BlockitRootController* rc = (BlockitRootController*)[Application sharedRootController];
//	if(![rc isSuspended])
//	{
//		[rc suspend];
//	}
//	[super viewDidDisappear:animated];
//}

-(void)dealloc
{
	self.view = nil;
	[super dealloc];
}

-(void)showBanner
{
	if (alreadyShowingBanner)return;
	alreadyShowingBanner = TRUE;
	if(adView)
	{
		[self.view addSubview:self.adView];
	}
}

-(void)setBanner
{
	self.view = [Application sharedCanvas];
	self.adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
}

-(void)hideBanner
{
	if (!alreadyShowingBanner) return;
	[self.adView removeFromSuperview];
	alreadyShowingBanner = FALSE;
}

- (NSString *)adWhirlApplicationKey 
{
	return kAdWhirlAppKey;
}

- (UIViewController *)viewControllerForPresentingModalView 
{
	return self;
}


- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView
{
	[self adjustAdSize];
}

- (void)adWhirlDidFailToReceiveAd:(AdWhirlView *)adWhirlView usingBackup:(BOOL)yesOrNo
{
}

- (void)adjustAdSize
{

	CGSize adSize = [adView actualAdSize];
	CGRect newFrame = adView.frame;
	newFrame.size.height = adSize.height;
	newFrame.size.width = adSize.width;
	//newFrame.origin.x = (self.view.bounds.size.width - adSize.width)/2;
	newFrame.origin.y = SCREEN_HEIGHT-adSize.height;
	adView.frame = newFrame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io {
	return NO;
}
@end

