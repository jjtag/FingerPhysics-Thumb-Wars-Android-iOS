//
//  GameController.h
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "GameView.h"
#import "GameScene.h"
#import "Framework.h"
#import "Joystick.h"

enum {VIEW_GAME, VIEW_BUY_FULL};
enum {BUTTON_PAUSE_RESUME, BUTTON_PAUSE_EXIT, BUTTON_PAUSE, BUTTON_WIN_RESTART, BUTTON_LOSE_RESTART,
	BUTTON_RESTART, BUTTON_NEXT, BUTTON_SKIP, BUTTON_PAUSE_OPTIONS, BUTTON_PAUSE_SELECT_LEVEL, BUTTON_PAUSE_CHEAT, BUTTON_OPTIONS_BACK,
	BUTTON_PAUSE_MUSIC_ONOFF, BUTTON_PAUSE_SOUND_ONOFF, BUTTON_WIN_CONTINUE, BUTTON_SPLASH_BUY, BUTTON_SPLASH_CANCEL};
enum {EXIT_CODE_FROM_PAUSE_MENU, RESTART_CODE_FROM_PAUSE_MENU, NEXT_LEVEL_CODE, SKIP_LEVEL_CODE, SELECT_LEVEL_PAUSE_MENU};

typedef enum
{
	TIMER_STOPPED = 0,
	TIMER_TICKING,
} TimerState;

typedef enum
{
	GAME_RESULT_NONE = 0,
	GAME_RESULT_WIN,
	GAME_RESULT_LOSE,
	GAME_RESULT_PAUSED,
} GameState;

@interface GameController : ViewController <GameSceneDelegate, ButtonDelegate, TimelineDelegate>
{		
//	bool isGamePaused;
	NSString* selectedMap;
	MapParser* mapParser;
	BOOL showCameraUI;
	//timer
	Image* digits;
	TimerState timer_state;
//	NSTimer* soundResumeTimer;
@public
	GameState game_state;
	int exitCode;
	bool popupShown;
//	Joystick* joystick;
}

+(void)unlockAchievement:(int)ac;

-(void)createGameView;
-(void)loadMap;

-(void)showPopup:(int)p;
-(void)hidePopup;
-(void)closePauseMenu;
-(void)showPauseMenu;

-(void)addMapNameInfo;

-(Button*)createPauseButton:(int)image withID:(int)bid;

@property (retain) NSString* selectedMap;
@end
