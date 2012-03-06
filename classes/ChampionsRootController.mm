//
//  RootController.m
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChampionsRootController.h"
#import "GameController.h"
#import "StartupController.h"
#import "MenuController.h"
#import "LoadingController.h"
#import "ChampionsResourceMgr.h"
#import "Texture2D.h"
#import "MapPickerController.h"
#import "MapsListParser.h"
#import "ChampionsPreferences.h"
// #import "OFImageCache.h"
#import "NewsParser.h"
#import "BannerParser.h"
#import "ChampionsSoundMgr.h"

@implementation ChampionsRootController

@synthesize bannerDate;
@synthesize selectedMap;
@synthesize user;

- (id)initWithParent:(ViewController*)p
{	
	if (self = [super initWithParent:p]) 
	{		
		self.bannerDate = [NSDate date];		
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
#ifdef FREE
		NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"settings_free.blob"];
#else
		NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"settings.blob"];
#endif
		NSData* data = [NSData dataWithContentsOfFile:path];
		selectedMap = nil;
		if(data)
			user = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
		
		if (user)
		{
//			NSLog(@"user registered? %i", (int)user.registered);
		}
		else
		{
			user = [[FPUser alloc] init];
			[user setDefaults];
//			NSLog(@"new user");
			[self saveGameProgress];
		}

		ChampionsResourceMgr* rm = (ChampionsResourceMgr*)[Application sharedResourceMgr];
		[rm initLoading];
		[rm loadPack:(int*)PACK_IMMEDIATE_COMMON];
		[rm loadPack:(int*)PACK_STARTUP];
		[rm loadImmediately];
		
		[ChampionsRootController loadNews];
//		[self loadBanners];
		[self performSelectorInBackground:@selector(loadBannersInBackground) withObject:nil];
//		[self performSelectorInBackground:@selector(loadNewsInBackground) withObject:nil];
		
		StartupController* startupController = [[StartupController alloc] initWithParent:self];
		[self addChild:startupController withID:CHILD_START]; 	
		[startupController release];		
				
		viewTransition = UNDEFINED;
		mapsList = [[MapsListParser create] retain];
		loadingRetainCount = 0;
		self.selectedMap = user.lastPlayedMap;
	}
	return self;
}

-(void)dealloc
{
	[mapsList release];
	[user release];
	[super dealloc];
}

-(void)activate
{
	[super activate];
	[self activateChild:CHILD_START];
	
//	[self performSelectorInBackground:@selector(loadNewsInBackground) withObject:nil];
//	[self performSelectorInBackground:@selector(loadMapListInBackground) withObject:nil];
}

-(void)destroyMenu
{
	ChampionsResourceMgr* rm = (ChampionsResourceMgr*)[Application sharedResourceMgr];
	[self deleteChild:CHILD_MENU];	
	[rm freePack:(int*)PACK_MENU];		
}

-(void)restartGame
{
	[self deleteChild:CHILD_GAME];
	LoadingController* loadingController = (LoadingController*)[self getChild:CHILD_LOADING];
	loadingController->nextController = CHILD_GAME;
	loadingController->nextView = 0;
	[self activateChild:CHILD_LOADING];

	ChampionsResourceMgr* rm = (ChampionsResourceMgr*)[Application sharedResourceMgr];	
	int mode = ([selectedMap hasPrefix:@"1"] ? 1 : 2);		
	
	if (mode == 1 && ![rm hasResource:IMG_BIRD])
	{
		[rm freePack:(int*)PACK_LEVEL_TOWN];
		rm.resourcesDelegate = loadingController;
		[rm initLoading];
		[rm loadPack:(int*)PACK_LEVEL_TREE];			
		[rm startLoading];
	}
	else if (mode == 2 && ![rm hasResource:IMG_AIRSHIP])
	{
		[rm freePack:(int*)PACK_LEVEL_TREE];
		rm.resourcesDelegate = loadingController;
		[rm initLoading];
		[rm loadPack:(int*)PACK_LEVEL_TOWN];
		[rm startLoading];
	}		
	else 
	{
		[loadingController deactivate];		
	}
}

-(void)restartPicker
{
	[self deleteChild:CHILD_GAME];	
	LoadingController* loadingController = (LoadingController*)[self getChild:CHILD_LOADING];
	loadingController->nextController = CHILD_MAPPICKER;
	loadingController->nextView = 0;					
	[self activateChild:CHILD_LOADING];
	ChampionsResourceMgr* rm = (ChampionsResourceMgr*)[Application sharedResourceMgr];
	rm.resourcesDelegate = loadingController;
	[rm initLoading];
	[rm loadPack:(int*)PACK_MAPPICKER];
	[rm freePack:(int*)PACK_GAME];
	[rm freePack:(int*)PACK_LEVEL_TOWN];
	[rm freePack:(int*)PACK_LEVEL_TREE];
	
	[rm startLoading];
}

-(NSString*)nextLevel:(NSString*)currentLevel
{
	ASSERT(mapsList);
	int index = UNDEFINED;
	int type = UNDEFINED;
	NSString* candidateMap = nil;
	for(LevelSet* set in mapsList)
	{
		if(index != UNDEFINED && !candidateMap)
		{
			candidateMap = [set->list objectAtIndex:0];
		}
		
		for (NSString* levelName in set->list)
		{
			if([levelName isEqualToString:currentLevel])
			{
				index = [set->list getObjectIndex:levelName];
				if(index+1 < [set->list count])
				{
					candidateMap = [set->list objectAtIndex:index+1];
//					FPScores* scores = [user.levelsProgress objectForKey:candidateMap];					
				}
				else
				{
					if([mapsList getObjectIndex:set] == [mapsList count]-1)
					{
						LevelSet* firstSet = [mapsList objectAtIndex:0];
						candidateMap = [firstSet->list objectAtIndex:0];
					}
				}
				break;
			}
		}
	}
//	NSLog(@"next map is %@", candidateMap);
	return candidateMap;
}	

-(void)onChildDeactivated:(int)n
{
	[super onChildDeactivated:n];

	ChampionsResourceMgr* rm = (ChampionsResourceMgr*)[Application sharedResourceMgr];
	
	switch (n) 
	{
		case CHILD_START:
		{	
			LoadingController* loadingController = [[LoadingController allocAndAutorelease] initWithParent:self];
			[self addChild:loadingController withID:CHILD_LOADING];
			
			[canvas initFPSMeterWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL]];

			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			int tutorialLevel = rc.user.tutorialLevel;

			[self deleteChild:CHILD_START];
			[rm freePack:(int*)PACK_STARTUP];						

#ifndef MAP_PICKER
			if (tutorialLevel != UNDEFINED)
			{	
				self.selectedMap = TUTORIAL_MAPS[tutorialLevel];
				GameController* gameController = [[GameController allocAndAutorelease] initWithParent:self];
				gameController.selectedMap = selectedMap;
				user.lastPlayedMap = selectedMap;				
				[self addChild:gameController withID:CHILD_GAME];
				[self activateChild:CHILD_GAME];								
			}
			else
#endif
			{			
				MenuController* menu = [[MenuController allocAndAutorelease] initWithParent:self];
	//			menu.mapsList = mapsList;
				[self addChild:menu withID:CHILD_MENU];
				[self activateChild:CHILD_MENU];
			}
		}
		break;				
			
		case CHILD_MENU:
		{			
			rm.resourcesDelegate = (LoadingController*)[self getChild:CHILD_LOADING];
			[rm initLoading];
#ifdef MAP_PICKER
			[rm loadPack:(int*)PACK_MAPPICKER];
#else
			[rm loadPack:(int*)PACK_GAME];

			int mode = ([selectedMap hasPrefix:@"1"] ? 1 : 2);		
			if (mode == 1)
			{
				[rm loadPack:(int*)PACK_LEVEL_TREE];			
			}
			else 
			{
				[rm loadPack:(int*)PACK_LEVEL_TOWN];
			}
#endif
			[rm startLoading];				
			
			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			int tutorialLevel = rc.user.tutorialLevel;						
			if (tutorialLevel != UNDEFINED)
			{	
				self.selectedMap = TUTORIAL_MAPS[tutorialLevel];
			}				
			
			LoadingController* loadingController = (LoadingController*)[self getChild:CHILD_LOADING];					
#ifdef MAP_PICKER
			loadingController->nextController = CHILD_MAPPICKER;
#else
			loadingController->nextController = CHILD_GAME;
#endif
			loadingController->nextView = 0;				
			[self activateChild:CHILD_LOADING];
			
			MenuController* mc = (MenuController*)[self getChild:CHILD_MENU];			
			lastMode1Scroll = [mc->levels1Container getScroll];
			lastMode2Scroll = [mc->levels2Container getScroll];
			
			[self performSelector:@selector(destroyMenu) withObject:self afterDelay:0.01];
		}
		break;	
		
		case CHILD_LOADING:
		{
			LoadingController* loadingController = (LoadingController*)[self getChild:CHILD_LOADING];
			int nextController = loadingController->nextController;
			int nextView = loadingController->nextView;
			switch (nextController)
			{
				case CHILD_GAME:
				{
//					[ChampionsSoundMgr playMusic:SND_INGAME_THEME1];
					[self saveGameProgress];					
					GameController* gameController = [[GameController allocAndAutorelease] initWithParent:self];
					gameController.selectedMap = selectedMap;
					user.lastPlayedMap = selectedMap;
					[self addChild:gameController withID:CHILD_GAME];
					[self activateChild:CHILD_GAME];
					break;
				}
					
				case CHILD_MENU:
				{
					[self saveGameProgress];
					MenuController* menuController = [[MenuController allocAndAutorelease] initWithParent:self];
					[self addChild:menuController withID:CHILD_MENU];			

					[menuController->levels1Container setScroll:lastMode1Scroll];
					[menuController->levels2Container setScroll:lastMode2Scroll];
					
					[self activateChild:CHILD_MENU];
					
					if (nextView == VIRTUAL_VIEW_LEVEL_SELECT)
					{
						int mode = ([selectedMap hasPrefix:@"1"] ? 1 : 2);
						[menuController scrollToLevelSelectForMode:mode];
					}
					break;
				}		
#ifdef MAP_PICKER					
				case CHILD_MAPPICKER:
				{
					MapPickerController* mapPicker = [[MapPickerController allocAndAutorelease] initWithParent:self];
					[self addChild:mapPicker withID:CHILD_MAPPICKER];
					[self activateChild:CHILD_MAPPICKER];
					break;
				}
#endif // MAP_PICKER
				default:
					ASSERT(FALSE);
			}	
		}
		break;				
			
		case CHILD_GAME:
		{
			GameController* gameController = (GameController*)[self getChild:CHILD_GAME];
			int exitCode = gameController->exitCode;
			
			switch (exitCode)
			{
				case SELECT_LEVEL_PAUSE_MENU:
				case EXIT_CODE_FROM_PAUSE_MENU:
				{
					[self deleteChild:CHILD_GAME];	
					[rm freePack:(int*)PACK_GAME];
					ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
					int mode = ([rc.selectedMap hasPrefix:@"1"] ? 1 : 2);		
					if (mode == 1)
					{
						[rm freePack:(int*)PACK_LEVEL_TREE];
					}
					else 
					{
						[rm freePack:(int*)PACK_LEVEL_TOWN];
					}			
					
					rm.resourcesDelegate = (LoadingController*)[self getChild:CHILD_LOADING];
					[rm initLoading];
					[rm loadPack:(int*)PACK_MENU];
					[rm startLoading];				

					LoadingController* loadingController = (LoadingController*)[self getChild:CHILD_LOADING];					
					loadingController->nextController = CHILD_MENU;
					loadingController->nextView = (exitCode == SELECT_LEVEL_PAUSE_MENU) ? VIRTUAL_VIEW_LEVEL_SELECT : 0;									
					[self activateChild:CHILD_LOADING];						
//					[ChampionsSoundMgr stopMusic];
					break;
				}
					
				case RESTART_CODE_FROM_PAUSE_MENU:
				{
					[self performSelector:@selector(restartGame) withObject:nil afterDelay:0.001];	
					break;
				}
				
				case NEXT_LEVEL_CODE:
				{
					self.selectedMap = [self nextLevel:selectedMap];
#ifndef MAP_PICKER
					[self performSelector:@selector(restartGame) withObject:nil afterDelay:0.001];	
#else
					[self performSelector:@selector(restartPicker) withObject:nil afterDelay:0.001];	
#endif
					break;
				}

				default:
					ASSERT(FALSE);
			}
		}			
		break;

#ifdef MAP_PICKER
		case CHILD_MAPPICKER:
		{
			MapPickerController* mapPicker = (MapPickerController*)[self getChild:CHILD_MAPPICKER];
			self.selectedMap = mapPicker.selectedMap;
			[self deleteChild:CHILD_MAPPICKER];	
			[rm freePack:(int*)PACK_MAPPICKER];	
			
			rm.resourcesDelegate = (LoadingController*)[self getChild:CHILD_LOADING];
			[rm initLoading];
			[rm loadPack:(int*)PACK_GAME];

			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			
			int mode = ([rc.selectedMap hasPrefix:@"1"] ? 1 : 2);		
			if (mode == 1)
			{
				[rm loadPack:(int*)PACK_LEVEL_TREE];			
			}
			else 
			{
				[rm loadPack:(int*)PACK_LEVEL_TOWN];
			}			
			
			[rm startLoading];
			
			LoadingController* loadingController = (LoadingController*)[self getChild:CHILD_LOADING];					
			loadingController->nextController = CHILD_GAME;
			loadingController->nextView = 0;
			[self activateChild:CHILD_LOADING];
		}
		break;
#endif // MAP_PICKER
	}
}

+(void)loadNews
{
//#ifdef FREE
//	NSURL* url = [NSURL URLWithString:@"http://fpchampions.s3.amazonaws.com/free/news.xml"];
//#else	
//	NSURL* url = [NSURL URLWithString:@"http://fpchampions.s3.amazonaws.com/news.xml"];
//#endif
//	NewsParser* newsParser = [[[NewsParser alloc] initWithContentsOfURL:url] autorelease];
//	[newsParser setDelegate:newsParser];
//	[newsParser parse];
//
////	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://fpchampions.s3.amazonaws.com/news.xml"]];
////	NSURLResponse *response;	
////	NSError *error;	
////	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];	
////	
////	BOOL success = (!error) && ([(NSHTTPURLResponse *)response statusCode] == 200);
////	if(success)
////	{
////		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
////		NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"news.xml"];
////		[responseData writeToFile:path atomically:TRUE];
////	}
	
}

-(void)loadNewsInBackground
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // we're in a new thread here, so we need our own autorelease pool	
	[ChampionsRootController loadNews];
	[pool release];
}

+(void)loadMapListInBackground
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // we're in a new thread here, so we need our own autorelease pool	
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://reaxion.com/fpchampions/maplist.xml"]];	
	NSURLResponse *response;	
	NSError *error;	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];	
	
	BOOL success = (!error) && ([(NSHTTPURLResponse *)response statusCode] == 200);
	if(success)
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
		NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"maplist.xml"];
		[responseData writeToFile:path atomically:TRUE];
	}
	
	[pool release];
}

+(void)loadBanners
{	
#ifdef FREE	
	NSURL* url = [NSURL URLWithString:@"http://fpchampions.s3.amazonaws.com/free/ads.xml"];
#else
	NSURL* url = [NSURL URLWithString:@"http://fpchampions.s3.amazonaws.com/ads.xml"];
#endif
	BannerParser* parser = [[[BannerParser alloc] initWithContentsOfURL:url] autorelease];
	[parser setDelegate:parser];
	[parser parse];
}

-(void)loadBannersInBackground
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[ChampionsRootController loadBanners];
	[pool release];
}

#ifdef OPENFEINT
//- (BOOL)showCustomScreenForAnnouncement:(OFAnnouncement*)announcement
//{
//	return TRUE;
//}

//- (BOOL)showCustomOpenFeintApprovalScreen
//{
//	[OFUserService findUsersForLocalDeviceOnSuccess:OFDelegate(self, @selector(_findUsersSucceeded:)) onFailure:OFDelegate(self, @selector(_findUsersFailed))];
//	return TRUE;
//}

//- (void)_findUsersSucceeded:(OFPaginatedSeries*)resources
//{
//	int numUsers = [resources count];
//	for (<#initial#>; <#condition#>; <#increment#>) {
//		<#statements#>
//	}
//}

//-(void)_findUsersFailed
//{
//}

- (void)dashboardWillAppear
{
	if(![self isSuspended])
		[self suspend];
}

- (void)dashboardDidDisappear
{
	if(user && ![user.name isEqualToString:[OpenFeint lastLoggedInUserName]])
	{
		if(![[OpenFeint lastLoggedInUserId] isEqualToString:@"0"])
		{
			user.name = [OpenFeint lastLoggedInUserName];
		}
		
		[user updateUserRegistration:FALSE];
	}
	
	[self downloadUserPicture];
	MenuController* mc = (MenuController*)[self getChild:CHILD_MENU];
	if(mc)
	{
		[mc updateUserData];
	}
	
	if([self isSuspended])
		[self resume];
}

-(void)removeCachedUserPicture
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userPicture"];
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];	
}

-(void)downloadUserPicture
{
	//Save user picture to filesystem
	NSString* imgPath = [OpenFeint lastLoggedInUserProfilePictureUrl];
	if(imgPath)
	{
		NSURL* url = [NSURL URLWithString:imgPath];
//		NSLog(@"profile picture url %@", imgPath);
		
		NSData* data = [NSData dataWithContentsOfURL:url];
		if(!data)
		{
			OFImageCache* ofc = [OFImageCache sharedInstance];
			UIImage* img = [ofc fetch:imgPath];
			data = UIImagePNGRepresentation(img);
		}
		if(data)
		{
			NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
			NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userPicture"];
			[data writeToFile:path atomically:TRUE];
		}
//		else
//		{
//			[self removeCachedUserPicture];
//		}
	}
	else
	{
		[self removeCachedUserPicture];
	}
	MenuController* mc = (MenuController*)[self getChild:CHILD_MENU];
	if(mc)
	{
		[mc updateUserData];
	}
}

- (void)userLoggedIn:(NSString*)feintId
{
	if(!user.feintId || [user.feintId isEqualToString:feintId])
	{
		user.feintId = feintId;
		user.name = [OpenFeint lastLoggedInUserName];
	}
	[self startLoadingAnimation];

	[self downloadUserPicture];
//	NSLog(@"userLoggedIn feintId=%@ %@ countryId=%i", user.feintId, user.name, user.countryId);
	[self downloadGameProgress];
	if(user.clearBlob)
	{
		user.online = TRUE;
		[self uploadGameProgress];
		[user clearData];
	}
}

- (void)userLoggedOut:(NSString*)userId
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userPicture"];
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
	
	[user release];
	user = [[FPUser alloc] init];
	[user setDefaults];
	[user updateUserRegistration:FALSE];
	[user saveGameProgress];
	MenuController* mc = (MenuController*)[self getChild:CHILD_MENU];
	if(mc)
	{
		[mc updateUserData];
	}	
}

-(void)settingsDownloadSuccess:(NSData*)data
{
//	NSLog(@"data length %i", [data length]);
	[self stopLoadingAnimation];
	FPUser* userData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//	NSLog(@"user settings load success");
//	NSLog(@"downloaded %@ %@ %i", userData.userId, userData.name, userData.countryId);
	userData.online = TRUE;
	[userData updateGameProgress:user];
	[user release];
	user = userData;
	[user retain];
	user.feintId = [OpenFeint lastLoggedInUserId];
	user.name = [OpenFeint lastLoggedInUserName];
	user.udId = [[UIDevice currentDevice] uniqueIdentifier];
	[user updateUserRegistration:FALSE];
	//[self uploadGameProgress];
	[self saveGameProgress];
	MenuController* mc = (MenuController*)[self getChild:CHILD_MENU];
	if(mc)
	{
		[mc updateUserData];
	}
	
}

-(void)settingsDownloadFailure:(OFCloudStorageStatus_Object*)param
{
	[self stopLoadingAnimation];
	if([param getStatusCode] == CSC_NotFound)
	{
		if(user)user.online = TRUE;
		[self uploadGameProgress];
	}
//	NSLog(@"user settings load failure");
}

-(void)settingsUploadSuccess
{
	if(user)
		user.clearBlob = FALSE;
//	NSLog(@"settings uploaded");
}

-(void)settingsUploadFailure
{
//	NSLog(@"settings upload failure");
}

-(BOOL)canReceiveCallbacksNow
{
	return TRUE;
}

-(void)uploadGameProgress
{
	if(user && user.online)
	{
//		[user updateUserRegistration:FALSE];
		NSData* data = [NSKeyedArchiver archivedDataWithRootObject:user];
//		NSLog(@"data len %i", [data length]);
		
#ifdef FREE
		NSString* blobName = @"settings_free";
#else
		NSString* blobName = @"settings";
#endif
		
		[OFCloudStorageService uploadBlob:data withKey:blobName onSuccess:OFDelegate(self, @selector(settingsUploadSuccess)) onFailure:OFDelegate(self, @selector(settingsUploadFailure))];
	}
}

-(void)downloadGameProgress
{
#ifdef FREE
	NSString* blobName = @"settings_free";
#else
	NSString* blobName = @"settings";
#endif
	
	if(user && !user.clearBlob)
	{
		[OFCloudStorageService downloadBlobWithKey:blobName onSuccess:OFDelegate(self, @selector(settingsDownloadSuccess:)) onFailure:OFDelegate(self,  @selector(settingsDownloadFailure:))];
	}
	else
	{
		[self stopLoadingAnimation];
	}
}

#endif

-(void)saveGameProgress
{
	if(user)
		[user saveGameProgress];
}

#pragma mark Email code
#pragma mark -

+(MFMailComposeViewController*)mailWithSubject:(NSString*)subject body:(NSString*)emailBody to:(NSString*)to isHTML:(BOOL)isHtml delegate:(id)delegate
{
	float os_version = [[UIDevice currentDevice].systemVersion floatValue];
	if(os_version < 3.0f)
	{
		[self sendEmailTo:to withSubject:subject withBody:emailBody];
		return nil;
	}
	else
	{
		MFMailComposeViewController* email = [[MFMailComposeViewController alloc] init];
		email.mailComposeDelegate = delegate;
		
		// Optional Attachments
		//	NSData *artwork = UIImagePNGRepresentation([UIImage imageNamed:@"info.png"]);
		//	[email addAttachmentData:artwork mimeType:@"image/png" fileName:@"info.png"];
		
		// Subject
		[email setSubject:subject];
		[email setMessageBody:emailBody isHTML:isHtml];
		if(to && ![to isEqualToString:@""])
			[email setToRecipients:[NSArray arrayWithObject:to]];
		
		[[Application sharedCanvas] addSubview: email.view];
		return email;
	}
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller.view removeFromSuperview];
	[controller release];
}

+(void)sendEmailTo:(NSString*)to withSubject:(NSString*)subject withBody:(NSString*)body
{
	NSString* mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
							[to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
							[subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
							[body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}

#pragma mark -

-(void)operateCurrentMVC
{
	if(loadingRetainCount <= 0)
		[super operateCurrentMVC];
}

-(void)startLoadingAnimation
{
	loadingRetainCount++;
//	NSLog(@"loadingRetainCount %i", loadingRetainCount);
	if(loadingRetainCount > 1)return;
	CGRect rect = {0, 0, SCREEN_WIDTH, SCREEN_HEIGHT};
	loadingView = [[UIView allocAndAutorelease] initWithFrame:rect];
	spinner = [[[UIActivityIndicatorView alloc]
										 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	CGPoint p = {rect.size.width/2, rect.size.height/2};
	spinner.center = p;
	loadingView.backgroundColor = [UIColor blackColor];
	loadingView.alpha = 0.3;
	loadingView.exclusiveTouch = TRUE;
	loadingView.userInteractionEnabled = FALSE;
	[loadingView addSubview:spinner];
	[spinner startAnimating];
	[[Application sharedCanvas] addSubview:loadingView];
}

-(void)stopLoadingAnimation
{
	loadingRetainCount--;
//	NSLog(@"loadingRetainCount %i", loadingRetainCount);
	if(loadingRetainCount == 0)
	{
		[spinner stopAnimating];
		[loadingView removeFromSuperview];
	}
}

-(void)resetProgress
{
	if(user)
	{
		int cId = user.countryId;
		[user clearData];
		[user release];
		user = [[FPUser alloc] init];
		[user setDefaults];
		user.countryId = cId;
		// user.feintId = [OpenFeint lastLoggedInUserId];
		// user.name = [OpenFeint lastLoggedInUserName];
		[user updateUserRegistration:TRUE];
		user.clearBlob = TRUE;
		[user saveGameProgress];
		user.online = TRUE;		
	}
	MenuController* mc = (MenuController*)[self getChild:CHILD_MENU];
	if(mc)
		[mc updateUserData];
}

-(void)suspend
{
	[super suspend];

	GameController* gc = (GameController*)[self getChild:CHILD_GAME];
	if ([self getCurrentController] == gc)
	{	
		View* v = [gc activeView];
		if (!gc->popupShown && ![Baloon hasBaloonInView:v])
		{
			[gc showPauseMenu];
		}
	}
}

-(BOOL)allLevelsCompleted
{
	if(!user)return FALSE;
	
	for(LevelSet* set in mapsList)
	{
		for (NSString* mapName in set->list)
		{
			FPScores* scores = [user getScoresForMap:mapName];
			if(!scores || scores->medal == 0)return FALSE;
		}		
	}
	return TRUE;
}

- (void)greystripeAdReadyForSlotNamed:(NSString *)a_name
{
	NSLog(@"%@ ready", a_name);
}

- (void)greystripeFullScreenDisplayWillOpen
{
	NSLog(@"Full screen will open");
	if (![self isSuspended]) 
		[super suspend];
}

- (void)greystripeFullScreenDisplayWillClose
{
	NSLog(@"Full screen will close");
	if ([self isSuspended]) 
		[self resume];
}

- (void)greystripeDidReceiveMemoryWarning
{
	NSLog(@"Memory warning");
}

-(void)saveBannerDate
{
	self.bannerDate = [NSDate date];
}

-(NSTimeInterval)diffFromPreviousBannerDate
{
	return [[NSDate date] timeIntervalSinceDate:bannerDate];
}

-(BOOL)shouldShowBanner
{
	return FALSE;
}

-(void)showGSBanner
{
}

-(void)setAdWhirlBanner
{
}

-(void)showAdWhirlBanner
{
}

-(void)hideAdWhirlBanner
{
}

@end
