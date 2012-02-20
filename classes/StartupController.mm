//
//  StartupController.m
//  blockit
//
//  Created by Efim Voinov on 18.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StartupController.h"
#import "ChampionsResourceMgr.h"
#import "StartupView.h"
#import "ChampionsRootController.h"
#import "ChampionsSoundMgr.h"
#import "AlternateImage.h"
#import "MenuController.h"
#import "ChampionsPreferences.h"
#import "NewsParser.h"
#import "FlurryAPI.h"

@implementation StartupController

-(NSString*)getNews
{
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"news"];
//	NSData* data = [NSData dataWithContentsOfFile:path];
	NSArray* newsArray = [NSArray arrayWithContentsOfFile:path];
	if(!newsArray)
		return NSLocalizedString(@"STR_NEWS_DEFAULT", @"[#043C87]Just like in Finger Physics: Finger Fun, your 5 star reviews ensure we provide constant updates and more levels to Finger Physics: Thumb Wars. Enjoy the battle!!!");
//	else
//		NewsParser* newsParser = [[[NewsParser alloc] initWithData:data] autorelease];
//	
//	XMLDocument* doc = [[[XMLDocument alloc] init] autorelease];
//	[doc parseData:data];
//	XMLNode* node = [doc->root findChildWithTagName:@"text" Recursively:TRUE];

//	NSDateFormatter* f = [[[NSDateFormatter alloc] init] autorelease];
//	[f setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
//
//	NSString* da = @"2010-03-25 11:00:38 GMT+03:00";
//	NSString* s = [f stringFromDate:[NSDate date]];
//	NSDate* d = [f dateFromString:da];
//	NSLog(@"\n%@\n%@", s, [d description]);
	
//	NSDate* da = [f dateFromString:@"2009-03-23 20:48:39 +0300"];
//	NSDate* db = [NSDate date];
//	NSComparisonResult res = [db compare:da];
	int rnd = arc4random() % [newsArray count];
	return [newsArray objectAtIndex:rnd];
}

- (id)initWithParent:(ViewController*)p
{	
	if (self = [super initWithParent:p]) 
	{			
		StartupView* startView = [[StartupView alloc] initFullscreen];

		Image* back = [Image create:[ChampionsResourceMgr getResource:IMG_DEFAULT]];
		[startView addChild:back];

		BaseElement* element = [ChampionsResourceMgr getResource:ELT_STARTUP];
		[element playTimeline:ELT_STARTUP_BASIC_TIMELINE];
		[element getCurrentTimeline].delegate = self;
		[startView addChild:element];
		
		BaseElement* titleNews = [MenuController createTitle:NSLocalizedString(@"STR_NEWS_TITLE", @"News") active:TRUE];		
		titleNews->anchor = titleNews->parentAnchor = TOP | HCENTER;
		titleNews->y = 150.0;
		[element addChild:titleNews];
		
		BaseElement* pinky = [ChampionsResourceMgr getResource:ELT_PINKY];
		[pinky playTimeline:ELT_PINKY_BASIC_TIMELINE];		
		[startView addChild:pinky];

		NSString* str = [self getNews];
//		CGSize size = CGSizeMake(210*1.25, 200);
//		Texture2D* t = [[[Texture2D alloc] initWithString:str dimensions:size alignment:UITextAlignmentLeft fontName:@"HelveticaNeue-Bold" fontSize:15] autorelease];
//		AlternateImage* text = (AlternateImage*)[AlternateImage create:t];
//		[text setMode:MODE_GL_SRC_ALPHA_GL_ONE_MINUS_SRC_ALPHA];
//		text->anchor = text->parentAnchor = TOP | LEFT;
//		text->color = blackRGBA;
//		text->x = 40;
//		text->y = 180;
//		text->rotationCenterX = -text->width/2;
//		text->scaleX = 0.75f;
		ColoredText* text = [[ColoredText allocAndAutorelease] initWithFont:[[Application sharedResourceMgr] getResource:FNT_FONTS_001_SMALL]];
		[text setString:str andWidth:200];
		text->x = 45;
		text->y = 180;
		text->anchor = text->parentAnchor = TOP | LEFT;
		[element addChild:text];
		
		[self addView:startView withID:0];
		[startView release];
		
		View* bannerView = [[View allocAndAutorelease] initFullscreen];
		BaseElement* bannerBack = [Image createWithResID:IMG_BANNER_FLIPSTONES];
		[bannerView addChild:bannerBack];
		
		Button* bshow = [[[Button alloc] initWithID:BUTTON_BANNER_SHOW] autorelease];
		bshow->y = 345;
		bshow->width = 300;
		bshow->height = 55;
		[bshow setDelegate:self];
		bshow->parentAnchor = bshow->anchor = TOP | HCENTER;
		[bannerBack addChild:bshow];
		
		Button* bskip = [[[Button alloc] initWithID:BUTTON_BANNER_SKIP] autorelease];
		bskip->y = 420;
		bskip->width = 300;
		bskip->height = 40;
		[bskip setDelegate:self];
		bskip->parentAnchor = bskip->anchor = TOP | HCENTER;
		[bannerBack addChild:bskip];
		[self addView:bannerView withID:1];
	}
	return self;
}

-(void)activate
{	
	[super activate];
	[self showView:0];		
}

+(BOOL)getBannerShowed
{
	return [[Application sharedPreferences] getBooleanForKey:@"bannerShowed"];
}

+(void)setBannerShowed:(BOOL)b
{
	[[Application sharedPreferences] setBoolean:b forKey:@"bannerShowed"];
}

-(void)timeline:(Timeline*)t reachedKeyFrame:(KeyFrame*)k withIndex:(int)i
{
}

-(void)timelineFinished:(Timeline*)t
{
	ChampionsResourceMgr* rm = (ChampionsResourceMgr*)[Application sharedResourceMgr];	
	rm.resourcesDelegate = (StartupController*)[root getChild:CHILD_START];
	[rm initLoading];
	[rm loadPack:(int*)PACK_COMMON];

	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	int tutorialLevel = rc.user.tutorialLevel;	
	if (tutorialLevel >= TUTORIAL_LEVELS_COUNT)
	{
		rc.user.tutorialLevel = UNDEFINED;	
		tutorialLevel = UNDEFINED;
	}
#ifndef MAP_PICKER	
	if (tutorialLevel != UNDEFINED)	
	{
		[rm loadPack:(int*)PACK_GAME];

		int mode = ([rc.selectedMap hasPrefix:@"1"] ? 1 : 2);		
		if (mode == 1)
		{
			[rm loadPack:(int*)PACK_LEVEL_TREE];			
		}
		else 
		{
			[rm loadPack:(int*)PACK_LEVEL_TOWN];
		}
	}
	else
#endif
	{
		[rm loadPack:(int*)PACK_MENU];
	}
#ifdef FREE
	[rm loadPack:(int*)PACK_FREE_VERSION];
#endif
	[rm startLoading];
}

// this method can be used to track loading progress (with getPercentLoaded method)
-(void)resourceLoaded:(int)resName
{
	if (resName == SND_INGAME_THEME1)
	{
		[ChampionsSoundMgr playMusic:SND_INGAME_THEME1];
//		[[Application sharedSoundMgr] setVolume:1 forChannel:0];
	}
}

-(void)allResourcesLoaded
{
#ifdef FREE		
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];	
	[rc showGSBanner];
#endif
	if([StartupController getBannerShowed])
		[self deactivate];
	else
		[self showView:1];
}

-(void)onButtonPressed:(int)n
{
#ifndef FREE
	NSURL* url = [NSURL URLWithString:@"http://prsok.com/FlipLoadScreen"];
#else
	NSURL* url = [NSURL URLWithString:@"http://prsok.com/FlipFreeLoadScreen"];
#endif
	switch (n) {
		case BUTTON_BANNER_SHOW:
			[FlurryAPI logEvent:@"BANNER_SHOW"];
			[StartupController setBannerShowed:TRUE];
			[[UIApplication sharedApplication] openURL:url];
			[self deactivate];
			break;
		case BUTTON_BANNER_SKIP:
			[FlurryAPI logEvent:@"BANNER_SKIP"];
			[StartupController setBannerShowed:TRUE];
			[self deactivate];
			break;
		default:
			break;
	}
	[[Application sharedPreferences] savePreferences];
}

@end
