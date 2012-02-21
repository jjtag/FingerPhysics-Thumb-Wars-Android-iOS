//
//  GameController.m
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameController.h"
#import "GameView.h"
#import "GameScene.h"
#import "ChampionsSoundMgr.h"
#import "ChampionsResourceMgr.h"
#import "ChampionsRootController.h"
#import "MenuController.h"
#import "MapParser.h"
#import "Mode1Scene.h"
#import "Mode2Scene.h"
#import "MapPickerController.h"
#import "GameTimer.h"
#import "ChampionsPreferences.h"
#import "Baloon.h"
// #import "OFAchievementService.h"
#import "TextScores.h"
#import "ReviewRequest.h"

#import "Localization.h"

RGBAColor greenColor = RGBA_FROM_HEX(133, 166, 3, 255);
RGBAColor three_color = RGBA_FROM_HEX(198, 214, 16, 255);
RGBAColor three_color_a = RGBA_FROM_HEX(198, 214, 16, 0);
RGBAColor two_color = RGBA_FROM_HEX(245, 143, 3, 255);
RGBAColor one_color = RGBA_FROM_HEX(222, 17, 17, 255);		
RGBAColor two_color_a = RGBA_FROM_HEX(245, 143, 3, 0);
RGBAColor one_color_a = RGBA_FROM_HEX(222, 17, 17, 0);
const RGBAColor pauseBlueColor = RGBA_FROM_HEX(4, 60, 135, 255);
RGBAColor bestScoreColor = RGBA_FROM_HEX(171, 16, 0, 255);

@implementation GameController

@synthesize selectedMap;

+(void)unlockAchievement:(int)ac
{
#ifndef FREE 
	ASSERT(ac >= 0);
	// [OFAchievementService unlockAchievement:FORMAT_STRING(@"%d", ac)];
#endif
}

- (id)initWithParent:(ViewController*)p
{
	if (self = [super initWithParent:p]) 
	{
		mapParser = [[MapParser alloc] init];
		timer_state = TIMER_STOPPED;
		game_state = GAME_RESULT_NONE;
//		soundResumeTimer = nil;
#ifdef FREE		
		View* buyFullView = [[View allocAndAutorelease] initFullscreen];
		Image* fullSplash = [Image create:[ChampionsResourceMgr getResource:IMG_SPLASH]];
		fullSplash->parentAnchor = fullSplash->anchor = TOP | LEFT;
		
		VBox* box = [[VBox allocAndAutorelease] initWithOffset:10 Align:HCENTER Width:SCREEN_WIDTH];
		box->y = -50;
		box->parentAnchor = box->anchor = BOTTOM | HCENTER;
		
		Texture2D* tbuy = [ChampionsResourceMgr getResource:IMG_GETITNOW];	
		Button* buyButton = [MenuController createButtonWithTextureUp:tbuy Down:tbuy ID:BUTTON_SPLASH_BUY scaleRatio:1.2];
		buyButton.delegate = self;
		
		[box addChild:buyButton];
		
		Texture2D* tcancel = [ChampionsResourceMgr getResource:IMG_NOTHANKS];
		Button* cancelButton = [MenuController createButtonWithTextureUp:tcancel Down:tcancel ID:BUTTON_SPLASH_CANCEL scaleRatio:1.2];
		cancelButton.delegate = self;
		
		[box addChild:cancelButton];
		[fullSplash addChild:box];
		[buyFullView addChild:fullSplash];
		[self addView:buyFullView withID:VIEW_BUY_FULL];
#endif		
	}
	return self;
}

-(void)activate
{
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	[super activate];
	[self loadMap];
	popupShown = FALSE;
//	[ChampionsSoundMgr playMusic:SND_GAME_MUSIC];
}

-(void)deactivate
{
#ifdef FREE
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if( (game_state == GAME_RESULT_WIN || game_state == GAME_RESULT_LOSE) && rc.user.tutorialLevel == UNDEFINED )
	{
		if([rc diffFromPreviousBannerDate] > 2*60)
		{
			[rc showGSBanner];
		}
	}
#endif
//	if(soundResumeTimer)
//		[soundResumeTimer invalidate];
	[super deactivate];
	[UIApplication sharedApplication].idleTimerDisabled = FALSE;
}

-(void)loadMap
{
#ifndef MAP_PICKER
	NSString* path = [[NSBundle mainBundle] pathForResource:@"library" ofType:@"xml"];
	NSData* data = [[[NSData alloc] initWithContentsOfFile:path] autorelease];
	
	XMLParser* parser = [[[XMLParser alloc] init] autorelease];
	[parser setDelegate:self];
	[parser parseData:data];
#else
	XMLSaxLoader* loader = [[[XMLSaxLoader alloc] init] autorelease];
	[loader turnOnCache];
	loader.delegate = self;
	NSString* url = @"http://reaxion.com/mapeditor/library.xml";
	[loader load:url];
#endif
}

-(Button*)createPauseButton:(int)image withID:(int)bid
{
	RGBAColor green = RGBA_FROM_HEX(137, 166, 3, 255);
	Image* tn = [Image create:[ChampionsResourceMgr getResource:IMG_PAUSEPLAY_BACK]];
	tn->color = green;
	tn->passColorToChilds = FALSE;
	
	Image* pauseButton = [Image create:[ChampionsResourceMgr getResource:image]];
	pauseButton->parentAnchor = pauseButton->anchor = CENTER;
	[tn addChild:pauseButton];
	
	Image* tp = [Image create:[ChampionsResourceMgr getResource:IMG_PAUSEPLAY_BACK]];
	tp->color = green;
	tp->passColorToChilds = FALSE;
	tp->scaleX = tp->scaleY = 1.2f;
	
	Image* pauseButton2 = [Image create:[ChampionsResourceMgr getResource:image]];
	pauseButton2->parentAnchor = pauseButton2->anchor = CENTER;
	[tp addChild:pauseButton2];
	
	Button* b = [[Button allocAndAutorelease] initWithUpElement:tn DownElement:tp andID:bid];	
	b.delegate = self;
	[b setTouchIncreaseLeft:10 Right:60 Top:20 Bottom:5];
	b->parentAnchor = b->anchor = TOP | LEFT;
	b->x = 2;
	b->y = 3;
	return b;	
}

-(void)createGameView
{	
	showCameraUI = mapParser.settings.height > SCREEN_HEIGHT;
	RGBAColor grayColor = (RGBAColor)RGBA_FROM_HEX(64,64,64,255);
	GameView* view = [[GameView allocAndAutorelease] initFullscreen];
	
	GameScene* sc;
	switch (mapParser.settings.mode) {
		case 1:
			sc = [Mode1Scene create];
			break;
		case 2:
			sc = [Mode2Scene create];
			break;
		default:
			sc = [GameScene create];
			break;
	}
	
	sc.delegate = self;
	
	[view addChild:sc withID:VIEW_ELEMENT_GAME_SCENE];
	
	Image* pauseBack = [Image create:[ChampionsResourceMgr getResource:IMG_PAUSE_BACK]];
	pauseBack->parentAnchor = pauseBack->anchor = TOP | RIGHT;
	pauseBack->x = -10;
	[view addChild:pauseBack withID:VIEW_ELEMENT_PAUSE_BUTTON];
	Font* font = [ChampionsResourceMgr getResource:FNT_FONTS_001];
	GameTimer* gameTimer = [[GameTimer allocAndAutorelease] initWithFont:font];
	//	gameTimer->parentAnchor = TOP | RIGHT;
	//	gameTimer->anchor = TOP | LEFT;
	//	gameTimer->x = -[font stringWidth:@"00:00"] - 5;
	//	gameTimer->y = -3;
	gameTimer->x = 311.0 -[font stringWidth:@"00:00"] - 5;
	gameTimer->y = -3;
	gameTimer->scaleX = gameTimer->scaleY = 0.9;
	gameTimer->color = (RGBAColor)RGBA_FROM_HEX(153, 153, 153, 255);
	[gameTimer setAlignment:LEFT];
	[pauseBack addChild:gameTimer];	
	sc.gameTimer = gameTimer;
	
	//Pause button
	Button* b = [self createPauseButton:IMG_PAUSE_BUTTON withID:BUTTON_PAUSE];
	[pauseBack addChild:b];
	
	//Create camera joystick
#pragma mark joystick
	Joystick* joystick = [Joystick create:[ChampionsResourceMgr getResource:IMG_CAMERA_WHITEBACK] maxOffsetX:0 maxOffsetY:25];
	joystick->parentAnchor = joystick->anchor = TOP | RIGHT;
	joystick->y = pauseBack->height / 2 + 14;
	joystick->x = -25;
	joystick.delegate = sc;
	
	Timeline* tjoy = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:4];
	KeyFrame frame = makePos(joystick->x, joystick->y, FRAME_TRANSITION_LINEAR, 0);
	[tjoy addKeyFrame:frame];	
	frame = makePos(joystick->x, joystick->y+15, FRAME_TRANSITION_LINEAR, 0.5);
	[tjoy addKeyFrame:frame];	
	frame = makePos(joystick->x, joystick->y-30, FRAME_TRANSITION_LINEAR, 1);
	[tjoy addKeyFrame:frame];
	frame = makePos(joystick->x, joystick->y, FRAME_TRANSITION_LINEAR, 0.5);
	[tjoy addKeyFrame:frame];
	[joystick addTimeline:tjoy];
	
	[view addChild:joystick withID:VIEW_ELEMENT_CAMERA];
	
	Image* cameraColorBack = [Image create:[ChampionsResourceMgr getResource:IMG_CAMERA_BACK]];
	cameraColorBack->parentAnchor = cameraColorBack->anchor = CENTER;
	RGBAColor green = RGBA_FROM_HEX(137, 166, 3, 255);
	cameraColorBack->color = green;
	[joystick addChild:cameraColorBack];
	cameraColorBack->passColorToChilds = false;
	
	Image* camera = [Image create:[ChampionsResourceMgr getResource:IMG_CAMERA]];
	camera->parentAnchor = camera->anchor = CENTER;
	[cameraColorBack addChild:camera];
	
#pragma mark timer
	Joystick* timer = [Joystick create:[ChampionsResourceMgr getResource:IMG_CAMERA_WHITEBACK] maxOffsetX:0 maxOffsetY:25];
	//	Image* timer = [Image createWithResID:IMG_CAMERA_WHITEBACK];
	timer->parentAnchor = timer->anchor = TOP | RIGHT;
	timer->y = pauseBack->height / 2 + 14;
	timer->x = -25;
	timer.delegate = sc;
	[timer setEnabled:FALSE];
	
	Image* timer_back = [Image createWithResID:IMG_CAMERA_BACK];
	timer_back->parentAnchor = timer_back->anchor = CENTER;
	[timer addChild:timer_back];
	
	Image* timer_front = [Image createWithResID:IMG_CAMERA_BACK];
	timer_front->parentAnchor = timer_front->anchor = CENTER;
	timer_front->color = transparentRGBA;
	timer_front->passColorToChilds = FALSE;
	
	digits = [Image createWithResID:IMG_COUNTER Quad:2];
	digits->parentAnchor = digits->anchor = CENTER;	
	[digits setEnabled:FALSE];
	[timer_front addChild:digits];
	
	[timer addChild:timer_front];
	[view addChild:timer withID:VIEW_ELEMENT_TIMER];
	
	Timeline* t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:5];
	[t addKeyFrame:makeScale(1, 1, FRAME_TRANSITION_IMMEDIATE, 0)];
	[t addKeyFrame:makeScale(0.1f, 1, FRAME_TRANSITION_LINEAR, 0.5)];
	[t addKeyFrame:makeScale(1, 1, FRAME_TRANSITION_LINEAR, 0.5)];
	[t addKeyFrame:makeColor(solidOpaqueRGBA, FRAME_TRANSITION_IMMEDIATE, 0)];
	[t addKeyFrame:makeColor(solidOpaqueRGBA, FRAME_TRANSITION_LINEAR, 4)];
	[t addKeyFrame:makeColor(transparentRGBA, FRAME_TRANSITION_LINEAR, 1)];
	[t setTimelineLoopType:TIMELINE_NO_LOOP];
	
	Timeline* t2 = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:5];
	[t2 addKeyFrame:makeColor(greenColor, FRAME_TRANSITION_IMMEDIATE, 0)];
	[t2 addKeyFrame:makeColor(three_color, FRAME_TRANSITION_IMMEDIATE, 1)];
	[t2 addKeyFrame:makeColor(two_color, FRAME_TRANSITION_IMMEDIATE, 1)];
	[t2 addKeyFrame:makeColor(one_color, FRAME_TRANSITION_IMMEDIATE, 1)];
	[t2 addKeyFrame:makeColor(transparentRGBA, FRAME_TRANSITION_IMMEDIATE, 1)];
	[t2 setTimelineLoopType:TIMELINE_NO_LOOP];
	[t2 setDelegate:self];
	[timer addTimeline:t];
	[timer_back addTimeline:t2];	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark pause menu	
	Image* pauseMenu = [Image createWithResID:IMG_MAIN_BACK];
	pauseMenu->parentAnchor = pauseMenu->anchor = TOP | HCENTER;
	pauseMenu->y = 0.0;
	
	Image* pauseBack1 = [Image createWithResID:IMG_OPTIONS_BACK];
	pauseBack1->anchor = pauseBack1->parentAnchor = BOTTOM | HCENTER;
	pauseBack1->y = -20.0;
	[pauseMenu addChild:pauseBack1];

	Image* bestScoreBack = [Image createWithResID:IMG_PAUSE_YOURSTAT_SCREEN];
	bestScoreBack->anchor = bestScoreBack->parentAnchor = TOP | HCENTER;
	bestScoreBack->y = 40.0;
	bestScoreBack->x = -20.0;	
	Text* bestScoreLabel = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL]];
	bestScoreLabel->color = pauseBlueColor;
	bestScoreLabel->x = 65.0;
	bestScoreLabel->y = 55.0;
	bestScoreLabel->rotation = -4.0;
	[bestScoreLabel setString:LocalizedString(@"STR_WIN_BEST_SCORE", @"Your Best Score")];
	[bestScoreBack addChild:bestScoreLabel];
	[pauseMenu addChild:bestScoreBack];			

	
	Text* bestScoreText = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001]];
	bestScoreText->color = bestScoreColor;
	bestScoreText->x = 68.0;
	bestScoreText->y = 70.0;
	bestScoreText->rotation = -3.0;

	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	FPScores* scores = [rc.user getScoresForMap:rc.selectedMap];
	NSString* bestScore = (scores == nil) ? @"0" : FORMAT_STRING(@"%d", scores->scores);
	
	[bestScoreText setString:bestScore];
	
	[bestScoreBack addChild:bestScoreText];	
	
	Image* pauseTitle = [Image createWithResID:IMG_PAUSE_YOURSTAT_BACK];
	pauseTitle->anchor = pauseTitle->parentAnchor = TOP | HCENTER;
	pauseTitle->y = 15.0;
	pauseTitle->x = -85.0;
	
	Text* pauseLabel = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001]];
	pauseLabel->color = MakeRGBA(0.4, 0.4, 0.4, 1.0);
	pauseLabel->x = 30.0;
	[pauseLabel setString:LocalizedString(@"STR_PAUSE_LABEL", @"Pause Menu")];
	pauseLabel->anchor = pauseLabel->parentAnchor = CENTER;
	[pauseTitle addChild:pauseLabel];
	[pauseMenu addChild:pauseTitle];			
	
	Image* pauseTimerBack = [Image create:[ChampionsResourceMgr getResource:IMG_PAUSE_BACK]];
	pauseTimerBack->parentAnchor = pauseTimerBack->anchor = TOP | RIGHT;
	pauseTimerBack->x = -10;
	font = [ChampionsResourceMgr getResource:FNT_FONTS_001];
	[pauseTimerBack addChild:gameTimer];
	[pauseMenu addChild:pauseTimerBack];
	
	//Pause button
	b = [self createPauseButton:IMG_PAUSEMENU_PLAY_BUTTON withID:BUTTON_PAUSE_RESUME];
	[pauseTimerBack addChild:b];		
	
	VBox* box = [[VBox allocAndAutorelease] initWithOffset:3.0 Align:HCENTER Width:SCREEN_WIDTH];
	
	Button* resumeb = [MenuController createButtonWithText:LocalizedString(@"STR_RESUME_LABEL", @"Back to Game") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_PAUSE_RESUME Delegate:self color:pauseBlueColor];
	[box addChild:resumeb];
	
	Button* restartb = [MenuController createButtonWithText:LocalizedString(@"STR_RESTART_LABEL", @"Restart") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_RESTART Delegate:self color:pauseBlueColor];
	[box addChild:restartb];		
	
	int tutorialLevel = rc.user.tutorialLevel;
	
	if (tutorialLevel == UNDEFINED)
	{
		Button* nextWinb = [MenuController createButtonWithText:LocalizedString(@"STR_NEXT_LEVEL", @"Next level") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_NEXT Delegate:self color:pauseBlueColor];
		[box addChild:nextWinb];		
	}
	else
	{
		Font* font = [ChampionsResourceMgr getResource:FNT_PAUSE_MENU_BIG_FONT]; 
		Text* tn = [[Text allocAndAutorelease] initWithFont:font];
		tn->color = pauseBlueColor;
		[tn setString:LocalizedString(@"STR_NEXT_LEVEL", @"Next level")];
		[box addChild:tn];
		tn->passColorToChilds = FALSE;

		Image* ts = [Image createWithResID:IMG_PAUSE_NON_ACTIVE_MENU_01];
		ts->anchor = ts->parentAnchor = CENTER;
		ts->rotation = 4.0;
		[tn addChild:ts];
	}
	
	
	if (tutorialLevel == UNDEFINED)
	{
		//Button* selectlvlb = [MenuController createButtonWithText:@"Select level" fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_PAUSE_SELECT_LEVEL Delegate:self color:pauseBlueColor];
		//[box addChild:selectlvlb];	

		Button* mainmenub = [MenuController createButtonWithText:LocalizedString(@"STR_MENU_MAIN_MENU", @"Main Menu") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_PAUSE_EXIT Delegate:self color:pauseBlueColor];
		[box addChild:mainmenub];		
	}
	else
	{
		Font* font = [ChampionsResourceMgr getResource:FNT_PAUSE_MENU_BIG_FONT]; 
		Text* tn = [[Text allocAndAutorelease] initWithFont:font];
		tn->color = pauseBlueColor;
		[tn setString:LocalizedString(@"STR_MAIN_MENU", @"Main Menu")];
		[box addChild:tn];
		tn->passColorToChilds = FALSE;
		Image* ts = [Image createWithResID:IMG_PAUSE_NON_ACTIVE_MENU_02];
		ts->anchor = ts->parentAnchor = CENTER;
		ts->rotation = -2.0;
		[tn addChild:ts];
	}
	
	Button* optionsb = [MenuController createButtonWithText:LocalizedString(@"STR_OPTIONS", @"Options") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_PAUSE_OPTIONS Delegate:self color:pauseBlueColor];
	[box addChild:optionsb];			
	
#ifdef CHEAT
	Button* cheatb = [MenuController createButtonWithText:@"Cheat" fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_PAUSE_CHEAT Delegate:self color:pauseBlueColor];
	[box addChild:cheatb];	
#endif
	
#ifdef MAP_PICKER
	Text* mapname = [[[Text alloc] initWithFont:[ChampionsResourceMgr getResource:FNT_PAUSE_MENU_BIG_FONT]] autorelease];
	mapname->color = grayColor;
	[mapname setString:selectedMap];
	[box addChild:mapname];
#endif
	
	box->anchor = box->parentAnchor = CENTER;
	[pauseBack1 addChild:box];	
	
	[view addChild:pauseMenu withID:VIEW_ELEMENT_PAUSE_MENU];	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	pauseMenu = [Image createWithResID:IMG_MAIN_BACK];
	pauseMenu->parentAnchor = pauseMenu->anchor = TOP | HCENTER;
	pauseMenu->y = 0.0;
/*	
	pauseBack1 = [Image createWithResID:IMG_OPTIONS_BACK];
	pauseBack1->anchor = pauseBack1->parentAnchor = BOTTOM | HCENTER;
	pauseBack1->y = -20.0;
	[pauseMenu addChild:pauseBack1];
*/	
	pauseTitle = [Image createWithResID:IMG_PAUSE_YOURSTAT_BACK];
	pauseTitle->anchor = pauseTitle->parentAnchor = TOP | HCENTER;
	pauseTitle->y = 15.0;
	pauseTitle->x = -85.0;
	
	pauseLabel = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001]];
	pauseLabel->color = MakeRGBA(0.4, 0.4, 0.4, 1.0);
	pauseLabel->x = 30.0;
	[pauseLabel setString:LocalizedString(@"STR_OPTIONS", @"Options")];
	pauseLabel->anchor = pauseLabel->parentAnchor = CENTER;
	[pauseTitle addChild:pauseLabel];
	[pauseMenu addChild:pauseTitle];			
	
	pauseTimerBack = [Image create:[ChampionsResourceMgr getResource:IMG_PAUSE_BACK]];
	pauseTimerBack->parentAnchor = pauseTimerBack->anchor = TOP | RIGHT;
	pauseTimerBack->x = -10;
	font = [ChampionsResourceMgr getResource:FNT_FONTS_001];
	[pauseTimerBack addChild:gameTimer];
	[pauseMenu addChild:pauseTimerBack];
	
	Button* optionsBack = [MenuController createButtonWithImage:IMG_PAUSE_BACKBT ID:BUTTON_OPTIONS_BACK Delegate:self];
	[pauseMenu addChild:optionsBack];
	optionsBack->x = -20.0;
	
	//Pause button
	b = [self createPauseButton:IMG_PAUSEMENU_PLAY_BUTTON withID:BUTTON_PAUSE_RESUME];
	[pauseTimerBack addChild:b];	
	
	ToggleButton* bmusic = [MenuController createToggleButtonWithBack:IMG_TITLE_BIG toggleFront:IMG_RED_LINE_01 Text:LocalizedString(@"STR_OPTIONS_MUSIC", @"Music") ID:BUTTON_PAUSE_MUSIC_ONOFF Delegate:self];
	bmusic->parentAnchor = TOP | HCENTER;
	bmusic->anchor = TOP | LEFT;
	bmusic->y = 180;
	bmusic->x = -20;
	bmusic->rotation = - 3;
	[pauseMenu addChild:bmusic];
	
	ToggleButton* bsound = [MenuController createToggleButtonWithBack:IMG_TITLE_BIG toggleFront:IMG_RED_LINE_02 Text:LocalizedString(@"STR_OPTIONS_SOUND", @"Sound") ID:BUTTON_PAUSE_SOUND_ONOFF Delegate:self];
	bsound->parentAnchor = TOP | HCENTER;
	bsound->anchor = TOP | LEFT;
	bsound->y = 210;
	bsound->x = -20;
	bsound->rotation = 3;
	[pauseMenu addChild:bsound];
	
	ChampionsPreferences* p = (ChampionsPreferences*)[Application sharedPreferences];
	bool soundOn = [p getBooleanForKey:(NSString*)PREFS_SOUND_ON];	
	bool musicOn = [p getBooleanForKey:(NSString*)PREFS_MUSIC_ON];	
	
	if (!soundOn)
	{
		[bsound toggle];
	}
	
	if (!musicOn)
	{
		[bmusic toggle];
	}
	
	Image* handBack = [Image createWithResID:IMG_OPTIONS_FOR_HAND];
	handBack->parentAnchor = handBack->anchor = TOP | HCENTER;
	handBack->y = 150.0;
	handBack->x = -45;
	[pauseMenu addChild:handBack];	
	
	Image* handRight = [Image createWithResID:IMG_OPTIONS_RIGHT_SOUND];
	handRight->parentAnchor = handRight->anchor = BOTTOM | HCENTER;
	[handBack addChild:handRight];	
	
	[view addChild:pauseMenu withID:VIEW_ELEMENT_OPTIONS];	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////	
#pragma mark win menu		
	Image* winMenu = [Image create:[ChampionsResourceMgr getResource:IMG_WIN_TRYAGAIN_BACK]];
	winMenu->anchor = CENTER;
	winMenu->x = SCREEN_WIDTH / 2;
	winMenu->y = SCREEN_HEIGHT / 2;
	
	Image* winMenuAnim = [Image createWithResID:IMG_WIN_TRYAGAIN_BACK_02];
	winMenuAnim->parentAnchor = winMenuAnim->anchor = CENTER;
	winMenuAnim->y = -10;
	
	Timeline* tl = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:2];
	[tl addKeyFrame:makeRotation(0.0, FRAME_TRANSITION_LINEAR, 0.0)];	
	[tl addKeyFrame:makeRotation(360, FRAME_TRANSITION_LINEAR, 5)];
	[tl setTimelineLoopType:TIMELINE_REPLAY];
	[winMenuAnim addTimeline:tl];
	[winMenuAnim playTimeline:0];
	
	[winMenu addChild:winMenuAnim];

	Font* font_pause_menu = [ChampionsResourceMgr getResource:FNT_FONTS_001];
	
	Image* winTitle = [Image createWithResID:IMG_YOU_WIN];
	[winMenu addChild:winTitle];
	winTitle->anchor = winTitle->parentAnchor = TOP | HCENTER;
	winTitle->y = -40.0;	
	
	VBox* winBox = [[[VBox alloc] initWithOffset:2 Align:HCENTER Width:winMenu->width] autorelease];
	[winBox setName:@"winBox"];
	winBox->parentAnchor = CENTER;
	winBox->anchor = TOP | HCENTER;
	
//	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
#ifdef FREE	
	winBox->y = -100;	
	Text* upgradeText = [[Text allocAndAutorelease] initWithFont:font_pause_menu];
	[upgradeText setAlignment:HCENTER];
	[upgradeText setString:LocalizedString(@"STR_UPGRADE_TEXT", @"Upgrade to Full to compete in weekly Thumb Wars!") andWidth:280.0];
	upgradeText->scaleX = upgradeText->scaleY = 0.75;
	upgradeText->passColorToChilds = FALSE;
	upgradeText->color = bestScoreColor;
	
	Text* upgradeTextPressed = [[Text allocAndAutorelease] initWithFont:font_pause_menu];
	[upgradeTextPressed setAlignment:HCENTER];
	[upgradeTextPressed setString:LocalizedString(@"STR_UPGRADE_TEXT", @"Upgrade to Full to compete in weekly Thumb Wars!") andWidth:280.0];
	upgradeTextPressed->scaleX = upgradeTextPressed->scaleY = 0.90;
	upgradeTextPressed->passColorToChilds = FALSE;
	upgradeTextPressed->color = bestScoreColor;
	
//	[winBox addChild:upgradeText];
//	upgradeText->parentAnchor = upgradeText->anchor = TOP | LEFT;			
//	upgradeText->y = 10.0;
//	upgradeText->x = 10.0;	
	
	Button* buyFullButton = [[Button allocAndAutorelease] initWithUpElement:upgradeText DownElement:upgradeTextPressed andID:BUTTON_SPLASH_BUY];
	buyFullButton.delegate = self;
	[winBox addChild:buyFullButton];
	buyFullButton->parentAnchor = buyFullButton->anchor = TOP | LEFT;
	buyFullButton->y = 10.0;
	buyFullButton->x = 10.0;
	
#else
	winBox->y = -55;	
	
	if(rc && rc.user && rc.user.countryId != 0)
	{
		int teamScoreOffset = 135;
		int countryPoints = 0;
		int cId = rc.user.countryId;
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
		NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"countries"];
		NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
		if(dict && [dict objectForKey:@"count"])
		{
			for (int i = 0; i < [[dict objectForKey:@"count"] intValue]; i++)
			{
				NSString* obj = [dict objectForKey:FORMAT_STRING(@"countryId%i", i)];
				if(obj && [obj isEqualToString:FORMAT_STRING(@"%i", rc.user.countryId)])				
				{
					countryPoints = [[dict objectForKey:FORMAT_STRING(@"points%i",i)] intValue];
				}				
			}
		}
		winBox->y -= 20;
		TextScores* countryScores = [TextScores createWithFont:font_pause_menu points:countryPoints prefix:@""];
		countryScores->passColorToChilds = FALSE;
		countryScores->color = bestScoreColor;
		countryScores->x = teamScoreOffset;
		[countryScores setName:@"countryScores"];
		[winBox addChild:countryScores];
		countryScores->anchor = countryScores->parentAnchor = TOP | LEFT;
		BaseElement* flag = [MenuController createFlag:cId];
		if(flag)
		{
			flag->parentAnchor = LEFT | VCENTER;
			flag->anchor = RIGHT | VCENTER;
			flag->x = -10;
			[countryScores addChild:flag];
		}
		if(cId == COUNTRY_US && rc.user.stateId != 0 )
		{
			winBox->y -= 20;
			int sId = rc.user.stateId;
			int statePoints = 0;
			NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
			NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"states"];
			NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
			if(dict && [dict objectForKey:@"count"])
			{
				for (int i = 0; i < [[dict objectForKey:@"count"] intValue]; i++)
				{
					NSString* obj = [dict objectForKey:FORMAT_STRING(@"stateId%i", i)];
					if(obj && [obj isEqualToString:FORMAT_STRING(@"%i", rc.user.stateId)])				
					{
						statePoints = [[dict objectForKey:FORMAT_STRING(@"points%i",i)] intValue];
					}				
				}
			}
			TextScores* stateScores = [TextScores createWithFont:font_pause_menu points:statePoints prefix:@""];
			stateScores->passColorToChilds = FALSE;
			stateScores->color = bestScoreColor;
			stateScores->x = teamScoreOffset;
			[stateScores setName:@"stateScores"];
			[winBox addChild:stateScores];
			stateScores->parentAnchor = stateScores->anchor = TOP | LEFT;
			BaseElement* flag = [MenuController createStateFlag:sId];
			if(flag)
			{
				flag->parentAnchor = LEFT | VCENTER;
				flag->anchor = RIGHT | VCENTER;
				flag->x = -10;
				[stateScores addChild:flag];
			}
		}
	}
#endif
	
	TextScores* winScore = [TextScores createWithFont:[ChampionsResourceMgr getResource:FNT_POINTS_FONT] points:0 prefix:@""];
	winScore->height -= 10;
	[winBox addChild:winScore];
//	winScore->anchor = CENTER;
//	winScore->parentAnchor = TOP | HCENTER;
//	winScore->y = 80.0;
	[winScore setName:@"winScore"];
	
//	Button* menuWin = [MenuController createButtonWithText:LocalizedString(@"STR_MENU_MAIN_MENU", @"Main Menu") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_PAUSE_EXIT Delegate:self color:grayColor];
//	[winBox addChild:menuWin];
	
//	Button* restartWin = [MenuController createButtonWithText:LocalizedString(@"STR_MENU_RESTART", @"Play Again") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_WIN_RESTART Delegate:self color:grayColor];
//	[winBox addChild:restartWin];
	
	TextScores* bonusesAnimation = [TextScores createWithFont:font_pause_menu points:0 prefix:LocalizedString(@"STR_STAR_BONUS", @"Star bonus: ")];
	[bonusesAnimation setName:@"bonusesAnimation"];
	bonusesAnimation->color = bestScoreColor;
	[winBox addChild:bonusesAnimation];
	bonusesAnimation->x = 48;
	bonusesAnimation->anchor = bonusesAnimation->parentAnchor = TOP | LEFT;
	
	HBox* lights = [[HBox allocAndAutorelease] initWithOffset:0.5 Align:VCENTER Height:10];
	[lights setName:@"lights"];
//	lights->parentAnchor = lights->anchor = BOTTOM | RIGHT;
	for(int i = 0; i < 10; i++)
	{
		Image* light = [Image createWithResID:IMG_COOL_BAR];
		[light setDrawQuad:1];
		[lights addChild:light];
	}
	[winBox addChild:lights];
	
	Text* best_score = [Text createWithFont:font_pause_menu andString:FORMAT_STRING(LocalizedString(@"STR_BEST_SCORE", @"Best score: %@"), bestScore)];
	best_score->color = grayColor;
	best_score->scaleX = best_score->scaleY = 0.75;
	[winBox addChild:best_score];
	
	Button* nextWin = [MenuController createButtonWithText:LocalizedString(@"STR_MENU_WIN_CONTINUE", @"Continue") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_WIN_CONTINUE Delegate:self color:grayColor];
	[winBox addChild:nextWin];
	
	[winMenu addChild:winBox];
	
	VBox* winBox2 = [[[VBox alloc] initWithOffset:10 Align:HCENTER Width:winMenu->width] autorelease];
	winBox2->parentAnchor = CENTER;
	winBox2->anchor = TOP | HCENTER;
	winBox2->y = -55;
	[winBox2 setName:@"winBox2"];
	[winBox2 setEnabled:FALSE];
	
	if (tutorialLevel == UNDEFINED)
	{
		Button* menuWin2 = [MenuController createButtonWithText:LocalizedString(@"STR_MENU_MAIN_MENU", @"Main Menu") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_PAUSE_EXIT Delegate:self color:grayColor];
		[winBox2 addChild:menuWin2];
	}
	else
	{
		Font* font = [ChampionsResourceMgr getResource:FNT_PAUSE_MENU_BIG_FONT]; 
		Text* tn = [[Text allocAndAutorelease] initWithFont:font];
		tn->color = grayColor;
		NSString* str = LocalizedString(@"STR_MENU_MAIN_MENU", @"Main Menu");
		[tn setString:str];
		[winBox2 addChild:tn];
		tn->passColorToChilds = FALSE;
		
		Image* ts = [Image createWithResID:IMG_PAUSE_NON_ACTIVE_MENU_01];
		ts->anchor = ts->parentAnchor = CENTER;
		ts->rotation = 4.0;
		[tn addChild:ts];
		
	}

	Button* restartWin2 = [MenuController createButtonWithText:LocalizedString(@"STR_MENU_RESTART", @"Play Again") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_WIN_RESTART Delegate:self color:grayColor];
	[winBox2 addChild:restartWin2];

	Button* nextWin2 = [MenuController createButtonWithText:LocalizedString(@"STR_MENU_NEXT_LEVEL", @"Next Level") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_NEXT Delegate:self color:grayColor];
	[winBox2 addChild:nextWin2];

	[winMenu addChild:winBox2];
	[view addChild:winMenu withID:VIEW_ELEMENT_WIN_MENU];
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark lose menu
	Image* loseMenu = [Image createWithResID:IMG_WIN_TRYAGAIN_BACK];
	loseMenu->anchor = CENTER;
	loseMenu->x = SCREEN_WIDTH / 2;
	loseMenu->y = SCREEN_HEIGHT / 2;
	
	Image* loseTitle = [Image createWithResID:IMG_TRY_AGAIN];
	loseTitle->parentAnchor = loseTitle->anchor = TOP | HCENTER;
	loseTitle->y = 20;
	[loseMenu addChild:loseTitle];
	
	VBox* vbox = [[[VBox alloc] initWithOffset:10 Align:HCENTER Width:loseMenu->width] autorelease];
	vbox->parentAnchor = vbox->anchor = CENTER;
	
	Button* menuLose = [MenuController createButtonWithText:LocalizedString(@"STR_MENU_MAIN_MENU", @"Main Menu") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_PAUSE_EXIT Delegate:self color:grayColor];
	[vbox addChild:menuLose];
	
	Button* restartLose = [MenuController createButtonWithText:LocalizedString(@"STR_MENU_RESTART", @"Play Again") fontID:FNT_PAUSE_MENU_BIG_FONT ID:BUTTON_LOSE_RESTART Delegate:self color:grayColor];
	[vbox addChild:restartLose];
	
	[loseMenu addChild:vbox];	
	[view addChild:loseMenu withID:VIEW_ELEMENT_LOSE_MENU];
	
#pragma mark win particles
	AnimationsPool* particlesContainer = [[[AnimationsPool alloc] init] autorelease];
	particlesContainer->anchor = particlesContainer->parentAnchor = TOP | LEFT;
	[view addChild:particlesContainer withID:VIEW_PARTICLES_CONTAINER];
	
	int totalParticles = 400;
	Image* ig = [Image createWithResID:IMG_STARS_PARTICLES];
	GLFireworks* gb = [[[GLFireworks alloc] initWithTotalParticles:totalParticles andImageGrid:ig] autorelease];
	gb->anchor = gb->parentAnchor = TOP | LEFT;
	gb->x = SCREEN_WIDTH/2;
	gb->y = SCREEN_HEIGHT;
	gb->size = 1.2;
	gb->sizeVar = 0.2;
	gb->gravity = vect(0, 20);
	gb->speed = 150;
	gb->angle = 270;
	gb->angleVar = 50;
	gb->life = 3.0;
	gb->emissionRate = totalParticles/gb->life;
	gb->posVar = vect(SCREEN_WIDTH/2, 0);
	gb->startColor = (RGBAColor)RGBA_FROM_HEX(0, 0, 0, 255);
	gb->startColorVar = (RGBAColor)RGBA_FROM_HEX(255, 0, 255, 0);
	gb->endColor = (RGBAColor)RGBA_FROM_HEX(0, 0, 0, 255);
	gb->endColorVar = (RGBAColor)RGBA_FROM_HEX(255, 0, 255, 0);
	[gb startSystem:0];
	[particlesContainer addChild:gb];
	[particlesContainer setEnabled:FALSE];
	[self addView:view withID:VIEW_GAME];
	
#ifdef MAP_PICKER
#ifndef AMAZON
	[self addMapNameInfo];
#endif
#endif
	
}

-(void)unpauseMusic
{
	[ChampionsSoundMgr unpauseMusic];
}
-(void)gameWon
{
	if(GAME_RESULT_PAUSED == game_state)		
		[self closePauseMenu];
		
	if(GAME_RESULT_NONE == game_state)
	{
		if (ReviewRequest::PlayerWonCheckIfShouldReview())
		{
			ReviewRequest::AskForReview();
		}		
		
		ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
		int tutorialLevel = rc.user.tutorialLevel;	
		if (tutorialLevel != UNDEFINED)
		{			
			tutorialLevel++;
			
			rc.user.tutorialLevel = tutorialLevel;
			
			if (tutorialLevel == 15)
			{
				[GameController unlockAchievement:AC_Tutorial];
			}
		}
		else
		{			
			[GameController unlockAchievement:AC_Welcome];			
		}		
		
		game_state = GAME_RESULT_WIN;
//		[ChampionsSoundMgr pauseMusic];
		[ChampionsSoundMgr playSound:SND_WIN];
//		soundResumeTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(unpauseMusic) userInfo:nil repeats:FALSE];
		[self showPopup:VIEW_ELEMENT_WIN_MENU];
		rc.user.lastPlayedMap = [rc nextLevel:rc.selectedMap];		
	}	
}

-(void)gameLost
{
	if(GAME_RESULT_PAUSED == game_state)		
		[self closePauseMenu];
	
	if(GAME_RESULT_NONE == game_state)
	{
		[self stopTimer];
		game_state = GAME_RESULT_LOSE;
//		[ChampionsSoundMgr pauseMusic];
		[ChampionsSoundMgr playSound:SND_LOSE];
//		soundResumeTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(unpauseMusic) userInfo:nil repeats:FALSE];

		[self showPopup:VIEW_ELEMENT_LOSE_MENU];
	}
}

-(void)showPauseMenu
{
	ASSERT(game_state != GAME_RESULT_PAUSED);
	[self stopTimer];
	[self showPopup:VIEW_ELEMENT_PAUSE_MENU];
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	int tutorialLevel = rc.user.tutorialLevel;	
    int hintIndex = (tutorialLevel != UNDEFINED) ? 
                    RND_RANGE(STR_HINTS_REDNECK_HINT_01, STR_HINTS_REDNECK_HINT_02) : 
                    RND_RANGE(STR_HINTS_SERGEANT_HINT_01, STR_HINTS_SERGEANT_HINT_07);
    
	[Baloon showBaloonWithID:0 Text:HINTS[hintIndex]
					   Image:[Image createWithResID:IMG_PERSONAGES Quad:(tutorialLevel != UNDEFINED) ? IMG_PERSONAGES_dude01 : IMG_PERSONAGES_dude02] Blocking:FALSE Type:BALOON_STATIC inView:[self getView:VIEW_GAME]
					Delegate:nil];
}

-(void)closePauseMenu
{
	ASSERT(game_state == GAME_RESULT_PAUSED);
	View* v = [self getView:VIEW_GAME];		
	[Baloon hideBaloonInView:v];
	[self hidePopup];				
}

-(void)onButtonPressed:(int)n
{
	[ChampionsSoundMgr playSound:SND_TAP];	
	switch (n)
	{
		case BUTTON_SPLASH_CANCEL:
		{
			[self showView:VIEW_GAME];
			break;
		}
		case BUTTON_WIN_CONTINUE:
		{
			View* view = [self getView:VIEW_GAME];
			BaseElement* winMenu = [view getChild:VIEW_ELEMENT_WIN_MENU];
			BaseElement* winBox = [winMenu getChildWithName:@"winBox"];
			BaseElement* winBox2 = [winMenu getChildWithName:@"winBox2"];
			[winBox setEnabled:FALSE];
			[winBox2 setEnabled:TRUE];
			break;
		}
			
		case BUTTON_PAUSE_RESUME:
		{
			[self closePauseMenu];
			break;
		}
			
		case BUTTON_PAUSE_EXIT:
			exitCode = EXIT_CODE_FROM_PAUSE_MENU;
			//			[ChampionsSoundMgr stopAll];
			[self deactivate];
			break;
			
		case BUTTON_PAUSE_SELECT_LEVEL:
			exitCode = SELECT_LEVEL_PAUSE_MENU;
			//			[ChampionsSoundMgr stopAll];
			[self deactivate];
			break;			
#ifdef CHEAT	
		case BUTTON_PAUSE_CHEAT:
		{
			View* v = [self getView:VIEW_GAME];	
			if(v)
			{
				GameScene* gs = (GameScene*)[v getChild:VIEW_ELEMENT_GAME_SCENE];
				if(gs)
				{
					[self hidePopup];
					[Baloon hideBaloonInView:v];					
					[gs cheatWinGame];
				}
			}
			break;
		}
#endif			
		case BUTTON_PAUSE_SOUND_ONOFF:
		{
			ChampionsPreferences* p = (ChampionsPreferences*)[Application sharedPreferences];
			bool soundOn = [p getBooleanForKey:(NSString*)PREFS_SOUND_ON];
			[p setBoolean:!soundOn forKey:(NSString*)PREFS_SOUND_ON];
			break;
		}
			
		case BUTTON_PAUSE_MUSIC_ONOFF:
		{
			ChampionsPreferences* p = (ChampionsPreferences*)[Application sharedPreferences];
			bool musicOn = [p getBooleanForKey:(NSString*)PREFS_MUSIC_ON];
			[p setBoolean:!musicOn forKey:(NSString*)PREFS_MUSIC_ON];
			if (musicOn)
			{
				[ChampionsSoundMgr stopMusic];
			}
			else
			{
				[ChampionsSoundMgr playMusic:SND_INGAME_THEME1];
			}
			break;
		}				
			
		case BUTTON_PAUSE:
		{
			[self showPauseMenu];
			break;
		}
			
		case BUTTON_OPTIONS_BACK:
			[self hidePopup];
			[self showPopup:VIEW_ELEMENT_PAUSE_MENU];
			break;			
			
		case BUTTON_PAUSE_OPTIONS:
			[self hidePopup];
			[self showPopup:VIEW_ELEMENT_OPTIONS];
			break;			
			
		case BUTTON_WIN_RESTART:
		{
			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			int tutorialLevel = rc.user.tutorialLevel;	
			if (tutorialLevel != UNDEFINED)			
			{
				rc.user.tutorialLevel--;
			}
		}
			
		case BUTTON_LOSE_RESTART:
		case BUTTON_RESTART:
		{			
			View* v = [self getView:VIEW_GAME];	
			if(v)
			{								
				GameScene* gs = (GameScene*)[v getChild:VIEW_ELEMENT_GAME_SCENE];
				if(gs)
				{
					[gs hide];
					[gs show];
//					[self hidePopup];			
					exitCode = RESTART_CODE_FROM_PAUSE_MENU;
					gs->updateable = FALSE;
					gs->touchable = FALSE;
					[self deactivate];
				}
			}
			
			break;
		}
			
		case BUTTON_NEXT:
		{			
			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			int tutorialLevel = rc.user.tutorialLevel;	
			if (tutorialLevel >= TUTORIAL_LEVELS_COUNT)
			{
				exitCode = EXIT_CODE_FROM_PAUSE_MENU;				
				[self deactivate];
				break;
			}				
			
			View* v = [self getView:VIEW_GAME];	
			if(v)
			{
				GameScene* gs = (GameScene*)[v getChild:VIEW_ELEMENT_GAME_SCENE];
				if(gs)
				{
					[gs hide];
					[gs show];
//					[self hidePopup];			
					exitCode = NEXT_LEVEL_CODE;
					gs->updateable = FALSE;
					gs->touchable = FALSE;
					[self deactivate];
				}
			}
			break;
		}
			
		default:
			ASSERT(FALSE);			
	}
}

-(void)hidePopup
{
	View* v = [self getView:VIEW_GAME];
	
	[[v getChild:VIEW_ELEMENT_PAUSE_MENU] setEnabled:FALSE];	
	[[v getChild:VIEW_ELEMENT_WIN_MENU] setEnabled:FALSE];	
	[[v getChild:VIEW_ELEMENT_LOSE_MENU] setEnabled:FALSE];	
	[[v getChild:VIEW_ELEMENT_OPTIONS] setEnabled:FALSE];			
	
	game_state = GAME_RESULT_NONE;// = FALSE;
	//	[ChampionsSoundMgr unpause];	
	
	[[v getChild:VIEW_ELEMENT_PAUSE_BUTTON] setEnabled:TRUE];	
	[[v getChild:VIEW_ELEMENT_CAMERA] setEnabled:showCameraUI];
	[v getChild:VIEW_ELEMENT_GAME_SCENE]->touchable = TRUE;	
	[v getChild:VIEW_ELEMENT_GAME_SCENE]->updateable = TRUE;	
	
	popupShown = FALSE;
}

-(void)showPopup:(int)p
{
	View* v = [self getView:VIEW_GAME];
	popupShown = TRUE;
	
	switch (p)
	{			
		case VIEW_ELEMENT_PAUSE_MENU:
		{
			[[v getChild:VIEW_ELEMENT_PAUSE_MENU] setEnabled:TRUE];
			game_state = GAME_RESULT_PAUSED;
			break;
		}
			
		case VIEW_ELEMENT_OPTIONS:
			[[v getChild:VIEW_ELEMENT_OPTIONS] setEnabled:TRUE];	
			game_state = GAME_RESULT_PAUSED;
			break;			
			
		case VIEW_ELEMENT_WIN_MENU:
		{
			[[v getChild:VIEW_ELEMENT_WIN_MENU] setEnabled:TRUE];	
			[[v getChild:VIEW_PARTICLES_CONTAINER] setEnabled:TRUE];
			break;
		}	
		case VIEW_ELEMENT_LOSE_MENU:
			[[v getChild:VIEW_ELEMENT_LOSE_MENU] setEnabled:TRUE];				
			break;
			
			
		default:			
			ASSERT(FALSE);
			break;
	}
	

	//	[ChampionsSoundMgr pause];
	
	[[v getChild:VIEW_ELEMENT_PAUSE_BUTTON] setEnabled:FALSE];
	[[v getChild:VIEW_ELEMENT_CAMERA] setEnabled:FALSE];	
	[v getChild:VIEW_ELEMENT_GAME_SCENE]->touchable = FALSE;	
	[v getChild:VIEW_ELEMENT_GAME_SCENE]->updateable = FALSE;						
}

-(void)dealloc
{
	[mapParser release];
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	[mapParser parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[mapParser parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
	
	if ([elementName isEqualToString:@"library"])
	{
		
#ifndef MAP_PICKER		
		NSString* path = [[NSBundle mainBundle] pathForResource:selectedMap ofType:@""];
		NSData* data = [[[NSData alloc] initWithContentsOfFile:path] autorelease];
		
		XMLParser* parser = [[[XMLParser alloc] init] autorelease];
		[parser setDelegate:self];
		[parser parseData:data];
#else
		XMLSaxLoader* loader = [[[XMLSaxLoader alloc] init] autorelease];
		[loader turnOnCache];
		loader.delegate = self;
#ifdef AMAZON
		NSString* url = FORMAT_STRING(@"http://fpchampions.s3.amazonaws.com/levels/%@", selectedMap);
#else
		//		NSString* url = FORMAT_STRING(@"http://model.reaxion.com/incoming/fpc/%@", selectedMap);
		NSString* url = FORMAT_STRING(@"http://reaxion.com/fpchampions/%@", selectedMap);
#endif
//		NSLog(@"%@", url);
		[loader load:url];
#endif		
	}
	
	if ([elementName isEqualToString:@"level"])
	{
		[mapParser sortQueuedObjects];
		[self createGameView];
		[self hidePopup];
		GameView* view = (GameView*)[self getView:VIEW_GAME];
		GameScene* sc = (GameScene*)[view getChild:VIEW_ELEMENT_GAME_SCENE];
		sc.mapParser = mapParser;
		[sc initPhysics];
#ifdef FREE
		ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
		if(rc && [rc allLevelsCompleted])
			[self showView:VIEW_BUY_FULL];
		else
			[self showView:VIEW_GAME];	
#else
		[self showView:VIEW_GAME];
#endif
	}
}

-(void)addMapNameInfo
{
	BOOL showMapName = TRUE;
	if(showMapName)
	{
		Font* small_font = [ChampionsResourceMgr getResource:FNT_FONTS_001];
		Text* mapName = [[[Text alloc] initWithFont:small_font] autorelease];
		mapName->color = whiteRGBA;
		float swidth = MIN([small_font stringWidth:selectedMap], SCREEN_WIDTH - 50);
		[mapName setString:selectedMap andWidth:swidth];
		mapName->parentAnchor = mapName->anchor = CENTER;
		
		int w = mapName->width+10;
		int h = mapName->height; 
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
		
		CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.8f);
		CGRect size = {0, 0, w, h};
		CGContextFillRect(context, size);
		CGImageRef imageMasked = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		
		Texture2D* mapNameBackground = [[[Texture2D alloc] initWithImage:[UIImage imageWithCGImage:imageMasked]] autorelease];
		Image* backImage = [Image create:mapNameBackground];
		backImage->parentAnchor = backImage->anchor = LEFT | BOTTOM;
		
		[backImage addChild:mapName];
		
		GameView* view = (GameView*)[self getView:VIEW_GAME];
		[view addChild:backImage withID:VIEW_MAP_NAME];
	}
}

-(void)timeline:(Timeline*)t reachedKeyFrame:(KeyFrame*)k withIndex:(int)i
{
	if(RGBAEqual(k->value.color.rgba, three_color))
	{
		[digits setEnabled:TRUE];
		[digits setDrawQuad:2];
	}
	
	if(RGBAEqual(k->value.color.rgba, two_color))
	{
		[digits setDrawQuad:3];
	}
	
	if(RGBAEqual(k->value.color.rgba, one_color))
	{
		[digits setDrawQuad:4];
	}
	
	if(RGBAEqual(k->value.color.rgba, transparentRGBA))
	{
		[digits setEnabled:FALSE];
	}
}

-(void)timelineFinished:(Timeline*)t
{
	GameView* view = (GameView*)[self getView:VIEW_GAME];
	if(view)
	{
		GameScene* sc = (GameScene*)[view getChild:VIEW_ELEMENT_GAME_SCENE];
		if(sc)
		{
			[sc timerFinished];
		}
	}
}

-(void)startTimer
{
	if (timer_state == TIMER_STOPPED)
	{
		timer_state = TIMER_TICKING;
		GameView* view = (GameView*)[self getView:VIEW_GAME];
		BaseElement* timer = [view getChild:VIEW_ELEMENT_TIMER];
		if(timer)
		{		
			[timer setEnabled:TRUE];
			BaseElement* camera = [view getChild:VIEW_ELEMENT_CAMERA];
			[camera setEnabled:FALSE];
			[timer playTimeline:0];
			
			BaseElement* timer_back = [timer getChild:0];
			[timer_back playTimeline:0];
			[timer_back setEnabled:TRUE];
			
			BaseElement* timer_front = [timer getChild:1];
			[timer_front setEnabled:TRUE];
		}
	}
}

-(void)stopTimer
{
	if (timer_state == TIMER_TICKING)
	{
		timer_state = TIMER_STOPPED;
		GameView* view = (GameView*)[self getView:VIEW_GAME];
		BaseElement* timer = [view getChild:VIEW_ELEMENT_TIMER];
		if(timer)
		{
			BaseElement* camera = [view getChild:VIEW_ELEMENT_CAMERA];
			BaseElement* timer_back = [timer getChild:0];
			BaseElement* timer_front = [timer getChild:1];
			[timer stopCurrentTimeline];
			[timer_back stopCurrentTimeline];
			[timer setEnabled:FALSE];
			[timer_back setEnabled:FALSE];
			[timer_front setEnabled:FALSE];
			[camera setEnabled:showCameraUI];
			[digits setEnabled:FALSE];
		}
	}
}

-(void)nextLevel
{
}

- (bool)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(GAME_RESULT_WIN == game_state)
	{
		GameView* view = (GameView*)[self getView:VIEW_GAME];
		Image* menu = (Image*)[view getChild:VIEW_ELEMENT_WIN_MENU];
		BaseElement* winBox = [menu getChildWithName:@"winBox"];
		TextScores* winScore = (TextScores*)[winBox getChildWithName:@"winScore"];
		TextScores* bonusesAnimation = (TextScores*)[winBox getChildWithName:@"bonusesAnimation"];
		TextScores* countryScores = (TextScores*)[winBox getChildWithName:@"countryScores"];
		TextScores* stateScores = (TextScores*)[winBox getChildWithName:@"stateScores"];
		if(countryScores)
			[countryScores stop];
		if(stateScores)
			[stateScores stop];
		[winScore stop];
		[bonusesAnimation stop];
	}
	return [super touchesEnded:touches withEvent:event];
}
@end
