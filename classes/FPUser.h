//
//  FPUser.h
//  champions
//
//  Created by ikoryakin on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "FPScores.h"

enum {WAS_IN_MAIN_MENU = 1, WAS_IN_REGISTRATION = 2, WAS_IN_STATISTICS = 4, WAS_IN_OPTIONS = 8, 
	  WAS_IN_LEVEL_SELECT = 16};

@interface FPUser : NSObject <NSCoding, ASIHTTPRequestDelegate>
{
	NSString* userId;
	NSString* feintId;
	NSString* udId;
	NSString* name;
	int countryId;
	int stateId;
	NSString* region;
	BOOL online;
	BOOL registered;
	BOOL clearBlob;
	NSString* email;
	NSMutableDictionary* levelsProgress;
	int tutorialLevel;
	NSString* lastPlayedMap;
	
	// achievement variables
	/////////////////////////////////////////////////////////////////////////////////
	int explodedBlocks;
	int connectedMagnets;
	int brokenBlocks;
	int collectedStars;
	int bumperStrikes;
	int blocksStacked;
	int levelsWoninARow;
	int menusVisited;
	int ownHighscoreBeatenCount;
	int ownBestTimeBeatenCount;
}

-(void)setDefaults;
-(void)updateGameProgress:(FPUser*)user;
-(void)updateUserRegistration:(BOOL)synchronously;
-(void)addScore:(int)score bumperMultiplier:(float)m starBonuses:(int)s totalBonuses:(int)ts time:(int)time forMap:(NSString*)mapName;
-(void)topAll:(id)delegate;
-(void)topStates:(id)delegate;
-(void)states:(id)delegate;
-(void)clearData;
-(void)countries:(id)delegate;
-(void)print;
-(void)scores;
-(void)setScores:(FPScores*)scores forMap:(NSString*)mapName;
-(FPScores*)getScoresForMap:(NSString*)mapName;
-(void)saveGameProgress;

// achievement helper
-(int)getNumberOfExpertLevels;

@property (nonatomic, retain) NSString *userId, *feintId, *udId, *name, *region, *email;
@property (retain) NSDictionary *levelsProgress;
@property (assign) BOOL online, registered, clearBlob;
@property (assign) int countryId, stateId;
@property (assign) int tutorialLevel;
@property (retain) NSString* lastPlayedMap;

@property (assign) int explodedBlocks, connectedMagnets, brokenBlocks, collectedStars, bumperStrikes, blocksStacked, 
levelsWoninARow, menusVisited, ownHighscoreBeatenCount, ownBestTimeBeatenCount;

@end