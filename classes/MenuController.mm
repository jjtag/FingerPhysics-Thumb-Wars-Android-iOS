//
//  MenuController.m
//  blockit
//
//  Created by Mac on 02.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MenuController.h"
#import "MenuView.h"
#import "ChampionsRootController.h"
#import "ChampionsResourceMgr.h"
#import "ChampionsSoundMgr.h"
#import "Framework.h"
#import "ChampionsPreferences.h"
#import "AlternateImage.h"
#import "ColoredLayer.h"
#import "GameController.h"
#import "FlurryAPI.h"
#import "FPBanner.h"

const int STATES_COUNT = sizeof(states) / sizeof(StateProperties);
const int COUNTRIES_COUNT = sizeof(countries) / sizeof(CountryProperties);
const int EU_COUNT = sizeof(eu) / sizeof(int);

const int TOP_ALL = 1;
const int TOP_NATIONAL = 2;
const int TOP_WORLD = 4;
const int TOPS_DOWNLOADED = TOP_ALL | TOP_NATIONAL | TOP_WORLD;

const RGBAColor grayColor = RGBA_FROM_HEX(180, 179, 175, 255);
const RGBAColor darkGrayColor = RGBA_FROM_HEX(64, 64, 64, 255);
const RGBAColor darkBlueColor = RGBA_FROM_HEX(14, 60, 135, 255);	
const RGBAColor lightGrayColor = RGBA_FROM_HEX(224, 220, 213, 255);
const RGBAColor lightBlueColor = RGBA_FROM_HEX(143, 165, 195, 255);
const RGBAColor dirtRedColor = RGBA_FROM_HEX(222, 77, 85, 255);
const RGBAColor scoresDarkGrayColor = RGBA_FROM_HEX(197, 197, 197, 255);
const RGBAColor scoresLightGrayColor = RGBA_FROM_HEX(220, 220, 220, 255);
const RGBAColor titleDarkGrayColor = RGBA_FROM_HEX(121, 121, 121, 255);
const RGBAColor scrollerColor = RGBA_FROM_HEX(101, 128, 165, 255);
const RGBAColor optionsGrayColor = RGBA_FROM_HEX(91, 90, 90, 255);
const RGBAColor optionsBlueColor = RGBA_FROM_HEX(4, 60, 135, 255);
const RGBAColor selectorGreenColor = RGBA_FROM_HEX(91, 184, 28, 255);
const RGBAColor selectorRedColor = RGBA_FROM_HEX(162, 54, 18, 255);

enum { BALOON_REGISTRATION_01, BALOON_REGISTRATION_02, BALOON_NEWS };

@implementation MenuController

@synthesize mapsList;

+(Button*)createButtonWithTextureUp:(Texture2D*)up Down:(Texture2D*)down ID:(int)bID scaleRatio:(float)scaleRatio
{
	Image* gUp = [Image create:up];
	Image* gDown = [Image create:down];
	gDown->scaleX = gDown->scaleY = scaleRatio;
	return [[[Button alloc] initWithUpElement:gUp DownElement:gDown andID:bID] autorelease];
}

+(Button*)createButtonWithText:(NSString*)str fontID:(int)fontID ID:(int)bid Delegate:(id)d color:(RGBAColor)color
{
	Font* font = [ChampionsResourceMgr getResource:fontID]; 
	Text* tn = [[Text allocAndAutorelease] initWithFont:font];
	tn->color = color;
	[tn setString:str];

	Text* tp = [[Text allocAndAutorelease] initWithFont:font];
	[tp setString:str];
	tp->scaleX = 1.2;
	tp->scaleY = 1.2;
	tp->color = color;
	
	Button* b = [[Button allocAndAutorelease] initWithUpElement:tn DownElement:tp andID:bid];	
	[b setTouchIncreaseLeft:10.0 Right:10.0 Top:10.0 Bottom:10.0];
	b.delegate = d;
	
	return b;
}

+(Button*)createButtonWithBackTexture:(int)t text:(NSString*)str textAngle:(float)angle  textX:(float)tx textY:(float)ty font:(int)fontId buttonId:(int)bId
{
	Font* font = [ChampionsResourceMgr getResource:fontId];

	Text* tn = [[Text allocAndAutorelease] initWithFont:font];
	tn->anchor = tn->parentAnchor = VCENTER | LEFT;
	tn->color = blackRGBA;
	tn->rotation = angle;
	tn->x = tx;
	tn->y = ty;
	[tn setString:str];
	
	Text* tp = [[Text allocAndAutorelease] initWithFont:font];
	tp->anchor = tp->parentAnchor = VCENTER | LEFT;
	tp->color = blackRGBA;
	tp->rotation = angle;
	tp->x = tx;
	tp->y = ty;
	[tp setString:str];
	
	Image* back = [Image createWithResID:t];
	Image* backPressed = [Image createWithResID:t];
	backPressed->scaleX = backPressed->scaleY = 1.2;
	[back addChild:tn];
	[backPressed addChild:tp];
	
	return [[Button allocAndAutorelease] initWithUpElement:back DownElement:backPressed andID:bId];	
}

+(ToggleButton*)createToggleButtonWithBack:(int)tback toggleFront:(int)tfront Text:(NSString*)text ID:(int)bid Delegate:(id)d
{
	Font* font = [ChampionsResourceMgr getResource:FNT_FONTS_001];
	float textWidth = [font stringWidth:text];
	
	Text* tnt = [[Text allocAndAutorelease] initWithFont:font];
	tnt->color = optionsBlueColor;
	tnt->parentAnchor = tnt->anchor = CENTER;
	[tnt setString:text];

	Text* tpt = [[Text allocAndAutorelease] initWithFont:font];
	tpt->color = optionsBlueColor;
	tpt->parentAnchor = tpt->anchor = CENTER;
	[tpt setString:text andWidth:textWidth];
	
	Text* tnt2 = [[Text allocAndAutorelease] initWithFont:font];
	tnt2->color = optionsGrayColor;
	tnt2->parentAnchor = tnt2->anchor = CENTER;
	[tnt2 setString:text andWidth:textWidth];
	
	Text* tpt2 = [[Text allocAndAutorelease] initWithFont:font];
	tpt2->color = optionsGrayColor;
	tpt2->parentAnchor = tpt2->anchor = CENTER;
	[tpt2 setString:text andWidth:textWidth];
	
	Image* tn = [Image createWithResID:tback];
	Image* tp = [Image createWithResID:tback];
	tp->scaleX = tp->scaleY = 1.2;
	[tn addChild:tnt];
	[tp addChild:tpt];
	
	Image* tn2 = [Image createWithResID:tback];
	Image* tp2 = [Image createWithResID:tback];	
	tp2->scaleX = tp2->scaleY = 1.2;
	[tn2 addChild:tnt2];
	[tp2 addChild:tpt2];
	
	Image* toggleFront = [Image createWithResID:tfront];
	Image* toggleFront2 = [Image createWithResID:tfront];
	toggleFront->parentAnchor = toggleFront->anchor = toggleFront2->parentAnchor = toggleFront2->anchor = CENTER;
	[tn2 addChild:toggleFront];
	[tp2 addChild:toggleFront2];
	
	ToggleButton* b = [[ToggleButton allocAndAutorelease] initWithUpElement1:tn DownElement1:tp
																  UpElement2:tn2 DownElement2:tp2 andID:bid];	
	b->rotationCenterX = -b->width/2;
//	[b setTouchIncreaseLeft:10.0 Right:10.0 Top:10.0 Bottom:10.0];
	b.delegate = d;
	return b;
	
}

+(ToggleButton*)createToggleButtonWithText1:(NSString*)str1 Text2:(NSString*)str2 ID:(int)bid Delegate:(id)d
{
	Font* font = [ChampionsResourceMgr getResource:FNT_FONTS_002];
	Text* tn = [[Text allocAndAutorelease] initWithFont:font];
	tn->color = blackRGBA;
	[tn setString:str1];
	
	Text* tp = [[Text allocAndAutorelease] initWithFont:font];
	[tp setString:str1];
	tp->scaleX = 1.2;
	tp->scaleY = 1.2;
	tp->color = blackRGBA;
	
	Text* tn2 = [[Text allocAndAutorelease] initWithFont:font];
	tn2->color = blackRGBA;
	[tn2 setString:str2];
	
	Text* tp2 = [[Text allocAndAutorelease] initWithFont:font];
	tp2->color = blackRGBA;
	[tp2 setString:str2];
	tp2->scaleX = 1.2;
	tp2->scaleY = 1.2;
		
	ToggleButton* b = [[ToggleButton allocAndAutorelease] initWithUpElement1:tn DownElement1:tp
	    												  UpElement2:tn2 DownElement2:tp2 andID:bid];	
	[b setTouchIncreaseLeft:10.0 Right:10.0 Top:10.0 Bottom:10.0];
	b.delegate = d;
	
	return b;	
}

//+(Button*)createBackButtonWithDelegate:(id)d
//{
//	Button* backb = [MenuController createButtonWithImage:IMG_BACK_ARROW ID:BUTTON_BACK_TO_MAIN_MENU Delegate:d];
//	backb->anchor = backb->parentAnchor = LEFT | BOTTOM;
//	backb->x = 20.0;
//	backb->y = -20.0;
//	
//	return backb;	
//}

+(Button*)createButtonWithImage:(int)resID ID:(int)bid Delegate:(id)d
{
	Texture2D* t = [ChampionsResourceMgr getResource:resID];
	Image* tn = [Image create:t];
	Image* tp = [Image create:t];
	tp->scaleX = 1.2;
	tp->scaleY = 1.2;
	
	Button* b = [[Button allocAndAutorelease] initWithUpElement:tn DownElement:tp andID:bid];
	[b setTouchIncreaseLeft:10.0 Right:10.0 Top:10.0 Bottom:10.0];
	b.delegate = d;
	
	return b;
}

+(AlternateImage*)createLabel:(NSString*)str font:(NSString*)font color:(RGBAColor)c width:(float)w height:(float)h fontSize:(int)fontSize
{
	CGSize size = CGSizeMake(w, h);
	Texture2D* t = [[[Texture2D alloc] initWithString:str dimensions:size alignment:UITextAlignmentLeft fontName:font fontSize:fontSize] autorelease];
	AlternateImage* image = (AlternateImage*)[AlternateImage create:t];
	image->color = c;
	image->rotationCenterX = -size.width/2;
	image.mode = MODE_GL_SRC_ALPHA_GL_ONE_MINUS_SRC_ALPHA;
	return image;
}

+(BaseElement*)createTemplateScreen
{
	BaseElement* screen = [BaseElement create];
	screen->width = SCREEN_WIDTH;
	screen->height = SCREEN_HEIGHT;
	screen->parentAnchor = TOP | LEFT;
	return screen;
}


+(Image*)createStateFlag:(int)cId
{
	Image* flag = nil;
	int index = [MenuController getStateById:cId];
	NSString* path = [[NSBundle mainBundle] pathForResource:states[index].flag ofType:@"" inDirectory:@"flags-state"];
	if(path && index != 0)
	{
		UIImage* image = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
		Texture2D* tflag = [[[Texture2D alloc] initWithImage:image] autorelease];
		flag = [Image create:tflag];
	}
	return flag;
	
}

+(Image*)createFlag:(int)cId
{
	Image* flag = nil;
	int index = [MenuController getCountryById:cId];
	NSString* path = [[NSBundle mainBundle] pathForResource:countries[index].flag ofType:@"" inDirectory:@"flags"];
	if(path && index != 0)
	{
		UIImage* image = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
		Texture2D* tflag = [[[Texture2D alloc] initWithImage:image] autorelease];
		flag = [Image create:tflag];
	}
	return flag;
	
}

+(BaseElement*)createCountryEntryForId:(int)index custom:(BOOL)b
{
	if(index >= COUNTRIES_COUNT)return nil;
	
	//Image* entry = [Image createWithResID:IMG_SMALL_LINE];
	ColoredLayer* entry = [ColoredLayer create];
	entry->width = 196;
	entry->height = 34;
	entry->color = lightGrayColor;
	entry->passColorToChilds = FALSE;
	entry->rotationCenterX = -entry->width/2;
	NSString* country_name;
	
	if(b && (countries[index].cId == 0 || index >= COUNTRIES_COUNT) )
	{
		country_name = NSLocalizedString(@"STR_COUNTRY_DEFAULT", @"Select your country");
	}
	else
	{
		country_name = countries[index].name;
	}
	
	Text* countryText = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL]];
	countryText->color = darkBlueColor;
	[countryText setString:country_name andWidth:SCREEN_WIDTH];
	countryText->anchor = countryText->parentAnchor = VCENTER | LEFT;
	countryText->x = 4;
	[entry addChild:countryText];
	
	NSString* path = [[NSBundle mainBundle] pathForResource:countries[index].flag ofType:@"" inDirectory:@"flags"];
	if(path && index != 0)
	{
		UIImage* image = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
		Texture2D* tflag = [[[Texture2D alloc] initWithImage:image] autorelease];
		Image* flag = [Image create:tflag];
		flag->parentAnchor = flag->anchor = VCENTER | LEFT;
		flag->x = 4;
		[entry addChild:flag];
		countryText->x = 8 + flag->width;
	}
	
	//	if(!b && [MenuController isCountryInEu:countries[index].cId])
	//	{
	//		NSString* path = [[NSBundle mainBundle] pathForResource:@"European-Union-Flag-32" ofType:@"png" inDirectory:@"flags"];
	//		if(path)
	//		{
	//			UIImage* image = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
	//			Texture2D* tflag = [[[Texture2D alloc] initWithImage:image] autorelease];
	//			Image* flag = [Image create:tflag];
	//			flag->parentAnchor = flag->anchor = VCENTER | RIGHT;
	//			flag->x = -4;
	//
	//			[entry addChild:flag];			
	//		}
	//	}
	
	if(!b && countries[index].cId == COUNTRY_US)
	{
		Texture2D* arrow = [ChampionsResourceMgr getResource:IMG_SELECT_LEVEL_OPEN_ARROW];
		Image* selector = [[Image allocAndAutorelease] initWithTexture:arrow];
		selector->parentAnchor = selector->anchor = RIGHT | VCENTER;
		selector->x = -4;
		[entry addChild:selector];
	}
	return entry;
}

+(BaseElement*)createStateEntryForId:(int)index custom:(BOOL)b
{
	//	Image* entry = [Image createWithResID:IMG_SMALL_LINE];
	ColoredLayer* entry = [ColoredLayer create];
	entry->width = 196;
	entry->height = 34;
	entry->color = lightGrayColor;
	entry->passColorToChilds = FALSE;
	entry->rotationCenterX = -entry->width/2;
	NSString* state_name;
	if (b && (states[index].cId == 0 || index >= STATES_COUNT))
	{
		state_name = NSLocalizedString(@"STR_STATE_DEFAULT", @"Select your state");
	}
	else
	{
		state_name = states[index].name;
	}
	
	Text* text = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL]];
	text->color = darkBlueColor;
	[text setString:state_name andWidth:SCREEN_WIDTH];
	text->anchor = text->parentAnchor = VCENTER | LEFT;
	text->x = 4;
	[entry addChild:text];
	
	NSString* path = [[NSBundle mainBundle] pathForResource:states[index].flag ofType:@"" inDirectory:@"flags-state"];
	if(path && index != 0)
	{
		UIImage* image = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
		Texture2D* tflag = [[[Texture2D alloc] initWithImage:image] autorelease];
		Image* flag = [Image create:tflag];
		flag->parentAnchor = flag->anchor = VCENTER | LEFT;
		flag->x = 4;
		[entry addChild:flag];
		text->x = 8 + flag->width;
	}
	return entry;
}

+(Image*)loadAvatar
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userPicture"];
	NSData* data = [NSData dataWithContentsOfFile:path];
	if(data)
	{		
		UIImage* image = [UIImage imageWithData:data];
		if(image)
		{
			int min = MIN(image.size.height, image.size.width);
			CGRect cropRect = CGRectMake(0, 0, min, min);
			CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
			UIImage* croppedImage = [UIImage imageWithCGImage:imageRef]; 
			CGImageRelease(imageRef);
			Texture2D* tavatar = [[[Texture2D alloc] initWithImage:croppedImage] autorelease];
			Image* avatar = [[Image allocAndAutorelease] initWithTexture:tavatar];
			float maxSideSize = MAX(avatar->height, avatar->width);
			float scaleRatio = MAX_AVATAR_SIZE / maxSideSize;
			float offsetX = round((MAX_AVATAR_SIZE - (avatar->width*scaleRatio))/2);
			float offsetY = round((MAX_AVATAR_SIZE - (avatar->height*scaleRatio))/2);
			avatar->y = 19+offsetY;
			avatar->x = 12+offsetX;
			
			avatar->rotationCenterX = -avatar->width/2;
			avatar->rotationCenterY = -avatar->height/2;
			avatar->scaleX = avatar->scaleY = scaleRatio;
			return avatar;
		}
	}
	return nil;
}

+(Image*)createPhotoWithAvatar
{
	Image* photo = [Image createWithResID:IMG_REGSCREEN_BACK_PHOTO];
	
	Image* avatar = [MenuController loadAvatar];
	if(avatar)
	{
		avatar->rotation = -12;
		avatar->parentAnchor = avatar->anchor = TOP | LEFT;
		[photo addChild:avatar];
	}
	
	Image* pinPhoto = [Image createWithResID:IMG_PIN_BLUE];
	pinPhoto->parentAnchor = pinPhoto->anchor = BOTTOM | LEFT;
	pinPhoto->x = 30;
	[photo addChild:pinPhoto];
	
	Image* clip = [Image createWithResID:IMG_CLIP_GREEN];
	clip->parentAnchor = clip->anchor = TOP | RIGHT;
	clip->x = -25;
	clip->y = -9;
	[photo addChild:clip];
	
	return photo;
}

-(BOOL)statisticsIsOpened
{
	return statScreen->y != statScreenYPos;
}

-(BOOL)optionsIsOpened
{
	return optionsBack->y != optionsBackYPos;
}

-(BaseElement*)createMapEntryForMap:(NSString*)name andNum:(int)num setName:(NSString*)sname locked:(BOOL)locked
{
	Image* entry = [Image createWithResID:IMG_SELECT_LEVEL];
	
	Font* font = [ChampionsResourceMgr getResource:FNT_FONTS_001];
	Text* numText = [[[Text alloc] initWithFont:font] autorelease];
	numText->parentAnchor = numText->anchor = TOP | LEFT;
	NSString* n = FORMAT_STRING(@"%i", num);
	float width = [font stringWidth:n];
	[numText setString:n andWidth:width];
	numText->x = 6;
	numText->y = -4;
	numText->color = optionsGrayColor;
	[entry addChild:numText];
	
	Text* scoreLabel = [[[Text alloc] initWithFont:font] autorelease];
	scoreLabel->parentAnchor = scoreLabel->anchor = TOP | LEFT;
	if(locked)
		[scoreLabel setString:NSLocalizedString(@"STR_SCORE_LABEL_LOCKED", @"LOCKED")];
	else
		[scoreLabel setString:NSLocalizedString(@"STR_SCORE_LABEL", @"SCORE")];
	scoreLabel->x = 45;
	scoreLabel->y = -4;
	[entry addChild:scoreLabel];
	
//	if(!locked)
//	{
//		Image* arrow = [Image createWithResID:IMG_SELECT_LEVEL_OPEN_ARROW];
//		arrow->parentAnchor = arrow->anchor = TOP | RIGHT;
//		arrow->x = -4;
//		arrow->y = 6;
//		[entry addChild:arrow];
//	}
	
	Font* font_small = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
	Text* setName = [[[Text alloc] initWithFont:font_small] autorelease];
	[setName setString:sname];
	setName->parentAnchor = setName->anchor = BOTTOM | LEFT;
	setName->x = 45;
	setName->y = -6;
	[entry addChild:setName];
	if(locked)
	{
		[entry setDrawQuad:2];
		setName->color = optionsGrayColor;
	}
	else 
	{
		if([name hasPrefix:@"1"])
		{
			[entry setDrawQuad:0];
			setName->color = selectorGreenColor;
		}
		else
		{
			[entry setDrawQuad:1];
			setName->color = selectorRedColor;
		}
	}
	if (!locked) 
	{
		int scores = 0;
		int lightsTurnedOn = 0;
		ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
		if(rc && rc.user)
		{
			FPScores* savedScores = [rc.user getScoresForMap:name];
			if(savedScores)
			{
				scores = savedScores->scores;
				lightsTurnedOn = savedScores->medal;
				if(lightsTurnedOn > 3)lightsTurnedOn = 10;
				if(lightsTurnedOn > 1 && lightsTurnedOn < 4)lightsTurnedOn = 5;
			}
		}
		Text* score = [[Text allocAndAutorelease] initWithFont:font_small];
		[score setString:FORMAT_STRING(@"%i", scores)];
		score->color = optionsGrayColor;
		score->anchor = BOTTOM | LEFT;
		score->parentAnchor = BOTTOM | RIGHT;
		score->x = 5;
		score->y = -4;
		[scoreLabel addChild:score];
		
		HBox* lights = [[HBox allocAndAutorelease] initWithOffset:0.5 Align:VCENTER Height:10];
		lights->parentAnchor = lights->anchor = BOTTOM | RIGHT;
		lights->y = -10;
		lights->x = -7;
		for(int i = 0; i < 10; i++)
		{
			Image* light = [Image createWithResID:IMG_COOL_BAR];
			if(lightsTurnedOn > i)
				[light setDrawQuad:0];
			else 
				[light setDrawQuad:1];
			
			[lights addChild:light];
		}
		[entry addChild:lights];
	}
	return entry;
}

-(void)addMode1Maps
{
//	ASSERT(!levels1Container);
	ASSERT(mapsList);
	int countMode1Maps = [MapsListParser countMapsWitPrefix:@"1" inList:mapsList];
	levels1Container = [[ScrollableContainer allocAndAutorelease] initWithWidth:260 Height:295 ContainerWidth:260 Height:countMode1Maps * MAP_ENTRY_HEIGHT];
	levels1Container->parentAnchor = levels1Container->anchor = TOP | LEFT;
	levels1Container->x = 0;
	levels1Container->y = 45;
	levels1Container->resetScrollOnShow	= TRUE;
	//	levels1Container->touchPassTimeout = 0.01;
	[levelsScrollBack1 addChild:levels1Container];	
	[levels1Container turnScrollPointsOnWithCapacity:countMode1Maps];
	

	int mapNum = 0;
	int mapsUnlocked = DEFAULT_MAPS_UNLOCKED;
	for(LevelSet* set in mapsList)
	{
		int num = 0;
		for(NSString* mapName in set->list)
		{
			if([mapName hasPrefix:@"1"])
			{
				mapNum++;
				num++;
				BOOL locked = mapsUnlocked < mapNum;
				BaseElement* entry = [self createMapEntryForMap:mapName andNum:num setName:set.name locked:locked];
				BaseElement* entry2 = [self createMapEntryForMap:mapName andNum:num setName:set.name locked:locked];
				entry2->scaleX = entry2->scaleY = 1.1;
				AlternateButton* bentry = [[AlternateButton allocAndAutorelease] initWithUpElement:entry DownElement:entry2 andID:BUTTON_PLAY_MAP];
				if(!locked)
					[bentry setDelegate:self];
				bentry->x = 20;
				bentry->parentAnchor = bentry->anchor = TOP | LEFT;
				bentry->y = MAP_ENTRY_HEIGHT*(mapNum - 1);
				[levels1Container addChild:bentry];
				[levels1Container addScrollPointAtX:0 Y:bentry->y];
				[bentry setName:mapName];
				ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
				if(rc && rc.user)
				{
					FPScores* savedScores = [rc.user getScoresForMap:mapName];
					if(savedScores)
					{
						if(savedScores->medal > 0)mapsUnlocked += MAPS_UNLOCK_FOR_LVL_COMPLETE;
					}
				}
			}
		}
	}	
	scroll1.provider = levels1Container;
	levels1Container->canSkipScrollPoints = TRUE;
}

-(void)addMode2Maps
{
	ASSERT(mapsList);
	int countMode2Maps = [MapsListParser countMapsWitPrefix:@"2" inList:mapsList];
	levels2Container = [[ScrollableContainer allocAndAutorelease] initWithWidth:260 Height:295 ContainerWidth:260 Height:countMode2Maps * MAP_ENTRY_HEIGHT];
	levels2Container->parentAnchor = levels2Container->anchor = TOP | LEFT;
	levels2Container->y = 45;
	levels2Container->resetScrollOnShow	= TRUE;	
	[levelsScrollBack2 addChild:levels2Container];
	
	[levels2Container turnScrollPointsOnWithCapacity:countMode2Maps];
	
	int mapsUnlocked = DEFAULT_MAPS_UNLOCKED;
	int mapNum = 0;
	for(LevelSet* set in mapsList)
	{
		int num = 0;
		for(NSString* mapName in set->list)
		{
			if([mapName hasPrefix:@"2"])
			{
				mapNum++;
				num++;
				BOOL locked = mapsUnlocked < mapNum;
				BaseElement* entry = [self createMapEntryForMap:mapName andNum:num setName:set.name locked:locked];
				BaseElement* entry2 = [self createMapEntryForMap:mapName andNum:num setName:set.name locked:locked];
				entry2->scaleX = entry2->scaleY = 1.1;				
				AlternateButton* bentry = [[AlternateButton allocAndAutorelease] initWithUpElement:entry DownElement:entry2 andID:BUTTON_PLAY_MAP];
				bentry->x = 20;
				if(!locked)
					[bentry setDelegate:self];
				[bentry setName:mapName];
				ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
				if(rc && rc.user)
				{
					FPScores* savedScores = [rc.user getScoresForMap:mapName];
					if(savedScores)
					{
						if(savedScores->medal > 0)mapsUnlocked += MAPS_UNLOCK_FOR_LVL_COMPLETE;
					}
				}
				
				bentry->parentAnchor = bentry->anchor = TOP | LEFT;
				bentry->y = MAP_ENTRY_HEIGHT*(mapNum - 1);
				[levels2Container addChild:bentry];
				[levels2Container addScrollPointAtX:0 Y:bentry->y];
			}
		}
	}	
	scroll2.provider = levels2Container;
	levels2Container->canSkipScrollPoints = TRUE;
}

-(void)updateUserData
{
	if(mainBack)
	{
		if(bphoto)			
			[mainBack removeChild:bphoto];
		
		
		Image* photo = [MenuController createPhotoWithAvatar];
		Image* photoPressed = [MenuController createPhotoWithAvatar];
		photoPressed->scaleX = photoPressed->scaleY = 1.2;
		
		bphoto = [[Button allocAndAutorelease] initWithUpElement:photo DownElement:photoPressed andID:BUTTON_REGISTRATION];
		bphoto->parentAnchor = LEFT | VCENTER;
		bphoto->anchor = LEFT | TOP;
		bphoto->x = -20;
		bphoto->y = 15;
		[bphoto setDelegate:self];
		[mainBack addChild:bphoto];
		
	}
	
	[self recreateRegistration];
	if(levels1Container)
	{
		[levelsScrollBack1 removeChild:levels1Container];
		[self addMode1Maps];
	}
	
	if(levels2Container)
	{
		[levelsScrollBack2 removeChild:levels2Container];
		[self addMode2Maps];
	}
	
}
-(void)createPins
{
	Texture2D* tof = [ChampionsResourceMgr getResource:IMG_OF_LOGO_MAIN];
	Button* of = [MenuController createButtonWithTextureUp:tof Down:tof ID:BUTTON_OPENFEINT scaleRatio:1.2];
	[of setDelegate:self];
	of->parentAnchor = TOP | LEFT;
	of->anchor = VCENTER | LEFT;
	of->y = 8;
	of->x = -4;
	[mapGrid addChild:of];
	
	Image* alien = [Image createWithResID:IMG_ALIEN];
	alien->parentAnchor = TOP | HCENTER;
	alien->anchor = BOTTOM | HCENTER;
	alien->y = 50;
	alien->x = -22;
	[mapGrid addChild:alien];
	
	Image* mapAll = [Image createWithResID:IMG_MAP_ALL];
	mapAll->parentAnchor = mapAll->anchor = TOP | HCENTER;
	mapAll->y = 20;
	[mapGrid addChild:mapAll];
	
#pragma mark MAP PINS
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"countries"];
	NSDictionary* topCountries = [NSDictionary dictionaryWithContentsOfFile:path];
	if(topCountries)
	{
		Font* font_small = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
		for(int i = 2; i >= 0; i--)
		{
			int cId = [[topCountries objectForKey:FORMAT_STRING(@"countryId%i",i)] intValue];
			if(cId)
			{
				int lId = [MenuController getCountryById:cId];
				if(lId > 0 && countries[lId].p.x != 0 && countries[lId].p.y != 0)
				{
					Image* medal = [Image createWithResID:IMG_STARS];
					[medal setDrawQuad:2-i];
					medal->parentAnchor = TOP | LEFT;
					medal->anchor = CENTER;
					medal->x = countries[lId].p.x;
					medal->y = countries[lId].p.y;
					[mapAll addChild:medal];
					
					BaseElement* flag = [MenuController createFlag:cId];
					Image* countryTitle = [Image createWithResID:IMG_CHART_PAPER_01+i];
					Text* countryName = [[Text allocAndAutorelease] initWithFont:font_small];
					countryName->color = optionsGrayColor;
					[countryName setString:countries[lId].name];
					countryName->parentAnchor = countryName->anchor = VCENTER | LEFT;
					countryName->x = 10;					
					[countryTitle addChild:countryName];
					flag->anchor = VCENTER | RIGHT;
					flag->parentAnchor = VCENTER | LEFT;
					[countryTitle addChild:flag];
					countryTitle->anchor = countryTitle->parentAnchor = BOTTOM | LEFT;
					countryTitle->x = FLAG_WIDTH+45;
					countryTitle->y = -28*(2-i) - 28;
					[mapGrid addChild:countryTitle];
				}
			}
		}
	}
}

#pragma mark -
-(void)createMainMenu
{
	MenuView* view = [[MenuView allocAndAutorelease] initFullscreen];			

	mainContainer = [[FPScrollableContainer allocAndAutorelease] initWithWidth:SCREEN_WIDTH Height:SCREEN_HEIGHT ContainerWidth:SCREEN_WIDTH*3 Height:SCREEN_HEIGHT];
	mainContainer->touchPassTimeout = 0;
//	mainContainer->touchMoveIgnoreLength = 30;
//	mainContainer->dontHandleTouchUpsHandledByChilds = TRUE;
	mainContainer->dontHandleTouchMovesHandledByChilds = TRUE;
	mainContainer->dontHandleTouchDownsHandledByChilds = TRUE;
	[mainContainer turnScrollPointsOnWithCapacity:3];
	[mainContainer addScrollPointAtX:0 Y:0];
	[mainContainer addScrollPointAtX:SCREEN_WIDTH Y:0];	
	[mainContainer addScrollPointAtX:SCREEN_WIDTH*2 Y:0];	
	mainContainer.delegate = self;
	
	//Create levels selector mode 2
	BaseElement* selector2Screen = [MenuController createTemplateScreen];
	selector2Screen->x = SCREEN_WIDTH*2;
	
	Image* back2 = [Image createWithResID:IMG_TOWN_BACK_01];
	back2->parentAnchor = back2->anchor = TOP | HCENTER;
	back2->y = 0;
	[selector2Screen addChild:back2];
	
	Image* floorBack2 =  [Image createWithResID:IMG_FLOOR_BACK];
	floorBack2->parentAnchor = floorBack2->anchor = BOTTOM | HCENTER;
	floorBack2->y = 6;
	[selector2Screen addChild:floorBack2];
	
	Image* fence = [Image createWithResID:IMG_GAMEROOM_02_NETT];
	fence->parentAnchor = BOTTOM | RIGHT;
	fence->anchor = BOTTOM | HCENTER;
	fence->x = -30;
	fence->y = -45;
	[floorBack2 addChild:fence];
	
	Image* rail = [Image createWithResID:IMG_GAMEROOM_02_RAIL];
	rail->parentAnchor = BOTTOM | LEFT;
	rail->anchor = BOTTOM | HCENTER;
	rail->y = 5;
	[fence addChild:rail];
	
	Image* bumper = [Image createWithResID:IMG_GAMEROOM_02_BAMPER];
	bumper->parentAnchor = BOTTOM | LEFT;
	bumper->anchor = BOTTOM | HCENTER;
	bumper->y = 5;
	bumper->x = 5;
	[fence addChild:bumper];
	
	Image* shadow2 = [Image createWithResID:IMG_UPSHADOW];
	shadow2->parentAnchor = shadow2->anchor = TOP | LEFT;
	[selector2Screen addChild:shadow2];
		
	[mainContainer addChild:selector2Screen];
	
	//Create levels selector mode 1
	BaseElement* selector1Screen = [MenuController createTemplateScreen];
	selector1Screen->x = SCREEN_WIDTH;
	
	Image* floorBack1 =  [Image createWithResID:IMG_FLOOR_BACK];
	floorBack1->parentAnchor = floorBack1->anchor = BOTTOM | HCENTER;
	floorBack1->y = 6;
	
	Image* back1 = [Image createWithResID:IMG_BACK_01];
	back1->parentAnchor = BOTTOM| RIGHT;
	back1->anchor = BOTTOM | RIGHT;
	back1->y = -floorBack1->height+floorBack1->y;
	[selector1Screen addChild:back1];

	Image* screensSeparator = [Image createWithResID:IMG_SHRINK_MENU_SEP];
	screensSeparator->parentAnchor = TOP | RIGHT;
	screensSeparator->anchor = TOP | HCENTER;
	screensSeparator->y = -back1->y;
	[back1 addChild:screensSeparator];
	
	Image* birdHouse = [Image createWithResID:IMG_BIRD_HOUSE];
	birdHouse->parentAnchor = CENTER;
	birdHouse->anchor = BOTTOM | RIGHT;
	birdHouse->y = -20;
	[selector1Screen addChild:birdHouse];
	
	Image* cloud = [Image createWithResID:IMG_CLOUD_003];
	cloud->parentAnchor = cloud->anchor = VCENTER | RIGHT;
	cloud->x = 20;
	[back1 addChild:cloud];
	
	Image* cloud2 = [Image createWithResID:IMG_CLOUD_001];
	cloud2->parentAnchor = BOTTOM | HCENTER;
	cloud2->anchor = TOP | HCENTER;
	cloud2->x = -15;
	cloud2->y = -20;
	[cloud addChild:cloud2];
	
	Image* baloon = [Image createWithResID:IMG_GAMEROOM_02_BALOON];
	baloon->parentAnchor = TOP | RIGHT;
	baloon->anchor = BOTTOM | LEFT;
	baloon->x = -40;
	baloon->y = 30;
	[cloud addChild:baloon];
	
	Image* branch_01 = [Image createWithResID:IMG_BRANCH_01];
	branch_01->parentAnchor = BOTTOM | LEFT;
	branch_01->anchor = BOTTOM | LEFT;
	branch_01->x = -branch_01->width/6;
	branch_01->y = -40;
	[selector1Screen addChild:branch_01];
	
	Image* branch_03 = [Image createWithResID:IMG_BRANCH_03];
	branch_03->parentAnchor = BOTTOM | LEFT;
	branch_03->anchor = BOTTOM | LEFT;
	branch_03->rotationCenterX = -56;
	branch_03->rotationCenterY = 31;
	branch_03->rotation = -75;
	branch_03->y = -20;
	branch_03->x = 50;
	[selector1Screen addChild:branch_03];
	
	[selector1Screen addChild:floorBack1];
		
	Image* flower = [Image createWithResID:IMG_GAMEROOM_01_FLOWER];
	flower->parentAnchor = flower->anchor = BOTTOM | LEFT;
	flower->x = 10;
	flower->y = -10;
	[floorBack1 addChild:flower];
	
	Image* shadow1 = [Image createWithResID:IMG_UPSHADOW];
	shadow1->parentAnchor = shadow1->anchor = TOP | LEFT;
	[selector1Screen addChild:shadow1];
	
	[mainContainer addChild:selector1Screen];	
	
	
	//Create main screen
	BaseElement* mainScreen = [MenuController createTemplateScreen];
	mainScreen->width = SCREEN_WIDTH*3;
	Image* objectsBack = [Image createWithResID:IMG_MAIN_OLD_OBJECTS_BACK];
	objectsBack->parentAnchor = objectsBack->anchor = BOTTOM | LEFT;
	[mainScreen addChild:objectsBack];
	
	Image* ropeDecorShadow = [Image createWithResID:IMG_ROPE_DECOR_SHADOW];
	ropeDecorShadow->parentAnchor = ropeDecorShadow->anchor = TOP | LEFT;
	ropeDecorShadow->x = 263;
	ropeDecorShadow->y = 8;
	[mainScreen addChild:ropeDecorShadow];
	
	Image* branch_02 = [Image createWithResID:IMG_BRANCH_02];
	branch_02->parentAnchor = BOTTOM | RIGHT;
	branch_02->anchor = BOTTOM | LEFT;
	branch_02->x = -28;
	branch_02->y = -32;
	[objectsBack addChild:branch_02];
	
	Image* field = [Image createWithResID:IMG_TREE_FIELD_03];
	field->scaleX = -1;
	field->parentAnchor = BOTTOM | RIGHT;
	field->anchor = BOTTOM | LEFT;
	field->x = -80;
	field->y = -40;
	field->passTransformationsToChilds = FALSE;
	[objectsBack addChild:field];
	
	Texture2D* tmainButton = [ChampionsResourceMgr getResource:IMG_MAIN_LEFT];
	Button* bmainMenu = [MenuController createButtonWithTextureUp:tmainButton Down:tmainButton ID:BUTTON_MAIN_MENU scaleRatio:1.2];
	bmainMenu->parentAnchor = bmainMenu->anchor = CENTER;
#ifdef FREE
	bmainMenu->y = -10;
#endif
	[bmainMenu setDelegate:self];
	[field addChild:bmainMenu];
	
	Image* pipes = [Image createWithResID:IMG_CRANE_TUBE];
	pipes->parentAnchor = BOTTOM | RIGHT;
	pipes->anchor = BOTTOM | LEFT;
	pipes->x = 140;
	pipes->y = -6;
	[field addChild:pipes];
	
	Button* bmainMenu2 = [MenuController createButtonWithTextureUp:tmainButton Down:tmainButton ID:BUTTON_MAIN_MENU scaleRatio:1.2];
	bmainMenu2->parentAnchor = CENTER;
	bmainMenu2->anchor = VCENTER | RIGHT;
#ifdef FREE
	bmainMenu2->y = -50;
#else
	bmainMenu2->x = 10;
	bmainMenu2->y = 5;
#endif
	[bmainMenu2 setDelegate:self];
	[pipes addChild:bmainMenu2];
	
	Image* field2 = [Image createWithResID:IMG_GAMEROOM_01_FIELD];
	field2->parentAnchor = VCENTER | RIGHT;
	field2->anchor = VCENTER | LEFT;
	field2->x = -95;
	field2->y = 25;
	[field addChild:field2];

	Button* mode1PrevButton = [MenuController createButtonWithImage:IMG_NEXTMODE_ARROW ID:BUTTON_MODE2_POSITION Delegate:self];
	mode1PrevButton->parentAnchor = TOP | RIGHT;
	mode1PrevButton->anchor = TOP | RIGHT;
#ifdef FREE
	mode1PrevButton->y = 10;
#else
	mode1PrevButton->y = 55;
#endif
	mode1PrevButton->x = -25;
	[field2 addChild:mode1PrevButton];

	Button* mode2PrevButton = [MenuController createButtonWithImage:IMG_PREVMODE_ARROW ID:BUTTON_MODE1_POSITION Delegate:self];
	mode2PrevButton->parentAnchor = TOP | RIGHT;
	mode2PrevButton->anchor = TOP | LEFT;
#ifdef FREE
	mode2PrevButton->y = 10;
#else
	mode2PrevButton->y = 55;
#endif
	mode2PrevButton->x = -20;
	[field2 addChild:mode2PrevButton];
	
	mainBack = [Image createWithResID:IMG_MAIN_BACK];
	mainBack->parentAnchor = mainBack->anchor = TOP | LEFT;
	[mainScreen addChild:mainBack];
	
	Image* mainDrawBack = [Image createWithResID:IMG_MAIN_DRAW_BACK];
	mainDrawBack->parentAnchor = mainDrawBack->anchor = BOTTOM | RIGHT;
	mainDrawBack->y = -40;
	mainDrawBack->x = -5;
	[mainBack addChild:mainDrawBack];
	
#ifdef FREE
	Texture2D* tbuyfull = [ChampionsResourceMgr getResource:IMG_FREE_BUYFULL];
	Button* buyfullButton = [MenuController createButtonWithTextureUp:tbuyfull Down:tbuyfull ID:BUTTON_BUYFULL scaleRatio:1.2];
	buyfullButton->parentAnchor = buyfullButton->anchor = BOTTOM | HCENTER;
	buyfullButton->y = 20;
	buyfullButton->x = -20;
	[buyfullButton setDelegate:self];
	[mainBack addChild:buyfullButton];
#endif
	
	Texture2D* tplay = [ChampionsResourceMgr getResource:IMG_MENU_PLAY_BUTTON];
	Texture2D* tplayPushed = [ChampionsResourceMgr getResource:IMG_PLAY_BUTTON_PUSH];
	Button* bplay = [MenuController createButtonWithTextureUp:tplay Down:tplayPushed ID:BUTTON_PLAY scaleRatio:1];
	bplay->parentAnchor = bplay->anchor = BOTTOM | HCENTER;
	bplay->x = -20;
	bplay->y = -20;
	[bplay setDelegate:self];
	[mainBack addChild:bplay];
	
	Image* mapBack = [Image createWithResID:IMG_MAP_BACK];
	mapBack->y = 35;
	mapBack->parentAnchor = mapBack->anchor	= TOP | HCENTER;
	[mainBack addChild:mapBack];
	
	mapGrid = [Image createWithResID:IMG_MAP_BACK_WEB];
	mapGrid->parentAnchor = TOP | LEFT;
	mapGrid->x = 6;
	[mapBack addChild:mapGrid];
	
	[self createPins];
	
	Texture2D* tlevels = [ChampionsResourceMgr getResource:IMG_LEVELS];
	Button* blevels = [MenuController createButtonWithTextureUp:tlevels Down:tlevels ID:BUTTON_LEVELS scaleRatio:1.2];
	[blevels setDelegate:self];
	blevels->parentAnchor = blevels->anchor = RIGHT | BOTTOM;
	blevels->y = -50;
	[mainBack addChild:blevels];
	
	Image* ropeDecor = [Image createWithResID:IMG_ROPE_DECOR];
	ropeDecor->parentAnchor = ropeDecor->anchor = TOP | RIGHT;
	ropeDecor->x = 15;
	[mainBack addChild:ropeDecor];
	
//	Texture2D* tbuy = [ChampionsResourceMgr getResource:IMG_MORE_GAMES];
//	Button* buyButton = [MenuController createButtonWithTextureUp:tbuy Down:tbuy ID:BUTTON_BUY scaleRatio:1.2];
//	buyButton->parentAnchor = buyButton->anchor = LEFT | BOTTOM;
//	buyButton->x = -20;
//	buyButton->y = -12;
//	[buyButton setDelegate:self];
//	[mainBack addChild:buyButton];
			
	Image* photo = [MenuController createPhotoWithAvatar];
	Image* photoPressed = [MenuController createPhotoWithAvatar];
	photoPressed->scaleX = photoPressed->scaleY = 1.2;
	
	bphoto = [[Button allocAndAutorelease] initWithUpElement:photo DownElement:photoPressed andID:BUTTON_REGISTRATION];
	bphoto->parentAnchor = LEFT | VCENTER;
	bphoto->anchor = LEFT | TOP;
	bphoto->x = -20;
	bphoto->y = 15;
	[bphoto setDelegate:self];
	[mainBack addChild:bphoto];
		
	[mainContainer addChild:mainScreen];
	
#pragma mark statistics
	statScreen = [MenuController createTemplateScreen];
	statScreen->parentAnchor = TOP | LEFT;
	statScreen->anchor = BOTTOM | LEFT;
	statScreen->y = statScreenYPos;
	statScreen->rotation = -2;
	statScreen->rotationCenterX = -statScreen->width/2;
	statScreen->rotationCenterY = statScreen->height/2 - 30;
	
	float yoffset = 30;
	Timeline* st = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:3];
	KeyFrame skeyframe = makePos(statScreen->x, statScreen->y, FRAME_TRANSITION_EASE_OUT, 0);
	[st addKeyFrame:skeyframe];
//	skeyframe = makePos(statScreen->x, statScreen->y, FRAME_TRANSITION_EASE_OUT, 0.2);
//	[st addKeyFrame:skeyframe];
	skeyframe = makePos(statScreen->x, statScreen->height-yoffset, FRAME_TRANSITION_EASE_OUT, 0.5);
	[st addKeyFrame:skeyframe];
	
	skeyframe = makeRotation(-2, FRAME_TRANSITION_LINEAR, 0);
	[st addKeyFrame:skeyframe];
	skeyframe = makeRotation(0, FRAME_TRANSITION_LINEAR, 0.5);
	[st addKeyFrame:skeyframe];	
	[statScreen addTimeline:st];

	Timeline* st2 = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:3];	
	skeyframe = makePos(statScreen->x, statScreen->height-yoffset, FRAME_TRANSITION_EASE_OUT, 0);
	[st2 addKeyFrame:skeyframe];	
//	skeyframe = makePos(statScreen->x, statScreen->y, FRAME_TRANSITION_EASE_OUT, 0.3);
//	[st2 addKeyFrame:skeyframe];	
	skeyframe = makePos(statScreen->x, statScreen->y, FRAME_TRANSITION_EASE_OUT, 0.5);
	[st2 addKeyFrame:skeyframe];
	
	skeyframe = makeRotation(0, FRAME_TRANSITION_LINEAR, 0);
	[st2 addKeyFrame:skeyframe];
//	skeyframe = makeRotation(0, FRAME_TRANSITION_LINEAR, 0.3);
//	[st2 addKeyFrame:skeyframe];
	skeyframe = makeRotation(-2, FRAME_TRANSITION_LINEAR, 0.5);
	[st2 addKeyFrame:skeyframe];		
	[statScreen addTimeline:st2];
	
	[mainScreen addChild:statScreen];

	Image* statBack = [Image createWithResID:IMG_MAIN_BACK];
	statBack->parentAnchor = statBack->anchor = TOP | HCENTER;	
	[statScreen addChild:statBack];
	
	Image* statBack2 = [Image createWithResID:IMG_MAIN_BACK];
	statBack2->parentAnchor = statBack2->anchor = BOTTOM | HCENTER;	
	[statScreen addChild:statBack2];
	
	Button* bstat = [MenuController createButtonWithBackTexture:IMG_STAT_BACK text:NSLocalizedString(@"STR_BTN_STATISTICS", @"Statistics") textAngle:-3 textX:3 textY:0 font:FNT_FONTS_002 buttonId:BUTTON_MAIN_SCORES];
	bstat->parentAnchor = bstat->anchor = BOTTOM | RIGHT;
	bstat->y = -25;
	bstat->x = -10;
	[bstat setDelegate:self];
	[statBack2 addChild:bstat];
	
#pragma mark -
	levelsScrollBack1 = [Image createWithResID:IMG_SELECT_LEVEL_BACK];
	levelsScrollBack1->parentAnchor = levelsScrollBack1->anchor = VCENTER | LEFT;
	levelsScrollBack1->x = SCREEN_WIDTH+(SCREEN_WIDTH-levelsScrollBack1->width)/2;
	[mainScreen addChild:levelsScrollBack1];

	HBox* dotsBox = [[HBox allocAndAutorelease] initWithOffset:1 Align:VCENTER Height:16];
	dotsBox->parentAnchor = dotsBox->anchor = BOTTOM | HCENTER;
	dotsBox->y = - 37;
	for (int i = 0; i < MODS_COUNT; i++)
	{
		Image* dot = [Image createWithResID:IMG_DOTS_SCREENS];
		[dot setDrawQuad:(i == 0)?1:0];
		[dotsBox addChild:dot];
	}
	
	[levelsScrollBack1 addChild:dotsBox];
	
	Image* scrollLiftBack1 = [Image createWithResID:IMG_SELECT_LEVEL_SLIDER_LINE];
	scrollLiftBack1->parentAnchor = scrollLiftBack1->anchor = RIGHT | VCENTER;
	scrollLiftBack1->x = -15;
	scrollLiftBack1->y = -10;
	[scrollLiftBack1 setDrawQuad:0];
	[levelsScrollBack1 addChild:scrollLiftBack1];
	
	levelsScrollBack2 = [Image createWithResID:IMG_SELECT_LEVEL_BACK];
	levelsScrollBack2->parentAnchor = levelsScrollBack2->anchor = VCENTER | LEFT;
	levelsScrollBack2->x = SCREEN_WIDTH*2+(SCREEN_WIDTH-levelsScrollBack2->width)/2;
	[mainScreen addChild:levelsScrollBack2];

	HBox* dotsBox2 = [[HBox allocAndAutorelease] initWithOffset:1 Align:VCENTER Height:16];
	dotsBox2->parentAnchor = dotsBox2->anchor = BOTTOM | HCENTER;
	dotsBox2->y = - 37;
	for (int i = 0; i < MODS_COUNT; i++)
	{
		Image* dot = [Image createWithResID:IMG_DOTS_SCREENS];
		[dot setDrawQuad:(i == 1)?2:0];
		[dotsBox2 addChild:dot];
	}
	
	[levelsScrollBack2 addChild:dotsBox2];
	
	Image* scrollLiftBack2 = [Image createWithResID:IMG_SELECT_LEVEL_SLIDER_LINE];
	scrollLiftBack2->parentAnchor = scrollLiftBack2->anchor = RIGHT | VCENTER;
	scrollLiftBack2->x = -15;
	scrollLiftBack2->y = -10;
	[scrollLiftBack2 setDrawQuad:1];
	[levelsScrollBack2 addChild:scrollLiftBack2];

	Image* modeLogo1 = [Image createWithResID:IMG_LEVEL_WG_LOGO];
	modeLogo1->parentAnchor = TOP | LEFT;
	modeLogo1->anchor = TOP | HCENTER;
	modeLogo1->x = SCREEN_WIDTH + SCREEN_WIDTH/2;
	modeLogo1->y = -8;
	[mainScreen addChild:modeLogo1];
	
	Image* modeLogo2 = [Image createWithResID:IMG_LEVEL_CONSTR_LOGO];
	modeLogo2->parentAnchor = TOP | LEFT;
	modeLogo2->anchor = TOP | HCENTER;
	modeLogo2->x = SCREEN_WIDTH*2 + SCREEN_WIDTH/2;
	modeLogo2->y = -8;
	[mainScreen addChild:modeLogo2];

	scroll1 = [[FPScrollbar allocAndAutorelease] initWithWidth:scrollLiftBack1->width Height:scrollLiftBack1->height-20 Vertical:TRUE];
	Image* lift1 = [Image createWithResID:IMG_SELECT_LEVEL_SLIDER];
	[lift1 setDrawQuad:0];
	lift1->parent = scrollLiftBack1;
	lift1->parentAnchor = lift1->anchor = TOP | HCENTER;
	scroll1.lift = lift1;
	[scrollLiftBack1 addChild:scroll1];
//	scroll1.provider = levels1Container;
	scroll1->parentAnchor = scroll1->anchor = TOP | LEFT;
	
	[self addMode1Maps];
		
	scroll2 = [[FPScrollbar allocAndAutorelease] initWithWidth:scrollLiftBack2->width Height:scrollLiftBack2->height-20 Vertical:TRUE];
	Image* lift2 = [Image createWithResID:IMG_SELECT_LEVEL_SLIDER];
	[lift2 setDrawQuad:1];
	lift2->parent = scrollLiftBack2;
	lift2->parentAnchor = lift2->anchor = TOP | HCENTER;
	scroll2.lift = lift2;
	[scrollLiftBack2 addChild:scroll2];
//	scroll2.provider = levels2Container;
	scroll2->parentAnchor = scroll2->anchor = TOP | LEFT;

	[self addMode2Maps];	
	
	//Create options
	BaseElement* options = [self createOptions];
	[mainScreen addChild:options];
	
	[view addChild:mainContainer];	
	
	[self addView:view withID:VIEW_MAIN_MENU];	
}

-(void)baloonClosed:(Baloon*)baloon
{
	switch (baloon->baloonID)
	{
		case BALOON_REGISTRATION_01:
			[Baloon showBaloonWithID:BALOON_REGISTRATION_02 Text:NSLocalizedString(@"STR_TUTORIAL_TUTORIAL_REGISTRATION_02", @"Join the finger squad, soldier!") 
							   Image:[Image createWithResID:IMG_PERSONAGES Quad:IMG_PERSONAGES_dude02] Blocking:TRUE Type:BALOON_MULTIPLE_LAST inView:[self getView:VIEW_REGISTRATION] Delegate:self];			
			break;
		
		case BALOON_REGISTRATION_02:
			// [OpenFeint launchDashboard];						
			break;
		case BALOON_NEWS:
			break;
	}
			
}

-(BaseElement*)createOptions
{
	optionsBack = [Image createWithResID:IMG_MAIN_OPTIONS_BACK];
	optionsBack->parentAnchor = BOTTOM | LEFT;
	optionsBack->anchor = TOP | LEFT;
	optionsBack->y = optionsBackYPos;
	
	Timeline* t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:2];
	KeyFrame frame = makePos(optionsBack->x, optionsBack->y, FRAME_TRANSITION_EASE_OUT, 0);
	[t addKeyFrame:frame];
	frame = makePos(optionsBack->x, -optionsBack->height, FRAME_TRANSITION_EASE_OUT, 0.5);
	[t addKeyFrame:frame];
	[optionsBack addTimeline:t];
	
	Timeline* t2 = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:2];
	frame = makePos(optionsBack->x, -optionsBack->height, FRAME_TRANSITION_EASE_IN, 0);
	[t2 addKeyFrame:frame];
	frame = makePos(optionsBack->x, optionsBack->y, FRAME_TRANSITION_EASE_IN, 0.5);	
	[t2 addKeyFrame:frame];
	[optionsBack addTimeline:t2];
	
	Button* boptions = [MenuController createButtonWithBackTexture:IMG_OPTIONS_ARROW text:NSLocalizedString(@"STR_BTN_OPTIONS", @"Options") textAngle:-3 textX:50 textY:-8 font:FNT_FONTS_002 buttonId:BUTTON_OPTIONS];
	[boptions setDelegate:self];
	boptions->x = 10;
	boptions->y = 30;
	boptions->parentAnchor = boptions->anchor = TOP | HCENTER;
	[optionsBack addChild:boptions];
	
	ToggleButton* bmusic = [MenuController createToggleButtonWithBack:IMG_TITLE_BIG toggleFront:IMG_RED_LINE_01 Text:NSLocalizedString(@"STR_BTN_MUSIC", @"Music") ID:BUTTON_MUSIC_ONOFF Delegate:self];
	bmusic->parentAnchor = TOP | HCENTER;
	bmusic->anchor = TOP | LEFT;
	bmusic->y = 120;
	bmusic->x = -20;
	bmusic->rotation = - 3;
	[optionsBack addChild:bmusic];
	
	ToggleButton* bsound = [MenuController createToggleButtonWithBack:IMG_TITLE_BIG toggleFront:IMG_RED_LINE_02 Text:NSLocalizedString(@"STR_BTN_SOUND", @"Sound") ID:BUTTON_SOUND_ONOFF Delegate:self];
	bsound->parentAnchor = TOP | HCENTER;
	bsound->anchor = TOP | LEFT;
	bsound->y = 150;
	bsound->x = -20;
	bsound->rotation = 3;
	[optionsBack addChild:bsound];
	
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
	handBack->y = 90;
	handBack->x = -45;
	[optionsBack addChild:handBack];
	
	Image* handRight = [Image createWithResID:IMG_OPTIONS_RIGHT_SOUND];
	handRight->parentAnchor = handRight->anchor = BOTTOM | HCENTER;
	[handBack addChild:handRight];
	
//	Image* optionsList = [Image createWithResID:IMG_OPTIONS_BACK];
//	optionsList->rotation = -3;
//	optionsList->parentAnchor = CENTER;
//	optionsList->anchor = TOP | HCENTER;
//	optionsList->y = -40;
//	[optionsBack addChild:optionsList];
	
//	Image* pinOptions = [Image createWithResID:IMG_PIN_BLUE];
//	pinOptions->parentAnchor = pinOptions->anchor = TOP | LEFT;
//	pinOptions->x = 30;
//	pinOptions->y = 5;
//	[optionsList addChild:pinOptions];
//	
//	Image* pinHole = [Image createWithResID:IMG_PIN_HOLE];
//	pinHole->parentAnchor = pinOptions->anchor = TOP | RIGHT;
//	pinHole->x = -25;
//	pinHole->y = 5;
//	[optionsList addChild:pinHole];
//	
//	Image* pinOptions2 = [Image createWithResID:IMG_PIN_BLUE];
//	pinOptions2->parentAnchor = pinOptions2->anchor =	TOP | LEFT;
//	pinOptions2->x = 14;
//	pinOptions2->y = 12;
//	[pinHole addChild:pinOptions2];

	optionsMenu = [BaseElement create];
	optionsMenu->width = SCREEN_WIDTH;
	optionsMenu->height = 240;
	optionsMenu->anchor = optionsMenu->parentAnchor = BOTTOM | HCENTER;
	[optionsBack addChild:optionsMenu];
	
//	BaseElement* optionsBox = [self createOptionsBox];
//	[optionsMenu addChild:optionsBox];
	
	BaseElement* feedbackBox = [self createFingerFeedbackBox];
	[optionsMenu addChild:feedbackBox];
	
	BaseElement* aboutBox = [self createAboutBox];
	[aboutBox setEnabled:FALSE];
	[optionsMenu addChild:aboutBox];
	
	BaseElement* progressBox = [self createClearProgressBox];
	[progressBox setEnabled:FALSE];
	[optionsMenu addChild:progressBox];
	return optionsBack;
}

-(void)optionsMenuEnableChild:(int)c
{
	ASSERT(optionsMenu);

	for (int i = 0; i < [optionsMenu childsCount]; i++)
	{
		BaseElement* child = [optionsMenu getChild:i];
		if (child)
		{
			[child setEnabled:i == c];
		}
	}
}

-(BaseElement*)createOptionsBox
{
	VBox* optionsBox = [[VBox allocAndAutorelease] initWithOffset:15 Align:HCENTER Width:260];
	optionsBox->parentAnchor = optionsBox->anchor = TOP | HCENTER;
	optionsBox->y = 20;
	
	Button* babout = [MenuController createButtonWithText:NSLocalizedString(@"STR_BTN_ABOUT", NSLocalizedString(@"STR_TITLE_ABOUT", @"About")) fontID:FNT_FONTS_001 ID:BUTTON_ABOUT Delegate:self color:optionsBlueColor];
	[optionsBox addChild:babout];
	
	Button* bfeedback = [MenuController createButtonWithText:NSLocalizedString(@"STR_BTN_FEEDBACK", @"Finger feedback") fontID:FNT_FONTS_001 ID:BUTTON_FEEDBACK Delegate:self color:optionsBlueColor];
	[optionsBox addChild:bfeedback];
	return optionsBox;
}

-(BaseElement*)createAboutBox
{
	BaseElement* about = [BaseElement create];
	about->width = SCREEN_WIDTH;
	about->height = 300;
	about->anchor = about->parentAnchor = TOP | HCENTER;

	
	Image* backBeyond = [Image createWithResID:IMG_OPTIONS_BACK];
	backBeyond->parentAnchor = backBeyond->anchor = TOP | HCENTER;
	backBeyond->rotation = 5;
	backBeyond->y = -15;
	backBeyond->rotationCenterX = backBeyond->width;
	backBeyond->rotationCenterY = backBeyond->height;
	backBeyond->x = -10;
	[about addChild:backBeyond];
	
	BaseElement* titleBack = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_FEEDBACK", NSLocalizedString(@"STR_FEEDBACK_SUBJECT", @"Finger Feedback")) active:FALSE];
	BaseElement* titleBack2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_FEEDBACK", NSLocalizedString(@"STR_FEEDBACK_SUBJECT", @"Finger Feedback")) active:FALSE];
	Button* bfeedback = [[Button allocAndAutorelease] initWithUpElement:titleBack DownElement:titleBack2 andID:BUTTON_FEEDBACK];
	bfeedback->anchor = bfeedback->parentAnchor = TOP | HCENTER;
	bfeedback->y = 8;
	[bfeedback setTouchIncreaseLeft:40 Right:45 Top:40 Bottom:-26];
	[bfeedback setDelegate:self];
	[backBeyond addChild:bfeedback];
	
	
	Image* backBeyond2 = [Image createWithResID:IMG_OPTIONS_BACK];
	backBeyond2->parentAnchor = backBeyond2->anchor = TOP | HCENTER;
	backBeyond2->rotation = 3;
	backBeyond2->rotationCenterX = backBeyond2->width;
	backBeyond2->rotationCenterY = backBeyond2->height;
	backBeyond2->x = -10;
	[about addChild:backBeyond2];
	
	BaseElement* titleReset = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_CLEAR_PROGRESS", @"Clear progress") active:FALSE];
	BaseElement* titleReset2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_CLEAR_PROGRESS", @"Clear progress") active:FALSE];
	Button* breset = [[Button allocAndAutorelease] initWithUpElement:titleReset DownElement:titleReset2 andID:BUTTON_CLEAR_PROGRESS];
	breset->anchor = breset->parentAnchor = TOP | HCENTER;
	breset->y = 8;
	[breset setTouchIncreaseLeft:40 Right:45 Top:18 Bottom:10];
	[breset setDelegate:self];
	[backBeyond2 addChild:breset];
	
	Image* frontBack = [Image createWithResID:IMG_OPTIONS_BACK];
	frontBack->parentAnchor = frontBack->anchor = TOP | HCENTER;
	frontBack->rotationCenterX = frontBack->width;
	frontBack->rotationCenterY = frontBack->height;
	frontBack->y = 10;
	[about addChild:frontBack];
	
	BaseElement* frontTitleBack = [MenuController createTitle:NSLocalizedString(@"STR_BTN_ABOUT", NSLocalizedString(@"STR_TITLE_ABOUT", @"About")) active:TRUE];
	frontTitleBack->anchor = frontTitleBack->parentAnchor = TOP | HCENTER;
	frontTitleBack->y = 8;
	[frontBack addChild:frontTitleBack];
	
	Text* text = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL]];
	text->color = blackRGBA;
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];	
	NSString* aboutText = FORMAT_STRING(NSLocalizedString(@"STR_MENU_ABOUT_TEXT", @"Finger Physics: Thumb Warsn ver. %@n (build %@)n www.mypressok.comn support@mypressok.comn n (c) 2009 PressOk Entertainment.n Published and developed byn PressOK Entertainment.n PressOK is a registeredn trademark or trademark ofn PressOK Entertainment in then United States and/or n other countries.n Finger Physics is a n trademark of Mobliss, Inc.n n n -= Special Thanks =-n Art:n Maxim Banshchikovn n Level Design:n Natalya Omelyanchuk n n Music:n Pavel "viert" Vorobyovn Angelo Taylorn http://angelotaylor.narod.ru/n n"), version, COMPILATION_TIMESTAMP);
	
	const float TEXT_BOX_WIDTH = 230.0;
	
	[text setAlignment:HCENTER];	
	[text setString:aboutText andWidth:TEXT_BOX_WIDTH];
	
	ScrollableContainer* aboutContainer = [[ScrollableContainer allocAndAutorelease] initWithWidth:TEXT_BOX_WIDTH Height:180
																					ContainerWidth:TEXT_BOX_WIDTH Height:text->height];
	aboutContainer->anchor = TOP | HCENTER;
	aboutContainer->parentAnchor = BOTTOM | HCENTER;
	aboutContainer->y = 10;
	[aboutContainer addChild:text];
	[frontTitleBack addChild:aboutContainer];
	
	Scrollbar* sb = [[Scrollbar allocAndAutorelease] initWithWidth:5 Height:aboutContainer->height Vertical:TRUE];
	[frontTitleBack addChild:sb];
	sb.provider = aboutContainer;
	sb->parentAnchor = BOTTOM | HCENTER;
	sb->anchor = TOP | HCENTER;
	sb->x = aboutContainer->x + aboutContainer->width/2;
	sb->y = aboutContainer->y;
	sb->scrollerColor = scrollerColor;
	sb->backColor = scoresDarkGrayColor;
	
	return about;
}

-(BaseElement*)createFingerFeedbackBox
{
	BaseElement* feedback = [BaseElement create];
	feedback->width = SCREEN_WIDTH;
	feedback->height = 300;
	feedback->anchor = feedback->parentAnchor = TOP | HCENTER;
	
	Image* backBeyond2 = [Image createWithResID:IMG_OPTIONS_BACK];
	backBeyond2->parentAnchor = backBeyond2->anchor = TOP | HCENTER;
	backBeyond2->rotation = 5;
	backBeyond2->rotationCenterX = backBeyond2->width;
	backBeyond2->rotationCenterY = backBeyond2->height;
	backBeyond2->x = -10;
	backBeyond2->y = -15;
	[feedback addChild:backBeyond2];
	
	BaseElement* titleReset = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_CLEAR_PROGRESS", @"Clear progress") active:FALSE];
	BaseElement* titleReset2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_CLEAR_PROGRESS", @"Clear progress") active:FALSE];
	Button* breset = [[Button allocAndAutorelease] initWithUpElement:titleReset DownElement:titleReset2 andID:BUTTON_CLEAR_PROGRESS];
	breset->anchor = breset->parentAnchor = TOP | HCENTER;
	breset->y = 8;
	[breset setTouchIncreaseLeft:40 Right:45 Top:40 Bottom:-26];
	[breset setDelegate:self];
	[backBeyond2 addChild:breset];

	Image* backBeyond = [Image createWithResID:IMG_OPTIONS_BACK];
	backBeyond->parentAnchor = backBeyond->anchor = TOP | HCENTER;
	backBeyond->rotation = 3;
	backBeyond->rotationCenterX = backBeyond->width;
	backBeyond->rotationCenterY = backBeyond->height;
	backBeyond->x = -10;
	[feedback addChild:backBeyond];
	
	BaseElement* titleBack = [MenuController createTitle:NSLocalizedString(@"STR_BTN_ABOUT", NSLocalizedString(@"STR_TITLE_ABOUT", @"About")) active:FALSE];
	BaseElement* titleBack2 = [MenuController createTitle:NSLocalizedString(@"STR_BTN_ABOUT", NSLocalizedString(@"STR_TITLE_ABOUT", @"About")) active:FALSE];
	Button* babout = [[Button allocAndAutorelease] initWithUpElement:titleBack DownElement:titleBack2 andID:BUTTON_ABOUT];
	babout->anchor = babout->parentAnchor = TOP | HCENTER;
	babout->y = 8;
	[babout setTouchIncreaseLeft:40 Right:45 Top:18 Bottom:10];
	[babout setDelegate:self];
	[backBeyond addChild:babout];
	
	Image* frontBack = [Image createWithResID:IMG_OPTIONS_BACK];
	frontBack->parentAnchor = frontBack->anchor = TOP | HCENTER;
	frontBack->rotationCenterX = frontBack->width;
	frontBack->rotationCenterY = frontBack->height;
	frontBack->y = 10;
	[feedback addChild:frontBack];
	
	BaseElement* frontTitleBack = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_FEEDBACK", NSLocalizedString(@"STR_FEEDBACK_SUBJECT", @"Finger Feedback")) active:TRUE];
	frontTitleBack->anchor = frontTitleBack->parentAnchor = TOP | HCENTER;
	frontTitleBack->y = 8;
	[frontBack addChild:frontTitleBack];
	
	Font* font = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
	Text* description = [[Text allocAndAutorelease] initWithFont:font];
	description->parentAnchor = BOTTOM | HCENTER;
	description->anchor = TOP | HCENTER;
	[description setAlignment:LEFT];
	[description setString:NSLocalizedString(@"STR_NEWS_DESCRIPTION", @"If you want to get the news about upcoming game updates and levels you can follow us on these services:") andWidth:210];
	description->color = blackRGBA;
	description->y = 20;
	description->passColorToChilds = FALSE;
	[frontTitleBack addChild:description];
	
	BaseElement* buttonContainer = [BaseElement create];
	buttonContainer->width = frontTitleBack->width;
	buttonContainer->height = 64;	
	[description addChild:buttonContainer];
	buttonContainer->y = 20;
	buttonContainer->parentAnchor = BOTTOM | HCENTER;
	buttonContainer->anchor = TOP | HCENTER;
	
	Texture2D* ttwitter = [ChampionsResourceMgr getResource:IMG_ST_TWITTER];
	Button* btwitter = [MenuController createButtonWithTextureUp:ttwitter Down:ttwitter ID:BUTTON_TWITTER scaleRatio:1.2];	
	btwitter->parentAnchor = btwitter->anchor = TOP | HCENTER;
	[btwitter setDelegate:self];
	[buttonContainer addChild:btwitter];
	
	Texture2D* tfacebook = [ChampionsResourceMgr getResource:IMG_ST_FACEBOOK];
	Button* bfacebook = [MenuController createButtonWithTextureUp:tfacebook Down:tfacebook ID:BUTTON_FACEBOOK scaleRatio:1.2];	
	bfacebook->parentAnchor = bfacebook->anchor = TOP | LEFT;
	bfacebook->x = 10;
	[bfacebook setDelegate:self];
	[buttonContainer addChild:bfacebook];
	
	Texture2D* tmail = [ChampionsResourceMgr getResource:IMG_ST_MAIL];
	Button* bmail = [MenuController createButtonWithTextureUp:tmail Down:tmail ID:BUTTON_MAIL scaleRatio:1.2];	
	bmail->parentAnchor = bmail->anchor = TOP | RIGHT;
	bmail->x = -10;
	[bmail setDelegate:self];
	[buttonContainer addChild:bmail];
	
	return feedback;
}

-(BaseElement*)createClearProgressBox
{
	BaseElement* feedback = [BaseElement create];
	feedback->width = SCREEN_WIDTH;
	feedback->height = 300;
	feedback->anchor = feedback->parentAnchor = TOP | HCENTER;
	
	Image* backBeyond2 = [Image createWithResID:IMG_OPTIONS_BACK];
	backBeyond2->parentAnchor = backBeyond2->anchor = TOP | HCENTER;
	backBeyond2->rotation = 5;
	backBeyond2->rotationCenterX = backBeyond2->width;
	backBeyond2->rotationCenterY = backBeyond2->height;
	backBeyond2->x = -10;
	backBeyond2->y = -15;
	[feedback addChild:backBeyond2];
	
	BaseElement* titleAbout = [MenuController createTitle:NSLocalizedString(@"STR_BTN_ABOUT", NSLocalizedString(@"STR_TITLE_ABOUT", @"About")) active:FALSE];
	BaseElement* titleAbout2 = [MenuController createTitle:NSLocalizedString(@"STR_BTN_ABOUT", NSLocalizedString(@"STR_TITLE_ABOUT", @"About")) active:FALSE];
	Button* babout = [[Button allocAndAutorelease] initWithUpElement:titleAbout DownElement:titleAbout2 andID:BUTTON_ABOUT];
	babout->anchor = babout->parentAnchor = TOP | HCENTER;
	babout->y = 8;
	[babout setTouchIncreaseLeft:40 Right:45 Top:40 Bottom:-26];
	[babout setDelegate:self];
	[backBeyond2 addChild:babout];
	
	Image* backBeyond = [Image createWithResID:IMG_OPTIONS_BACK];
	backBeyond->parentAnchor = backBeyond->anchor = TOP | HCENTER;
	backBeyond->rotation = 3;
	backBeyond->rotationCenterX = backBeyond->width;
	backBeyond->rotationCenterY = backBeyond->height;
	backBeyond->x = -10;
	[feedback addChild:backBeyond];
	
	BaseElement* titleBack = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_FEEDBACK", NSLocalizedString(@"STR_FEEDBACK_SUBJECT", @"Finger Feedback")) active:FALSE];
	BaseElement* titleBack2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_FEEDBACK", NSLocalizedString(@"STR_FEEDBACK_SUBJECT", @"Finger Feedback")) active:FALSE];
	Button* bfeedback = [[Button allocAndAutorelease] initWithUpElement:titleBack DownElement:titleBack2 andID:BUTTON_FEEDBACK];
	bfeedback->anchor = bfeedback->parentAnchor = TOP | HCENTER;
	bfeedback->y = 8;
	[bfeedback setTouchIncreaseLeft:40 Right:45 Top:18 Bottom:10];
	[bfeedback setDelegate:self];
	[backBeyond addChild:bfeedback];
	
	Image* frontBack = [Image createWithResID:IMG_OPTIONS_BACK];
	frontBack->parentAnchor = frontBack->anchor = TOP | HCENTER;
	frontBack->rotationCenterX = frontBack->width;
	frontBack->rotationCenterY = frontBack->height;
	frontBack->y = 10;
	[feedback addChild:frontBack];
	
	BaseElement* frontTitleBack = [MenuController createTitle:@"Clear Progress" active:TRUE];
	frontTitleBack->anchor = frontTitleBack->parentAnchor = TOP | HCENTER;
	frontTitleBack->y = 8;
	[frontBack addChild:frontTitleBack];
	
	Font* font = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
	Text* description = [[Text allocAndAutorelease] initWithFont:font];
	description->parentAnchor = BOTTOM | HCENTER;
	description->anchor = TOP | HCENTER;
	[description setAlignment:LEFT];
	[description setString:NSLocalizedString(@"STR_PROGRESS_DESCRIPTION", @"If you want to clear all statistics and level progress, use button below.") andWidth:210];
	description->color = blackRGBA;
	description->y = 20;
	description->passColorToChilds = FALSE;
	[frontTitleBack addChild:description];
	
	Button* resetData = [MenuController createButtonWithText:NSLocalizedString(@"STR_BTN_RESET_PROGRESS", @"Reset progress") fontID:FNT_FONTS_001 ID:BUTTON_RESET_PROGRESS Delegate:self color:optionsBlueColor];
	resetData->parentAnchor = BOTTOM | HCENTER;
	resetData->anchor = TOP | HCENTER;
	resetData->y = 10;
	[description addChild:resetData];
	
	return feedback;
}

/*
-(void)createHelp
{
	MenuView* view = [[MenuView allocAndAutorelease] initFullscreen];
	Image* menuBackground = [MenuController createBackground];

	const int HELP_SCREEN_IDS[] = {IMG_HELP_SCREEN1, IMG_HELP_SCREEN2, IMG_HELP_SCREEN1, IMG_HELP_SCREEN2, IMG_HELP_SCREEN1, IMG_HELP_SCREEN2};
	const int HELP_SCREENS_COUNT = sizeof(HELP_SCREEN_IDS) / sizeof(int);
	
	Image* helps[HELP_SCREENS_COUNT];

	for (int i = 0; i < HELP_SCREENS_COUNT; i++)
	{
		helps[i] = [Image create:[ChampionsResourceMgr getResource:HELP_SCREEN_IDS[i]]];
		if (i > 0)
		{
			helps[i]->x = helps[i - 1]->x + helps[i - 1]->width;
		}
	}
	
	helpContainer = [[ScrollableContainer allocAndAutorelease] initWithWidth:helps[0]->width Height:helps[0]->height 
				    ContainerWidth:(helps[HELP_SCREENS_COUNT - 1]->x + helps[HELP_SCREENS_COUNT - 1]->width) Height:helps[0]->height];
	
	[helpContainer turnScrollPointsOnWithCapacity:HELP_SCREENS_COUNT];
	for (int i = 0; i < HELP_SCREENS_COUNT; i++)
	{
		[helpContainer addScrollPointAtX:helps[i]->x Y:0.0];
		[helpContainer addChild:helps[i]];
	}


	helpContainer->x = 30.0;
	helpContainer->y = 80.0;

	
	[menuBackground addChild:helpContainer];
	
	BulletScrollbar* helpDotsContainer = [[BulletScrollbar allocAndAutorelease] 
										   initWithBulletTexture:[ChampionsResourceMgr getResource:IMG_BULLETS] andTotalBullets:HELP_SCREENS_COUNT];

	helpDotsContainer.provider = helpContainer;
	
	helpDotsContainer->parentAnchor = helpDotsContainer->anchor = TOP | HCENTER;
	helpDotsContainer->y = helpContainer->y + helpContainer->height + 20.0;
	[menuBackground addChild:helpDotsContainer];
	
	Button* backb = [MenuController createBackButtonWithDelegate:self];
	[menuBackground addChild:backb];	
	
	[view addChild:menuBackground];	
	[self addView:view withID:VIEW_HELP];	
}
	
-(void)createAbout
{
	MenuView* view = [[MenuView allocAndAutorelease] initFullscreen];
	Image* menuBackground = [MenuController createBackground];

	Text* text = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_SMALL_FONT]];

	NSString* path = [[NSBundle mainBundle] bundlePath];
	NSString* finalPath = [path stringByAppendingPathComponent:@"Info.plist"];
	NSDictionary* plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];		
	NSString* version = (NSString*)[plistDictionary objectForKey:@"CFBundleVersion"];	
	
	NSString* aboutText = FORMAT_STRING(NSLocalizedString(@"STR_MENU_ABOUT_TEXT", @"Finger Physics: Thumb Warsn ver. %@n (build %@)n www.mypressok.comn support@mypressok.comn n (c) 2009 PressOk Entertainment.n Published and developed byn PressOK Entertainment.n PressOK is a registeredn trademark or trademark ofn PressOK Entertainment in then United States and/or n other countries.n Finger Physics is a n trademark of Mobliss, Inc.n n n -= Special Thanks =-n Art:n Maxim Banshchikovn n Level Design:n Natalya Omelyanchuk n n Music:n Pavel "viert" Vorobyovn Angelo Taylorn http://angelotaylor.narod.ru/n n"), version, COMPILATION_TIMESTAMP);
	
	const float TEXT_BOX_WIDTH = 270.0;

	[text setAlignment:HCENTER];	
	[text setString:aboutText andWidth:TEXT_BOX_WIDTH];
	
	aboutContainer = [[ScrollableContainer allocAndAutorelease] initWithWidth:TEXT_BOX_WIDTH Height:210.0 	
							   ContainerWidth:TEXT_BOX_WIDTH Height:text->height];

	aboutContainer->x = 30.0;
	aboutContainer->y = 120.0;

	[aboutContainer addChild:text];		

	[menuBackground addChild:aboutContainer];
	
	Scrollbar* sb = [[Scrollbar allocAndAutorelease] initWithWidth:10.0 Height:aboutContainer->height Vertical:TRUE];
	sb.provider = aboutContainer;

	sb->x = aboutContainer->x + aboutContainer->width + 10.0;	
	sb->y = aboutContainer->y;
	[menuBackground addChild:sb];

	Button* backb = [MenuController createBackButtonWithDelegate:self];
	[menuBackground addChild:backb];	
	
	[view addChild:menuBackground];	
	[self addView:view withID:VIEW_ABOUT];	
}	
*/

-(void)createRegistration
{
	MenuView* view = [[MenuView allocAndAutorelease] initFullscreen];
	
	Image* bottom = [Image createWithResID:IMG_MAIN_OLD_OBJECTS_BACK];
	bottom->parentAnchor = bottom->anchor = HCENTER | BOTTOM;
	[view addChild:bottom];

	Image* back = [Image createWithResID:IMG_MAIN_BACK];
	back->parentAnchor = back->anchor = HCENTER | TOP;
	[view addChild:back];
	
	Image* front = [Image createWithResID:IMG_REGSCREEN_BACK];
	front->parentAnchor = front->anchor = CENTER;
	[view addChild:front];

	Image* photoFrame = [Image createWithResID:IMG_REGSCREEN_BACK_PHOTO];
	photoFrame->parentAnchor = photoFrame->anchor = TOP | LEFT;
	photoFrame->x = 8;
	[front addChild:photoFrame];
	
	Image* avatar = [MenuController loadAvatar];
	if(avatar)
	{
		avatar->rotation = -12;
		avatar->parentAnchor = avatar->anchor = TOP | LEFT;
		float maxSideSize = MIN(avatar->height, avatar->width);
		float scaleRatio = MAX_AVATAR_SIZE / maxSideSize;
//		float offsetX = round((MAX_AVATAR_SIZE - (avatar->width*scaleRatio))/2);
//		float offsetY = round((MAX_AVATAR_SIZE - (avatar->height*scaleRatio))/2);
//		avatar->y = 19+offsetY;
//		avatar->x = 12+offsetX;
		
		avatar->rotationCenterX = -avatar->width/2;
		avatar->rotationCenterY = -avatar->height/2;
		avatar->scaleX = avatar->scaleY = scaleRatio;
		[photoFrame addChild:avatar];
	}
	
	Image* pin = [Image createWithResID:IMG_PIN_BLUE];
	pin->parentAnchor = TOP | RIGHT;
	pin->anchor = TOP | HCENTER;
	pin->x = -27;
	[photoFrame addChild:pin];
	
	Image* labelBack = [Image createWithResID:IMG_REGSCREEN_BACK_NAME];
	labelBack->parentAnchor = VCENTER | RIGHT;
	labelBack->anchor = BOTTOM | LEFT;
	labelBack->x = -4;
	[photoFrame addChild:labelBack];

 	NSString* name = NSLocalizedString(@"STR_UNKNOWN_USER", @"Unknown");
	ChampionsRootController* rc =(ChampionsRootController*)[Application sharedRootController];
	FPUser* user = [[FPUser alloc] init];
	[user setDefaults];
	if(rc)
	{
		if(rc.user)
		{
			[user release];
			user = rc.user;
			[user retain];
			name = user.name;
		}
	}

	CGSize size = CGSizeMake(SCREEN_WIDTH, 25);
	Texture2D* ttext = [[[Texture2D alloc] initWithString:name dimensions:size alignment:UITextAlignmentLeft fontName:@"HelveticaNeue" fontSize:20] autorelease];
	AlternateImage* text = (AlternateImage*)[AlternateImage create:ttext];
	text.mode = MODE_GL_SRC_ALPHA_GL_ONE_MINUS_SRC_ALPHA;
	text->parentAnchor = TOP | LEFT;
	text->color = darkBlueColor;
	text->x = 4;
	text->rotationCenterX = -size.width/2;
	text->scaleX = 0.75;
	text->passColorToChilds = FALSE;
	text->passTransformationsToChilds = FALSE;
	[labelBack addChild:text];
	
	Text* label = [Text createWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL] andString:NSLocalizedString(@"STR_TAKE_FROM_OPENFEINT", @"Taken from the OpenFeint login")];
	label->rotationCenterX = -label->width/2;
	label->rotationCenterY = -label->height/2;
	label->scaleX = label->scaleY = 0.75;
	label->parentAnchor = BOTTOM | LEFT;
	label->anchor = TOP | LEFT;
	label->color = darkGrayColor;
	label->x = 5;
	[text addChild:label];
	
	Button* ofbutton = [[[Button alloc] initWithID:BUTTON_OPENFEINT] autorelease];
	ofbutton->width = SCREEN_WIDTH;
	ofbutton->height = 80;
	ofbutton->parentAnchor = ofbutton->anchor = TOP | HCENTER;
	[ofbutton setDelegate:self];
	[front addChild:ofbutton];
	
	HBox* box = [[[HBox alloc] initWithOffset:30 Align:VCENTER Height:100] autorelease];
	box->parentAnchor = box->anchor = BOTTOM | HCENTER;
	[front addChild:box];

	Texture2D* tok = [ChampionsResourceMgr getResource:IMG_REGSCREEN_OK];
	Button* bok = [MenuController createButtonWithTextureUp:tok Down:tok ID:BUTTON_REGISTRATION_OK scaleRatio:1.2];
	bok.delegate = self;
	[box addChild:bok];

	Texture2D* tcancel = [ChampionsResourceMgr getResource:IMG_REGSCREEN_CANCEL];
	Button* bcancel = [MenuController createButtonWithTextureUp:tcancel Down:tcancel ID:BUTTON_REGISTRATION_CANCEL scaleRatio:1.2];
	bcancel.delegate = self;
	[box addChild:bcancel];
	
	BaseElement* first_screen = [[BaseElement allocAndAutorelease] init];
	first_screen->width = 300;
	first_screen->height = 290;
	first_screen->parentAnchor = first_screen->anchor = TOP | HCENTER;
	first_screen->y = 105;
	[front addChild:first_screen];
	
	Font* small_font = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
	float yoffset = 0;
	
	Text* idleText = [[Text allocAndAutorelease] initWithFont:small_font];
	idleText->parentAnchor = idleText->anchor = TOP | HCENTER;
	idleText->color = darkBlueColor;
	[idleText setString:STRING_REGISTRATION_INSPIRING_TEXT andWidth:first_screen->width - 50];
	[first_screen addChild:idleText];
	yoffset += idleText->height + 10;
	
	if([MenuController isCountryInEu:user.countryId])
	{
		//Image* region_box = [Image createWithResID:IMG_BIG_LINE];
		ColoredLayer* region_box = [ColoredLayer create];
		region_box->width = 198;
		region_box->height = 56;
		region_box->parentAnchor = region_box->anchor = TOP | HCENTER;
		region_box->color = grayColor;
		region_box->passColorToChilds = FALSE;
		region_box->y = yoffset;
		[first_screen addChild:region_box];
		
		Text* regionLabel = [[Text allocAndAutorelease] initWithFont:small_font];
		[regionLabel setString:NSLocalizedString(@"STR_REGION_LABEL", @"Your region") andWidth:SCREEN_WIDTH];
		regionLabel->parentAnchor = regionLabel->anchor = TOP | LEFT;
		regionLabel->x = 4;
		[region_box addChild:regionLabel];
		yoffset += region_box->height + 10;
		
		//Image* region_field = [Image createWithResID:IMG_SMALL_LINE];
		ColoredLayer* region_field = [ColoredLayer create];
		region_field->width = 196;
		region_field->height = 34;
		region_field->parentAnchor = region_field->anchor = BOTTOM | HCENTER;
		region_field->y = -1;
		region_field->color = lightGrayColor;
		[region_box addChild:region_field];
		
		Text* countryText = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL]];
		countryText->color = darkBlueColor;
		[countryText setString:NSLocalizedString(@"STR_EU", @"European Union") andWidth:SCREEN_WIDTH];
		countryText->anchor = countryText->parentAnchor = VCENTER | LEFT;
		countryText->x = 4;
		[region_field addChild:countryText];
		

		NSString* path = [[NSBundle mainBundle] pathForResource:@"European-Union-Flag-32" ofType:@"png" inDirectory:@"flags"];
		if(path)
		{
			UIImage* image = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
			Texture2D* tflag = [[[Texture2D alloc] initWithImage:image] autorelease];
			Image* flag = [Image create:tflag];
			flag->parentAnchor = flag->anchor = VCENTER | LEFT;
			flag->x = 4;
			countryText->x = flag->width + 8;
			[region_field addChild:flag];			
		}
	}
	
	//Image* country_box = [Image createWithResID:IMG_BIG_LINE];
	ColoredLayer* country_box = [ColoredLayer create];
	country_box->width = 198;
	country_box->height = 56;
	country_box->parentAnchor = country_box->anchor = TOP | HCENTER;
	country_box->color = lightBlueColor;
	country_box->passColorToChilds = FALSE;
	country_box->y = yoffset;
	[first_screen addChild:country_box];
	
	Text* countryLabel = [[Text allocAndAutorelease] initWithFont:small_font];
	[countryLabel setString:NSLocalizedString(@"STR_CONTRY_LABEL", @"Your country") andWidth:SCREEN_WIDTH];
	countryLabel->parentAnchor = countryLabel->anchor = TOP | LEFT;
	countryLabel->x = 4;
	[country_box addChild:countryLabel];
	
	int cId = [MenuController getCountryById:user.countryId];
	if(cId == 0)
		country_box->color = dirtRedColor;
	BaseElement* country_field = [MenuController createCountryEntryForId:cId custom:TRUE];
	country_field->parentAnchor = country_field->anchor = BOTTOM | HCENTER;
	country_field->y = -1;
	country_field->color = lightGrayColor;
	[country_box addChild:country_field];
		
	Texture2D* tedit = [ChampionsResourceMgr getResource:IMG_SELECT_LEVEL_OPEN_ARROW];
	Button* edit = [MenuController createButtonWithTextureUp:tedit Down:tedit ID:BUTTON_REGISTRATION_EDIT scaleRatio:1.2];
	edit->parentAnchor = VCENTER | RIGHT;
	edit->anchor = VCENTER | LEFT;
	edit->x = 10;
	[edit setDelegate:self];
	[edit setTouchIncreaseLeft:country_box->width+10 Right:0 Top:country_box->height/2 Bottom:country_box->height/2];
	[country_box addChild:edit];
	
	yoffset += country_box->height + 10;

	if(user && user.countryId == 1)
	{
//		Image* state_box = [Image createWithResID:IMG_BIG_LINE];
		ColoredLayer* state_box = [ColoredLayer create];
		state_box->width = 198;
		state_box->height = 56;
		state_box->parentAnchor = state_box->anchor = TOP | HCENTER;
		state_box->color = lightBlueColor;
		state_box->passColorToChilds = FALSE;
		state_box->y = yoffset;
		[first_screen addChild:state_box];
		
		Text* stateLabel = [[Text allocAndAutorelease] initWithFont:small_font];
		[stateLabel setString:NSLocalizedString(@"STR_STATE_LABEL", @"Your state") andWidth:SCREEN_WIDTH];
		stateLabel->parentAnchor = countryLabel->anchor = TOP | LEFT;
		stateLabel->x = 4;
		[state_box addChild:stateLabel];

		int sId = [MenuController getStateById:user.stateId];
		if(sId == 0)
			state_box->color = dirtRedColor;
		BaseElement* state_field = [MenuController createStateEntryForId:sId custom:TRUE];//[Image createWithResID:IMG_SMALL_LINE];
		state_field->parentAnchor = state_field->anchor = BOTTOM | HCENTER;
		state_field->y = -1;
		state_field->color = lightGrayColor;
		[state_box addChild:state_field];
		
		Texture2D* tsedit = [ChampionsResourceMgr getResource:IMG_SELECT_LEVEL_OPEN_ARROW];
		Button* sedit = [MenuController createButtonWithTextureUp:tsedit Down:tsedit ID:BUTTON_STATE_EDIT scaleRatio:1.2];
		sedit->parentAnchor = VCENTER | RIGHT;
		sedit->anchor = VCENTER | LEFT;
		sedit->x = 10;
		[sedit setDelegate:self];
		[sedit setTouchIncreaseLeft:state_box->width+10 Right:0 Top:state_box->height/2 Bottom:state_box->height/2];
		[state_box addChild:sedit];
		yoffset += state_box->height + 10;
	}
	
	Text* idleText2 = [[Text allocAndAutorelease] initWithFont:small_font];
	idleText2->color = darkGrayColor;
	idleText2->parentAnchor = idleText2->anchor = TOP | HCENTER;
	idleText2->y = yoffset;
	[idleText2 setString:NSLocalizedString(@"STR_INFO_TEXT", @"You can change this information at any time by clicking your avatar in main menu.") andWidth:first_screen->width-50];
	[first_screen addChild:idleText2];
	
	[self addView:view withID:VIEW_REGISTRATION];
	[user release];
}

-(void)createCountryList
{
	MenuView* view = [[MenuView allocAndAutorelease] initFullscreen];
	
	Image* bottom = [Image createWithResID:IMG_MAIN_OLD_OBJECTS_BACK];
	bottom->parentAnchor = bottom->anchor = HCENTER | BOTTOM;
	[view addChild:bottom];
	
	Image* back = [Image createWithResID:IMG_MAIN_BACK];
	back->parentAnchor = back->anchor = HCENTER | TOP;
	[view addChild:back];
	
	Image* front = [Image createWithResID:IMG_REGSCREEN_BACK];
	front->parentAnchor = front->anchor = CENTER;
	[view addChild:front];
	
	Image* labelBack = [Image createWithResID:IMG_REGSCREEN_BACK_NAME];
	labelBack->parentAnchor = labelBack->anchor = TOP | LEFT;
	labelBack->x = 50;
	labelBack->y = 30;
	[front addChild:labelBack];

	Text* text = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL]];
	[text setString:NSLocalizedString(@"STR_SELECT_COUNTRY", @"Select your country.") andWidth:200];
	text->color = darkBlueColor;
	text->anchor = text->parentAnchor = LEFT | VCENTER;
	[labelBack addChild:text];
	
	ChampionsRootController* rc =(ChampionsRootController*)[Application sharedRootController];
	FPUser* user = [[FPUser alloc] init];
	[user setDefaults];
	if(rc)
	{
		if(rc.user)
		{
			[user release];
			user = rc.user;
			[user retain];
		}
	}
	
	HBox* box = [[[HBox alloc] initWithOffset:30 Align:VCENTER Height:100] autorelease];
	box->parentAnchor = box->anchor = BOTTOM | HCENTER;
	[front addChild:box];
	
//	Texture2D* tcancel = [ChampionsResourceMgr getResource:IMG_REGSCREEN_CANCEL];
//	Button* bcancel = [MenuController createButtonWithTextureUp:tcancel Down:tcancel ID:BUTTON_COUNTRY_CANCEL scaleRatio:1.2];
//	bcancel.delegate = self;
//	[box addChild:bcancel];

	BaseElement* first_screen = [[BaseElement allocAndAutorelease] init];
	first_screen->width = 300;
	first_screen->height = 320;
	first_screen->parentAnchor = first_screen->anchor = TOP | HCENTER;
	first_screen->y = 70;
	[front addChild:first_screen];
	
	Font* small_font = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
	Text* idleText = [[Text allocAndAutorelease] initWithFont:small_font];
	idleText->parentAnchor = idleText->anchor = TOP | HCENTER;
	idleText->color = darkBlueColor;
	[idleText setString:STRING_REGISTRATION_INSPIRING_TEXT andWidth:first_screen->width - 50];
	[first_screen addChild:idleText];	
	float yoffset = idleText->height + 20;

	int entryHeight = FLAG_HEIGHT+8+7;
	ScrollableContainer* countryList = [[ScrollableContainer allocAndAutorelease]
										initWithWidth:200 Height:MAX_COUNTRY_ENTRY_ON_SCREEN*entryHeight ContainerWidth:200
										Height:entryHeight*(COUNTRIES_COUNT-1)];
	countryList->canSkipScrollPoints = TRUE;
	[countryList turnScrollPointsOnWithCapacity:COUNTRIES_COUNT];
	
	for (int i = 1; i < COUNTRIES_COUNT; i++)
	{
		BaseElement* entry = [MenuController createCountryEntryForId:i custom:FALSE];
		BaseElement* entry2 = [MenuController createCountryEntryForId:i custom:FALSE];
		entry2->scaleX = entry2->scaleY = 1.2;
		AlternateButton* bentry = [[AlternateButton allocAndAutorelease]
								   initWithUpElement:entry DownElement:entry2 andID:BUTTON_COUNTRY_SELECT];
		[bentry setDelegate:self];
		[bentry setName:FORMAT_STRING(@"%i", countries[i].cId)];
		bentry->y = entryHeight*(i-1);
		[countryList addChild:bentry];
		[countryList addScrollPointAtX:0 Y:bentry->y];
	}
	countryList->parentAnchor = countryList->anchor = TOP | HCENTER;
	countryList->y = yoffset;
	[first_screen addChild:countryList];
	[self addView:view withID:VIEW_COUNTRY_LIST];
	[user release];
	
	Scrollbar* sb = [[Scrollbar allocAndAutorelease] initWithWidth:5 Height:countryList->height Vertical:TRUE];
	sb.provider = countryList;
	sb->x = countryList->x + countryList->width/2 + sb->width/2 + 20;
	sb->y = countryList->y;
	sb->anchor = sb->parentAnchor = TOP | HCENTER;
	sb->scrollerColor = scrollerColor;
	sb->backColor = scoresDarkGrayColor;
	
	[first_screen addChild:sb];
}

-(void)createStateList
{
	MenuView* view = [[[MenuView alloc] initFullscreen] autorelease];
	
	Image* bottom = [Image createWithResID:IMG_MAIN_OLD_OBJECTS_BACK];
	bottom->parentAnchor = bottom->anchor = HCENTER | BOTTOM;
	[view addChild:bottom];
	
	Image* back = [Image createWithResID:IMG_MAIN_BACK];
	back->parentAnchor = back->anchor = HCENTER | TOP;
	[view addChild:back];
	
	Image* front = [Image createWithResID:IMG_REGSCREEN_BACK];
	front->parentAnchor = front->anchor = CENTER;
	[view addChild:front];
	
	Image* labelBack = [Image createWithResID:IMG_REGSCREEN_BACK_NAME];
	labelBack->parentAnchor = labelBack->anchor = TOP | LEFT;
	labelBack->x = 50;
	labelBack->y = 30;
	[front addChild:labelBack];
	
	Text* text = [[Text allocAndAutorelease] initWithFont:[ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL]];
	[text setString:NSLocalizedString(@"STR_SELECT_STATE", @"Select your state.") andWidth:200];
	text->color = darkBlueColor;
	text->anchor = text->parentAnchor = LEFT | VCENTER;
	text->x = 4;
	[labelBack addChild:text];
	
	ChampionsRootController* rc =(ChampionsRootController*)[Application sharedRootController];
	FPUser* user = [[FPUser alloc] init];
	[user setDefaults];
	if(rc)
	{
		if(rc.user)
		{
			[user release];
			user = rc.user;
			[user retain];
		}
	}
	
	HBox* box = [[[HBox alloc] initWithOffset:30 Align:VCENTER Height:100] autorelease];
	box->parentAnchor = box->anchor = BOTTOM | HCENTER;
	[front addChild:box];
	
	Texture2D* tcancel = [ChampionsResourceMgr getResource:IMG_REGSCREEN_CANCEL];
	Button* bcancel = [MenuController createButtonWithTextureUp:tcancel Down:tcancel ID:BUTTON_STATE_CANCEL scaleRatio:1.2];
	bcancel.delegate = self;
	[box addChild:bcancel];
	
	BaseElement* first_screen = [[BaseElement allocAndAutorelease] init];
	first_screen->width = 300;
	first_screen->height = 320;
	first_screen->parentAnchor = first_screen->anchor = TOP | HCENTER;
	first_screen->y = 70;
	[front addChild:first_screen];
	
	Font* small_font = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
	Text* idleText = [[Text allocAndAutorelease] initWithFont:small_font];
	idleText->parentAnchor = idleText->anchor = TOP | HCENTER;
	idleText->color = darkBlueColor;
	[idleText setString:STRING_REGISTRATION_INSPIRING_TEXT andWidth:first_screen->width - 50];
	[first_screen addChild:idleText];	
	float yoffset = idleText->height + 20;
	
	int entryHeight = FLAG_HEIGHT+8+7;
	ScrollableContainer* stateList = [[ScrollableContainer allocAndAutorelease]
										initWithWidth:200 Height:MAX_STATE_ENTRY_ON_SCREEN*entryHeight ContainerWidth:200
										Height:entryHeight*(STATES_COUNT-1)];
	stateList->canSkipScrollPoints = TRUE;
	[stateList turnScrollPointsOnWithCapacity:STATES_COUNT];
	
	for (int i = 1; i < STATES_COUNT; i++)
	{
		BaseElement* entry = [MenuController createStateEntryForId:i custom:FALSE];
		BaseElement* entry2 = [MenuController createStateEntryForId:i custom:FALSE];
		entry2->scaleX = entry2->scaleY = 1.2;
		AlternateButton* bentry = [[AlternateButton allocAndAutorelease]
								   initWithUpElement:entry DownElement:entry2 andID:BUTTON_STATE_SELECT];
		[bentry setDelegate:self];
		[bentry setName:FORMAT_STRING(@"%i", states[i].cId)];
		bentry->y = entryHeight*(i-1);
		[stateList addChild:bentry];
		[stateList addScrollPointAtX:0 Y:bentry->y];
	}
	stateList->parentAnchor = stateList->anchor = TOP | HCENTER;
	stateList->y = yoffset;
	[first_screen addChild:stateList];
	[self addView:view withID:VIEW_STATE_LIST];
	[user release];
	
	Scrollbar* sb = [[Scrollbar allocAndAutorelease] initWithWidth:5 Height:stateList->height Vertical:TRUE];
	sb.provider = stateList;
	sb->x = stateList->x + stateList->width/2 + sb->width/2 + 20;
	sb->y = stateList->y;
	sb->anchor = sb->parentAnchor = TOP | HCENTER;
	sb->scrollerColor = scrollerColor;
	sb->backColor = scoresDarkGrayColor;
	
	[first_screen addChild:sb];
}

#pragma mark -

+(BaseElement*)createScoreEntry:(NSString*)name rank:(NSString*)rank points:(NSString*)points countryId:(int)cId userId:(NSString*)userId
{
	
//	NSLog(@"%@ rank=%@ points=%@ userId=%@", name, rank, points, userId);
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	ColoredLayer* nameBack = [ColoredLayer create];
	nameBack->width = 200;
	nameBack->height = 20 + 2 + FLAG_HEIGHT;
	if(rc && rc.user && [userId isEqualToString:rc.user.userId])
	{
		nameBack->color = lightBlueColor;
	}
	else
	{
		nameBack->color = scoresDarkGrayColor;
	}
	nameBack->passColorToChilds = FALSE;

	int leftOffset = 2;
	int rightOffset = 5;
	
	CGSize size = CGSizeMake(SCREEN_WIDTH, 20);
	Texture2D* tuserName = [[[Texture2D alloc] initWithString:name dimensions:size alignment:UITextAlignmentLeft fontName:@"HelveticaNeue" fontSize:16] autorelease];
	AlternateImage* userName = (AlternateImage*)[AlternateImage create:tuserName];
	userName->color = blackRGBA;
	userName->rotationCenterX = -size.width/2;
	userName->scaleX = 0.75;
	userName.mode = MODE_GL_SRC_ALPHA_GL_ONE_MINUS_SRC_ALPHA;
	userName->parentAnchor = userName->anchor = TOP | LEFT;
	userName->x = leftOffset+FLAG_WIDTH+rightOffset;
	[nameBack addChild:userName];

	Font* font = [ChampionsResourceMgr getResource:FNT_FONTS_001];
	Text* rankText = [[[Text alloc] initWithFont:font] autorelease];
	rankText->parentAnchor = rankText->anchor = TOP | RIGHT;
	float width = [font stringWidth:rank];
	[rankText setString:rank andWidth:width];
	rankText->x = -4;
	rankText->y = -6;
	[nameBack addChild:rankText];
	
	ColoredLayer* scoreBack = [ColoredLayer create];
	scoreBack->width = 200;
	scoreBack->height = FLAG_HEIGHT+2;
	scoreBack->color = scoresLightGrayColor;
	scoreBack->parentAnchor = BOTTOM | HCENTER;
	scoreBack->anchor = BOTTOM | HCENTER;
	[nameBack addChild:scoreBack];
	
	Image* flag = [MenuController createFlag:cId];
	if(flag)
	{
		flag->anchor = flag->parentAnchor = VCENTER | LEFT;
		flag->x = leftOffset;
		[scoreBack addChild:flag];
	}
	
	Font* font_small = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
	Text* scoreText = [[[Text alloc] initWithFont:font_small] autorelease];
	scoreText->parentAnchor = scoreText->anchor = VCENTER | LEFT;
	[scoreText setString:NSLocalizedString(@"STR_SCORE_TEXT", @"Score:") andWidth:80];
	[scoreBack addChild:scoreText];
	scoreText->color = darkBlueColor;
	scoreText->x = leftOffset+FLAG_WIDTH+rightOffset;
	scoreText->passColorToChilds = FALSE;
	
	Text* userScore = [[[Text alloc] initWithFont:font_small] autorelease];
	userScore->parentAnchor = RIGHT | VCENTER;
	userScore->anchor = LEFT | VCENTER;
	float pointsWidth = [font_small stringWidth:points];
	[userScore setString:points andWidth:pointsWidth];
	userScore->color = blackRGBA;
	[scoreText addChild:userScore];
	
	return nameBack;
}

+(BaseElement*)createCountryScoreEntry:(int)countryId rank:(int)rank points:(NSString*)points
{
//	NSLog(@"%i rank=%i points=%@", countryId, rank, points);
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	ColoredLayer* nameBack = [ColoredLayer create];
	nameBack->width = 200;
	nameBack->height = 20 + 2 + FLAG_HEIGHT;
	
	if(rc && rc.user && countryId > 0 && countryId == rc.user.countryId)
	{
		nameBack->color = lightBlueColor;
	}
	else
	{
		nameBack->color = scoresDarkGrayColor;
	}
	nameBack->passColorToChilds = FALSE;
	
	int leftOffset = 2;
	int rightOffset = 5;
	
	CGSize size = CGSizeMake(200, 20);
	
	int countryIndex = [MenuController getCountryById:countryId];
	Texture2D* tuserName = [[[Texture2D alloc] initWithString:countries[countryIndex].name dimensions:size alignment:UITextAlignmentLeft fontName:@"HelveticaNeue" fontSize:16] autorelease];
	AlternateImage* userName = (AlternateImage*)[AlternateImage create:tuserName];
	userName->color = blackRGBA;
	userName->rotationCenterX = -size.width/2;
	userName->scaleX = 0.75;
	userName.mode = MODE_GL_SRC_ALPHA_GL_ONE_MINUS_SRC_ALPHA;
	userName->parentAnchor = userName->anchor = TOP | LEFT;
	userName->x = leftOffset+FLAG_WIDTH+rightOffset;
	[nameBack addChild:userName];
	
	Font* font = [ChampionsResourceMgr getResource:FNT_FONTS_001];
	Text* rankText = [[[Text alloc] initWithFont:font] autorelease];
	rankText->parentAnchor = rankText->anchor = TOP | RIGHT;
	NSString* rankStr = FORMAT_STRING(@"%i", rank);
	float width = [font stringWidth:rankStr];
	[rankText setString:rankStr andWidth:width];
	rankText->x = -4;
	rankText->y = -6;
	[nameBack addChild:rankText];
	
	ColoredLayer* scoreBack = [ColoredLayer create];
	scoreBack->width = 200;
	scoreBack->height = FLAG_HEIGHT+2;
	scoreBack->color = scoresLightGrayColor;
	scoreBack->parentAnchor = BOTTOM | HCENTER;
	scoreBack->anchor = BOTTOM | HCENTER;
	[nameBack addChild:scoreBack];
	
	Image* flag = [MenuController createFlag:countryId];
	if(flag)
	{
		flag->anchor = flag->parentAnchor = VCENTER | LEFT;
		flag->x = leftOffset;
		[scoreBack addChild:flag];
	}
	
	Font* font_small = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
	Text* scoreText = [[[Text alloc] initWithFont:font_small] autorelease];
	scoreText->parentAnchor = scoreText->anchor = VCENTER | LEFT;
	[scoreText setString:NSLocalizedString(@"STR_SCORE_TEXT", @"Score:") andWidth:80];
	[scoreBack addChild:scoreText];
	scoreText->color = darkBlueColor;
	scoreText->x = leftOffset+FLAG_WIDTH+rightOffset;
	scoreText->passColorToChilds = FALSE;
	
	Text* userScore = [[[Text alloc] initWithFont:font_small] autorelease];
	userScore->parentAnchor = RIGHT | VCENTER;
	userScore->anchor = LEFT | VCENTER;
	float pointsWidth = [font_small stringWidth:points];
	[userScore setString:points andWidth:pointsWidth];
	userScore->color = blackRGBA;
	[scoreText addChild:userScore];
	
	return nameBack;	
}

+(BaseElement*)createStateScoreEntry:(int)stateId rank:(int)rank points:(NSString*)points
{
	
//	NSLog(@"%i rank=%i points=%@", stateId, rank, points );
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	ColoredLayer* nameBack = [ColoredLayer create];
	nameBack->width = 200;
	nameBack->height = 20 + 2 + FLAG_HEIGHT;
	
//	int stateId = [MenuController getStateIdByName:name];
	
	if(rc && rc.user && stateId > 0 && stateId == rc.user.stateId)
	{
		nameBack->color = lightBlueColor;
	}
	else
	{
		nameBack->color = scoresDarkGrayColor;
	}
	nameBack->passColorToChilds = FALSE;
	
	int leftOffset = 2;
	int rightOffset = 5;
	
	CGSize size = CGSizeMake(200, 20);
	
	int stateIndex = [MenuController getStateById:stateId];
	Texture2D* tuserName = [[[Texture2D alloc] initWithString:states[stateIndex].name dimensions:size alignment:UITextAlignmentLeft fontName:@"HelveticaNeue" fontSize:16] autorelease];
	AlternateImage* userName = (AlternateImage*)[AlternateImage create:tuserName];
	userName->color = blackRGBA;
	userName->rotationCenterX = -size.width/2;
	userName->scaleX = 0.75;
	userName.mode = MODE_GL_SRC_ALPHA_GL_ONE_MINUS_SRC_ALPHA;
	userName->parentAnchor = userName->anchor = TOP | LEFT;
	userName->x = leftOffset+FLAG_WIDTH+rightOffset;
	[nameBack addChild:userName];
	
	Font* font = [ChampionsResourceMgr getResource:FNT_FONTS_001];
	Text* rankText = [[[Text alloc] initWithFont:font] autorelease];
	rankText->parentAnchor = rankText->anchor = TOP | RIGHT;
	NSString* rankStr = FORMAT_STRING(@"%i", rank);
	float width = [font stringWidth:rankStr];
	[rankText setString:rankStr andWidth:width];
	rankText->x = -4;
	rankText->y = -6;
	[nameBack addChild:rankText];
	
	ColoredLayer* scoreBack = [ColoredLayer create];
	scoreBack->width = 200;
	scoreBack->height = FLAG_HEIGHT+2;
	scoreBack->color = scoresLightGrayColor;
	scoreBack->parentAnchor = BOTTOM | HCENTER;
	scoreBack->anchor = BOTTOM | HCENTER;
	[nameBack addChild:scoreBack];
	
	Image* flag = [MenuController createStateFlag:stateId];
	if(flag)
	{
		flag->anchor = flag->parentAnchor = VCENTER | LEFT;
		flag->x = leftOffset;
		[scoreBack addChild:flag];
	}
	
	Font* font_small = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
	Text* scoreText = [[[Text alloc] initWithFont:font_small] autorelease];
	scoreText->parentAnchor = scoreText->anchor = VCENTER | LEFT;
	[scoreText setString:NSLocalizedString(@"STR_SCORE_TEXT", @"Score:") andWidth:80];
	[scoreBack addChild:scoreText];
	scoreText->color = darkBlueColor;
	scoreText->x = leftOffset+FLAG_WIDTH+rightOffset;
	scoreText->passColorToChilds = FALSE;
	
	Text* userScore = [[[Text alloc] initWithFont:font_small] autorelease];
	userScore->parentAnchor = RIGHT | VCENTER;
	userScore->anchor = LEFT | VCENTER;
	float pointsWidth = [font_small stringWidth:points];
	[userScore setString:points andWidth:pointsWidth];
	userScore->color = blackRGBA;
	[scoreText addChild:userScore];
	
	return nameBack;
}

+(BaseElement*)createTitle:(NSString*)str active:(BOOL)active
{
	ColoredLayer* titleBack = [ColoredLayer create];
	titleBack->color = active?lightBlueColor:scoresDarkGrayColor;
	titleBack->height = 20;
	titleBack->width = 240;
	titleBack->passColorToChilds = FALSE;
	titleBack->rotationCenterX = titleBack->width;
	titleBack->rotationCenterY = titleBack->height;
	
	AlternateImage* titleText = [MenuController createLabel:str font:@"HelveticaNeue-Bold" color:active?whiteRGBA:titleDarkGrayColor width:240 height:22 fontSize:18];
	titleText->parentAnchor = titleText->anchor = VCENTER | LEFT;
	titleText->scaleX = 0.75;
	titleText->x = 4;
	titleText->y = -1;
	[titleBack addChild:titleText];
	return titleBack;
}

-(void)createScores
{
	scoresContainer = [BaseElement create];
	scoresContainer->parentAnchor = scoresContainer->anchor = TOP | HCENTER;
	[statScreen addChild:scoresContainer];
	scoresContainer->y = statTablesYPos;
	scoresContainer->width = SCREEN_WIDTH;
	scoresContainer->height = 200;
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if(rc && rc.user && rc.user.countryId == COUNTRY_US)
	{
		Image* backBeyond = [Image createWithResID:IMG_OPTIONS_BACK];
		backBeyond->parentAnchor = backBeyond->anchor = TOP | HCENTER;
		backBeyond->y = -60;
		backBeyond->x = -10;
		backBeyond->rotation = 4;
		backBeyond->rotationCenterX = backBeyond->width;
		backBeyond->rotationCenterY = backBeyond->height;
		[scoresContainer addChild:backBeyond];
		
		BaseElement* titleBackBeyond = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_NATION_CHAMP", @"Weekly National Champions") active:FALSE];
		BaseElement* titleBackBeyond2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_NATION_CHAMP", @"Weekly National Champions") active:FALSE];
		Button* bnational = [[Button allocAndAutorelease] initWithUpElement:titleBackBeyond DownElement:titleBackBeyond2 andID:BUTTON_NATIONAL_CHAMPIONS];
		bnational->anchor = bnational->parentAnchor = TOP | HCENTER;
		bnational->y = 8;
		[bnational setTouchIncreaseLeft:40 Right:50 Top:50 Bottom:-21];
		[bnational setDelegate:self];
		[backBeyond addChild:bnational];
	}
	
	Image* back = [Image createWithResID:IMG_OPTIONS_BACK];
	back->y = -45;
	back->x = 18;
	back->parentAnchor = back->anchor = TOP | LEFT;
	back->rotation = 2;
	back->rotationCenterX = back->width;
	back->rotationCenterY = back->height;
	[scoresContainer addChild:back];
	
	BaseElement* titleBack = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WORLD_CHAMP", @"Weekly World Champions") active:FALSE];
	BaseElement* titleBack2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WORLD_CHAMP", @"Weekly World Champions") active:FALSE];
	Button* bworld = [[Button allocAndAutorelease] initWithUpElement:titleBack DownElement:titleBack2 andID:BUTTON_WORLD_CHAMPIONS];
	bworld->anchor = bworld->parentAnchor = TOP | HCENTER;
	bworld->y = 8;
	int incTop = 14;
	if(rc && rc.user && rc.user.countryId != COUNTRY_US)
		incTop = 80;
	[bworld setTouchIncreaseLeft:80 Right:50 Top:incTop Bottom:20];
	[bworld setDelegate:self];
	[back addChild:bworld];
	
	
	Image* frontBack = [Image createWithResID:IMG_OPTIONS_BACK];
	frontBack->y = -30;
	frontBack->x = 18;
	frontBack->parentAnchor = frontBack->anchor = TOP | LEFT;
	frontBack->rotationCenterX = frontBack->width;
	frontBack->rotationCenterY = frontBack->height;
	[scoresContainer addChild:frontBack];
	
	BaseElement* frontTitleBack = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_CHAMP", @"Weekly Champions") active:TRUE];
	frontTitleBack->anchor = frontTitleBack->parentAnchor = TOP | HCENTER;
	frontTitleBack->y = 8;
	[frontBack addChild:frontTitleBack];
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"topall"];
	NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
	if(dict && [dict objectForKey:@"count"])
	{
		int SCORES_COUNT = [[dict objectForKey:@"count"] intValue];
		int offset = 5;
		if(SCORES_COUNT > 0)
		{
			float entryHeight = FLAG_HEIGHT+2+20+offset;
			
			ScrollableContainer* scoresList = [[ScrollableContainer allocAndAutorelease]
											   initWithWidth:200 Height:MAX_SCORE_ENTRY_ON_SCREEN*entryHeight-offset ContainerWidth:200
											   Height:entryHeight*SCORES_COUNT];
			scoresList->canSkipScrollPoints = TRUE;
			[frontBack addChild:scoresList];
			scoresList->parentAnchor = scoresList->anchor = TOP | LEFT;
			scoresList->y = 40;
			scoresList->x = 10;
			
			Scrollbar* sb = [[Scrollbar allocAndAutorelease] initWithWidth:5 Height:scoresList->height Vertical:TRUE];
			sb.provider = scoresList;
			sb->x = scoresList->x + scoresList->width + sb->width + 30;
			sb->y = scoresList->y;
			sb->anchor = sb->parentAnchor = TOP | LEFT;
			sb->scrollerColor = scrollerColor;
			sb->backColor = scoresDarkGrayColor;
			[frontBack addChild:sb];
			
			[scoresList turnScrollPointsOnWithCapacity:SCORES_COUNT];
			for (int i = 0; i < SCORES_COUNT; i++)
			{
				
				NSString* name = [dict objectForKey:FORMAT_STRING(@"name%i",i)];
				NSString* rank = [dict objectForKey:FORMAT_STRING(@"rank%i",i)];
				NSString* points = [dict objectForKey:FORMAT_STRING(@"points%i",i)];
				NSString* userId = [dict objectForKey:FORMAT_STRING(@"userId%i",i)];
				int countryId = [[dict objectForKey:FORMAT_STRING(@"countryId%i",i)] intValue];
				
				if(name && rank && points && userId)
				{
					
					BaseElement* scoreEntry = [MenuController createScoreEntry:name rank:rank points:points countryId:countryId userId:userId];
					[scoresList addChild:scoreEntry];
					scoreEntry->y = i*entryHeight;
					[scoresList addScrollPointAtX:0 Y:scoreEntry->y];
					if(i >= 0 && i < 3)
					{
						Image* star = [Image createWithResID:IMG_STARS];
						[star setDrawQuad:2-i];
						star->anchor = HCENTER | TOP;
						star->parentAnchor = TOP | LEFT;
						star->x = 2+FLAG_WIDTH/2;
						star->y = -4;
						[scoreEntry addChild:star];
					}

					if([userId isEqualToString:rc.user.userId])
					{
					#ifndef FREE
						BaseElement* myScoreEntry = [MenuController createScoreEntry:name rank:rank points:points countryId:countryId userId:userId];
						if(myScoreEntry)
						{
							myScoreEntry->y = scoresList->y + scoresList->height + 20;
							myScoreEntry->x = scoresList->x;
							myScoreEntry->parentAnchor = myScoreEntry->anchor = TOP | LEFT;
							[frontBack addChild:myScoreEntry];
							
							if(i >= 0 && i < 3)
							{
								Image* star = [Image createWithResID:IMG_STARS];
								[star setDrawQuad:2-i];
								star->anchor = HCENTER | TOP;
								star->parentAnchor = TOP | LEFT;
								star->x = 2+FLAG_WIDTH/2;
								star->y = -4;
								[myScoreEntry addChild:star];
							}
						}
					#endif
					}
				}
			}
#ifdef FREE
			Button* buyFull = [MenuController createButtonWithText:NSLocalizedString(@"STR_BUTTON_BUY_FULL", @"Buy full version") fontID:FNT_FONTS_001 ID:BUTTON_BUYFULL Delegate:self color:darkBlueColor];
			buyFull->y = scoresList->y + scoresList->height + 20;
			buyFull->parentAnchor = buyFull->anchor = TOP | HCENTER;
			[frontBack addChild:buyFull];
#endif
		}
	}
	else
	{
		Font* font_small = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
		Text* text = [[[Text alloc] initWithFont:font_small] autorelease];
		[text setString:STRING_NO_DATA andWidth:240];
		text->parentAnchor = text->anchor = CENTER;
		text->color = blackRGBA;
		[frontBack addChild:text];
	}	
}

-(void)createNationalChampions
{
	
	nationalContainer = [BaseElement create];
	nationalContainer->y = statTablesYPos;
	nationalContainer->width = SCREEN_WIDTH;
	nationalContainer->height = 400;
	nationalContainer->anchor = nationalContainer->parentAnchor = TOP | HCENTER;
	[nationalContainer setEnabled:FALSE];
	
	[statScreen addChild:nationalContainer];
	
	Image* backBeyond = [Image createWithResID:IMG_OPTIONS_BACK];
	backBeyond->parentAnchor = backBeyond->anchor = TOP | HCENTER;
	backBeyond->y = -60;
	backBeyond->x = -10;
	backBeyond->rotation = 4;
	backBeyond->rotationCenterX = backBeyond->width;
	backBeyond->rotationCenterY = backBeyond->height;
	[nationalContainer addChild:backBeyond];
	
	BaseElement* titleBackBeyond = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WORLD_CHAMP", @"Weekly World Champions") active:FALSE];
	BaseElement* titleBackBeyond2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WORLD_CHAMP", @"Weekly World Champions") active:FALSE];
	Button* bworld = [[Button allocAndAutorelease] initWithUpElement:titleBackBeyond DownElement:titleBackBeyond2 andID:BUTTON_WORLD_CHAMPIONS];
	bworld->anchor = bworld->parentAnchor = TOP | HCENTER;
	bworld->y = 8;
	[bworld setTouchIncreaseLeft:40 Right:50 Top:50 Bottom:-21];
	[bworld setDelegate:self];
	[backBeyond addChild:bworld];
	
	
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	
	Image* back = [Image createWithResID:IMG_OPTIONS_BACK];
	back->y = -45;
	back->x = 18;
	back->parentAnchor = back->anchor = TOP | LEFT;
	back->rotation = 2;
	back->rotationCenterX = back->width;
	back->rotationCenterY = back->height;
	[nationalContainer addChild:back];
	
	BaseElement* titleBack = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_CHAMP", @"Weekly Champions") active:FALSE];
	BaseElement* titleBack2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_CHAMP", @"Weekly Champions") active:FALSE];
	Button* bnational = [[Button allocAndAutorelease] initWithUpElement:titleBack DownElement:titleBack2 andID:BUTTON_TOP_SCORES];
	bnational->anchor = bnational->parentAnchor = TOP | HCENTER;
	bnational->y = 8;
	[bnational setTouchIncreaseLeft:40 Right:50 Top:14 Bottom:20];
	[bnational setDelegate:self];
	[back addChild:bnational];
	
	Image* frontBack = [Image createWithResID:IMG_OPTIONS_BACK];
	frontBack->y = -30;
	frontBack->x = 18;
	frontBack->parentAnchor = frontBack->anchor = TOP | LEFT;
	frontBack->rotationCenterX = frontBack->width;
	frontBack->rotationCenterY = frontBack->height;
	[nationalContainer addChild:frontBack];
	
	BaseElement* frontTitleBack = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_NATION_CHAMP", @"Weekly National Champions") active:TRUE];
	frontTitleBack->anchor = frontTitleBack->parentAnchor = TOP | HCENTER;
	frontTitleBack->y = 8;
	[frontBack addChild:frontTitleBack];
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"states"];
	NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
	if(dict && [dict objectForKey:@"count"])
	{
		int SCORES_COUNT = [[dict objectForKey:@"count"] intValue];
		int offset = 5;
		if(SCORES_COUNT > 0)
		{
			float entryHeight = FLAG_HEIGHT+2+20+offset;
			
			ScrollableContainer* scoresList = [[ScrollableContainer allocAndAutorelease]
											   initWithWidth:200 Height:MAX_SCORE_ENTRY_ON_SCREEN*entryHeight-offset ContainerWidth:200
											   Height:entryHeight*SCORES_COUNT];
			scoresList->canSkipScrollPoints = TRUE;
			[frontBack addChild:scoresList];
			scoresList->parentAnchor = scoresList->anchor = TOP | LEFT;
			scoresList->y = 40;
			scoresList->x = 10;
			
			Scrollbar* sb = [[Scrollbar allocAndAutorelease] initWithWidth:5 Height:scoresList->height Vertical:TRUE];
			sb.provider = scoresList;
			sb->x = scoresList->x + scoresList->width + sb->width + 30;
			sb->y = scoresList->y;
			sb->anchor = sb->parentAnchor = TOP | LEFT;
			sb->scrollerColor = scrollerColor;
			sb->backColor = scoresDarkGrayColor;
			[frontBack addChild:sb];
			
			[scoresList turnScrollPointsOnWithCapacity:SCORES_COUNT];
			for (int i = 0; i < SCORES_COUNT; i++)
			{
				int stateId = [[dict objectForKey:FORMAT_STRING(@"stateId%i",i)] intValue];
				NSString* points = [dict objectForKey:FORMAT_STRING(@"points%i",i)];
				
				if(stateId != 0 && points)
				{
					
					BaseElement* scoreEntry = [MenuController createStateScoreEntry:stateId rank:i+1 points:points];
					[scoresList addChild:scoreEntry];
					scoreEntry->y = i*entryHeight;
					[scoresList addScrollPointAtX:0 Y:scoreEntry->y];
					if(i >= 0 && i < 3)
					{
						Image* star = [Image createWithResID:IMG_STARS];
						[star setDrawQuad:2-i];
						star->anchor = HCENTER | TOP;
						star->parentAnchor = TOP | LEFT;
						star->x = 2+FLAG_WIDTH/2;
						star->y = -4;
						[scoreEntry addChild:star];
					}
				}
				
				if(stateId != 0 && stateId == rc.user.stateId)
				{
#ifndef FREE
					BaseElement* myScoreEntry = [MenuController createStateScoreEntry:stateId rank:i+1 points:points];
					if(myScoreEntry)
					{
						myScoreEntry->y = scoresList->y + scoresList->height + 20;
						myScoreEntry->x = scoresList->x;
						myScoreEntry->parentAnchor = myScoreEntry->anchor = TOP | LEFT;
						[frontBack addChild:myScoreEntry];
						
						if(i >= 0 && i < 3)
						{
							Image* star = [Image createWithResID:IMG_STARS];
							[star setDrawQuad:2-i];
							star->anchor = HCENTER | TOP;
							star->parentAnchor = TOP | LEFT;
							star->x = 2+FLAG_WIDTH/2;
							star->y = -4;
							[myScoreEntry addChild:star];
						}
					}
#endif					
				}
			}
#ifdef FREE
			Button* buyFull = [MenuController createButtonWithText:NSLocalizedString(@"STR_BUTTON_BUY_FULL", @"Buy full version") fontID:FNT_FONTS_001 ID:BUTTON_BUYFULL Delegate:self color:darkBlueColor];
			buyFull->y = scoresList->y + scoresList->height + 20;
			buyFull->parentAnchor = buyFull->anchor = TOP | HCENTER;
			[frontBack addChild:buyFull];
#endif			
		}
	}
	else
	{
		Font* font_small = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
		Text* text = [[[Text alloc] initWithFont:font_small] autorelease];
		[text setString:STRING_NO_DATA andWidth:240];
		text->parentAnchor = text->anchor = CENTER;
		text->color = blackRGBA;
		[frontBack addChild:text];
	}
}

-(void)createWorldChampions
{
	worldContainer = [BaseElement create];
	worldContainer->y = statTablesYPos;
	worldContainer->width = SCREEN_WIDTH;
	worldContainer->height = 400;
	worldContainer->parentAnchor = worldContainer->anchor = TOP | HCENTER;
	[worldContainer setEnabled:FALSE];
	[statScreen addChild:worldContainer];
	
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if(rc && rc.user && rc.user.countryId == COUNTRY_US)
	{
		Image* backBeyond = [Image createWithResID:IMG_OPTIONS_BACK];
		backBeyond->parentAnchor = backBeyond->anchor = TOP | HCENTER;
		backBeyond->y = -60;
		backBeyond->x = -10;
		backBeyond->rotation = 4;
		backBeyond->rotationCenterX = backBeyond->width;
		backBeyond->rotationCenterY = backBeyond->height;
		[worldContainer addChild:backBeyond];
		
		BaseElement* titleBackBeyond = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_NATION_CHAMP", @"Weekly National Champions") active:FALSE];
		BaseElement* titleBackBeyond2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_NATION_CHAMP", @"Weekly National Champions") active:FALSE];
		Button* bnational = [[Button allocAndAutorelease] initWithUpElement:titleBackBeyond DownElement:titleBackBeyond2 andID:BUTTON_NATIONAL_CHAMPIONS];
		bnational->anchor = bnational->parentAnchor = TOP | HCENTER;
		bnational->y = 8;
		[bnational setTouchIncreaseLeft:40 Right:50 Top:50 Bottom:-21];
		[bnational setDelegate:self];
		[backBeyond addChild:bnational];
	}
	
	Image* back = [Image createWithResID:IMG_OPTIONS_BACK];
	back->y = -45;
	back->x = 18;
	back->parentAnchor = back->anchor = TOP | LEFT;
	back->rotation = 2;
	back->rotationCenterX = back->width;
	back->rotationCenterY = back->height;
	[worldContainer addChild:back];
	
	BaseElement* titleBack = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_CHAMP", @"Weekly Champions") active:FALSE];
	BaseElement* titleBack2 = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WEEK_CHAMP", @"Weekly Champions") active:FALSE];
	Button* bscores = [[Button allocAndAutorelease] initWithUpElement:titleBack DownElement:titleBack2 andID:BUTTON_TOP_SCORES];
	bscores->anchor = bscores->parentAnchor = TOP | HCENTER;
	bscores->y = 8;
	int incTop = 14;
	if(rc && rc.user && rc.user.countryId != COUNTRY_US)
		incTop = 80;
	[bscores setTouchIncreaseLeft:40 Right:50 Top:incTop Bottom:20];
	[bscores setDelegate:self];
	[back addChild:bscores];
	
	
	Image* frontBack = [Image createWithResID:IMG_OPTIONS_BACK];
	frontBack->y = -30;
	frontBack->x = 18;
	frontBack->parentAnchor = frontBack->anchor = TOP | LEFT;
	frontBack->rotationCenterX = frontBack->width;
	frontBack->rotationCenterY = frontBack->height;
	[worldContainer addChild:frontBack];
	
	BaseElement* frontTitleBack = [MenuController createTitle:NSLocalizedString(@"STR_TITLE_WORLD_CHAMP", @"Weekly World Champions") active:TRUE];
	frontTitleBack->anchor = frontTitleBack->parentAnchor = TOP | HCENTER;
	frontTitleBack->y = 8;
	[frontBack addChild:frontTitleBack];
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"countries"];
	NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
	if(dict && [dict objectForKey:@"count"])
	{
		int SCORES_COUNT = [[dict objectForKey:@"count"] intValue];
		int offset = 5;
		if(SCORES_COUNT > 0)
		{
			float entryHeight = FLAG_HEIGHT+2+20+offset;
			
			ScrollableContainer* scoresList = [[ScrollableContainer allocAndAutorelease]
											   initWithWidth:200 Height:MAX_SCORE_ENTRY_ON_SCREEN*entryHeight-offset ContainerWidth:200
											   Height:entryHeight*SCORES_COUNT];
			scoresList->canSkipScrollPoints = TRUE;
			[frontBack addChild:scoresList];
			scoresList->parentAnchor = scoresList->anchor = TOP | LEFT;
			scoresList->y = 40;
			scoresList->x = 10;
			
			Scrollbar* sb = [[Scrollbar allocAndAutorelease] initWithWidth:5 Height:scoresList->height Vertical:TRUE];
			sb.provider = scoresList;
			sb->x = scoresList->x + scoresList->width + sb->width + 30;
			sb->y = scoresList->y;
			sb->anchor = sb->parentAnchor = TOP | LEFT;
			sb->scrollerColor = scrollerColor;
			sb->backColor = scoresDarkGrayColor;
			[frontBack addChild:sb];
			
			[scoresList turnScrollPointsOnWithCapacity:SCORES_COUNT];
			for (int i = 0; i < SCORES_COUNT; i++)
			{
				
				NSString* points = [dict objectForKey:FORMAT_STRING(@"points%i",i)];
				int countryId = [[dict objectForKey:FORMAT_STRING(@"countryId%i",i)] intValue];
				
				if(points && countryId != 0)
				{
					
					BaseElement* scoreEntry = [MenuController createCountryScoreEntry:countryId rank:i+1 points:points];
					[scoresList addChild:scoreEntry];
					scoreEntry->y = i*entryHeight;
					[scoresList addScrollPointAtX:0 Y:scoreEntry->y];
					if(i >= 0 && i < 3)
					{
						Image* star = [Image createWithResID:IMG_STARS];
						[star setDrawQuad:2-i];
						star->anchor = HCENTER | TOP;
						star->parentAnchor = TOP | LEFT;
						star->x = 2+FLAG_WIDTH/2;
						star->y = -4;
						[scoreEntry addChild:star];
					}
					
					if(countryId == rc.user.countryId)
					{
#ifndef FREE
						BaseElement* myScoreEntry = [MenuController createCountryScoreEntry:countryId rank:i+1 points:points];
						if(myScoreEntry)
						{
							myScoreEntry->y = scoresList->y + scoresList->height + 20;
							myScoreEntry->x = scoresList->x;
							myScoreEntry->parentAnchor = myScoreEntry->anchor = TOP | LEFT;
							[frontBack addChild:myScoreEntry];
							
							if(i >= 0 && i < 3)
							{
								Image* star = [Image createWithResID:IMG_STARS];
								[star setDrawQuad:2-i];
								star->anchor = HCENTER | TOP;
								star->parentAnchor = TOP | LEFT;
								star->x = 2+FLAG_WIDTH/2;
								star->y = -4;
								[myScoreEntry addChild:star];
							}
						}
#endif
					}
				}
			}
#ifdef FREE
			Button* buyFull = [MenuController createButtonWithText:NSLocalizedString(@"STR_BUTTON_BUY_FULL", @"Buy full version") fontID:FNT_FONTS_001 ID:BUTTON_BUYFULL Delegate:self color:darkBlueColor];
			buyFull->y = scoresList->y + scoresList->height + 20;
			buyFull->parentAnchor = buyFull->anchor = TOP | HCENTER;
			[frontBack addChild:buyFull];
#endif
		}
	}
	else
	{
		Font* font_small = [ChampionsResourceMgr getResource:FNT_FONTS_001_SMALL];
		Text* text = [[[Text alloc] initWithFont:font_small] autorelease];
		[text setString:STRING_NO_DATA andWidth:240];
		text->parentAnchor = text->anchor = CENTER;
		text->color = blackRGBA;
		[frontBack addChild:text];
	}	
}

- (void)initLocalizedNames
{
    countries[COUNTRY_UNKNOWN].name = NSLocalizedString(@"STR_COUNTRY_0", @"Unknown");
    countries[COUNTRY_US].name = NSLocalizedString(@"STR_COUNTRY_1", @"United States");
    countries[COUNTRY_UK].name = NSLocalizedString(@"STR_COUNTRY_2", @"United Kingdom");
    countries[COUNTRY_CA].name = NSLocalizedString(@"STR_COUNTRY_3", @"Canada");
    countries[COUNTRY_AU].name = NSLocalizedString(@"STR_COUNTRY_4", @"Australia");
    countries[COUNTRY_DE].name = NSLocalizedString(@"STR_COUNTRY_5", @"Germany");
    countries[COUNTRY_SE].name = NSLocalizedString(@"STR_COUNTRY_6", @"Sweden");
    countries[COUNTRY_FR].name = NSLocalizedString(@"STR_COUNTRY_7", @"France");
    countries[COUNTRY_AT].name = NSLocalizedString(@"STR_COUNTRY_8", @"Austria");
    countries[COUNTRY_DK].name = NSLocalizedString(@"STR_COUNTRY_9", @"Denmark");
    countries[COUNTRY_JP].name = NSLocalizedString(@"STR_COUNTRY_10", @"Japan");
    countries[COUNTRY_RU].name = NSLocalizedString(@"STR_COUNTRY_11", @"Russia");
    countries[COUNTRY_UA].name = NSLocalizedString(@"STR_COUNTRY_12", @"Ukraine");
    countries[COUNTRY_BY].name = NSLocalizedString(@"STR_COUNTRY_13", @"Belarus");
    countries[COUNTRY_AR].name = NSLocalizedString(@"STR_COUNTRY_14", @"Argentina");
    countries[COUNTRY_AM].name = NSLocalizedString(@"STR_COUNTRY_15", @"Armenia");
    countries[COUNTRY_BH].name = NSLocalizedString(@"STR_COUNTRY_16", @"Bahrain");
    countries[COUNTRY_BE].name = NSLocalizedString(@"STR_COUNTRY_17", @"Belgium");
    countries[COUNTRY_BW].name = NSLocalizedString(@"STR_COUNTRY_18", @"Botswana");
    countries[COUNTRY_BR].name = NSLocalizedString(@"STR_COUNTRY_19", @"Brazil");
    countries[COUNTRY_BG].name = NSLocalizedString(@"STR_COUNTRY_20", @"Bulgaria");
    countries[COUNTRY_CM].name = NSLocalizedString(@"STR_COUNTRY_21", @"Cameroon");
    countries[COUNTRY_CF].name = NSLocalizedString(@"STR_COUNTRY_22", @"Central African Rep.");
    countries[COUNTRY_CL].name = NSLocalizedString(@"STR_COUNTRY_23", @"Chile");
    countries[COUNTRY_CN].name = NSLocalizedString(@"STR_COUNTRY_24", @"China");
    countries[COUNTRY_CO].name = NSLocalizedString(@"STR_COUNTRY_25", @"Colombia");
    countries[COUNTRY_CR].name = NSLocalizedString(@"STR_COUNTRY_26", @"Costa Rica");
    countries[COUNTRY_HR].name = NSLocalizedString(@"STR_COUNTRY_27", @"Croatia");
    countries[COUNTRY_CZ].name = NSLocalizedString(@"STR_COUNTRY_28", @"Czech Republic");
    countries[COUNTRY_DO].name = NSLocalizedString(@"STR_COUNTRY_29", @"Dominican Republic");
    countries[COUNTRY_EC].name = NSLocalizedString(@"STR_COUNTRY_30", @"Ecuador");
    countries[COUNTRY_SV].name = NSLocalizedString(@"STR_COUNTRY_31", @"El Salvador");
    countries[COUNTRY_EG].name = NSLocalizedString(@"STR_COUNTRY_32", @"Egypt");
    countries[COUNTRY_EE].name = NSLocalizedString(@"STR_COUNTRY_33", @"Estonia");
    countries[COUNTRY_GQ].name = NSLocalizedString(@"STR_COUNTRY_34", @"Equatorial Guinea");
    countries[COUNTRY_FI].name = NSLocalizedString(@"STR_COUNTRY_35", @"Finland");
    countries[COUNTRY_GR].name = NSLocalizedString(@"STR_COUNTRY_36", @"Greece");
    countries[COUNTRY_GT].name = NSLocalizedString(@"STR_COUNTRY_37", @"Guatemala");
    countries[COUNTRY_GW].name = NSLocalizedString(@"STR_COUNTRY_38", @"Guinea-Bissau");
    countries[COUNTRY_GN].name = NSLocalizedString(@"STR_COUNTRY_39", @"Guinea");
    countries[COUNTRY_HO].name = NSLocalizedString(@"STR_COUNTRY_40", @"Honduras");
    countries[COUNTRY_HK].name = NSLocalizedString(@"STR_COUNTRY_41", @"Hong Kong");
    countries[COUNTRY_HU].name = NSLocalizedString(@"STR_COUNTRY_42", @"Hungary");
    countries[COUNTRY_IN].name = NSLocalizedString(@"STR_COUNTRY_43", @"India");
    countries[COUNTRY_ID].name = NSLocalizedString(@"STR_COUNTRY_44", @"Indonesia");
    countries[COUNTRY_IL].name = NSLocalizedString(@"STR_COUNTRY_45", @"Israel");
    countries[COUNTRY_IE].name = NSLocalizedString(@"STR_COUNTRY_46", @"Ireland");
    countries[COUNTRY_IT].name = NSLocalizedString(@"STR_COUNTRY_47", @"Italy");
    countries[COUNTRY_CI].name = NSLocalizedString(@"STR_COUNTRY_48", @"Ivory Coast");
    countries[COUNTRY_JM].name = NSLocalizedString(@"STR_COUNTRY_49", @"Jamaica");
    countries[COUNTRY_JO].name = NSLocalizedString(@"STR_COUNTRY_50", @"Jordan");
    countries[COUNTRY_KE].name = NSLocalizedString(@"STR_COUNTRY_51", @"Kenya");
    countries[COUNTRY_KO].name = NSLocalizedString(@"STR_COUNTRY_52", @"Korea");
    countries[COUNTRY_KW].name = NSLocalizedString(@"STR_COUNTRY_53", @"Kuwait");
    countries[COUNTRY_LV].name = NSLocalizedString(@"STR_COUNTRY_54", @"Latvia");
    countries[COUNTRY_LI].name = NSLocalizedString(@"STR_COUNTRY_55", @"Liechtenstein");
    countries[COUNTRY_LT].name = NSLocalizedString(@"STR_COUNTRY_56", @"Lithuania");
    countries[COUNTRY_LU].name = NSLocalizedString(@"STR_COUNTRY_57", @"Luxembourg");
    countries[COUNTRY_MO].name = NSLocalizedString(@"STR_COUNTRY_58", @"Macau");
    countries[COUNTRY_MK].name = NSLocalizedString(@"STR_COUNTRY_59", @"Macedonia");
    countries[COUNTRY_MG].name = NSLocalizedString(@"STR_COUNTRY_60", @"Madagascar");
    countries[COUNTRY_MY].name = NSLocalizedString(@"STR_COUNTRY_61", @"Malaysia");
    countries[COUNTRY_ML].name = NSLocalizedString(@"STR_COUNTRY_62", @"Mali");
    countries[COUNTRY_MT].name = NSLocalizedString(@"STR_COUNTRY_63", @"Malta");
    countries[COUNTRY_MA].name = NSLocalizedString(@"STR_COUNTRY_64", @"Morocco");
    countries[COUNTRY_MU].name = NSLocalizedString(@"STR_COUNTRY_65", @"Mauritius");
    countries[COUNTRY_MX].name = NSLocalizedString(@"STR_COUNTRY_66", @"Mexico");
    countries[COUNTRY_MD].name = NSLocalizedString(@"STR_COUNTRY_67", @"Moldova");
    countries[COUNTRY_ME].name = NSLocalizedString(@"STR_COUNTRY_68", @"Montenegro");
    countries[COUNTRY_MZ].name = NSLocalizedString(@"STR_COUNTRY_69", @"Mozambique");
    countries[COUNTRY_NL].name = NSLocalizedString(@"STR_COUNTRY_70", @"Netherlands");
    countries[COUNTRY_NZ].name = NSLocalizedString(@"STR_COUNTRY_71", @"New Zealand");
    countries[COUNTRY_NI].name = NSLocalizedString(@"STR_COUNTRY_72", @"Nicaragua");
    countries[COUNTRY_NE].name = NSLocalizedString(@"STR_COUNTRY_73", @"Niger");
    countries[COUNTRY_NG].name = NSLocalizedString(@"STR_COUNTRY_74", @"Nigeria");
    countries[COUNTRY_NO].name = NSLocalizedString(@"STR_COUNTRY_75", @"Norway");
    countries[COUNTRY_OM].name = NSLocalizedString(@"STR_COUNTRY_76", @"Oman");
    countries[COUNTRY_PA].name = NSLocalizedString(@"STR_COUNTRY_77", @"Panama");
    countries[COUNTRY_PY].name = NSLocalizedString(@"STR_COUNTRY_78", @"Paraguay");
    countries[COUNTRY_PE].name = NSLocalizedString(@"STR_COUNTRY_79", @"Peru");
    countries[COUNTRY_PH].name = NSLocalizedString(@"STR_COUNTRY_80", @"Philippines");
    countries[COUNTRY_PL].name = NSLocalizedString(@"STR_COUNTRY_81", @"Poland");
    countries[COUNTRY_PT].name = NSLocalizedString(@"STR_COUNTRY_82", @"Portugal");
    countries[COUNTRY_PR].name = NSLocalizedString(@"STR_COUNTRY_83", @"Puerto Rico");
    countries[COUNTRY_QA].name = NSLocalizedString(@"STR_COUNTRY_84", @"Qatar");
    countries[COUNTRY_RO].name = NSLocalizedString(@"STR_COUNTRY_85", @"Romania");
    countries[COUNTRY_SA].name = NSLocalizedString(@"STR_COUNTRY_86", @"Saudi Arabia");
    countries[COUNTRY_SN].name = NSLocalizedString(@"STR_COUNTRY_87", @"Senegal");
    countries[COUNTRY_SG].name = NSLocalizedString(@"STR_COUNTRY_88", @"Singapore");
    countries[COUNTRY_SK].name = NSLocalizedString(@"STR_COUNTRY_89", @"Slovakia");
    countries[COUNTRY_ZA].name = NSLocalizedString(@"STR_COUNTRY_90", @"South Africa");
    countries[COUNTRY_ES].name = NSLocalizedString(@"STR_COUNTRY_91", @"Spain");
    countries[COUNTRY_CH].name = NSLocalizedString(@"STR_COUNTRY_92", @"Switzerland");
    countries[COUNTRY_TW].name = NSLocalizedString(@"STR_COUNTRY_93", @"Taiwan");
    countries[COUNTRY_TH].name = NSLocalizedString(@"STR_COUNTRY_94", @"Thailand");
    countries[COUNTRY_TN].name = NSLocalizedString(@"STR_COUNTRY_95", @"Tunisia");
    countries[COUNTRY_TR].name = NSLocalizedString(@"STR_COUNTRY_96", @"Turkey");
    countries[COUNTRY_UG].name = NSLocalizedString(@"STR_COUNTRY_97", @"Uganda");
    countries[COUNTRY_AE].name = NSLocalizedString(@"STR_COUNTRY_98", @"United Arab Emirates");
    countries[COUNTRY_UY].name = NSLocalizedString(@"STR_COUNTRY_99", @"Uruguay");
    countries[COUNTRY_VE].name = NSLocalizedString(@"STR_COUNTRY_100", @"Venezuela");
    countries[COUNTRY_VN].name = NSLocalizedString(@"STR_COUNTRY_101", @"Vietnam");
    
    states[STATE_UNKNOWN].name = NSLocalizedString(@"STR_STATE_0", @"None");
    states[STATE_ALABAMA].name = NSLocalizedString(@"STR_STATE_1", @"Alabama");
    states[STATE_ALASKA].name = NSLocalizedString(@"STR_STATE_2", @"Alaska");
    states[STATE_ARIZONA].name = NSLocalizedString(@"STR_STATE_3", @"Arizona");
    states[STATE_ARKANSAS].name = NSLocalizedString(@"STR_STATE_4", @"Arkansas");
    states[STATE_CALIFORNIA].name = NSLocalizedString(@"STR_STATE_5", @"California");
    states[STATE_COLORADO].name = NSLocalizedString(@"STR_STATE_6", @"Colorado");
    states[STATE_CONNECTICUT].name = NSLocalizedString(@"STR_STATE_7", @"Connecticut");
    states[STATE_DELAWARE].name = NSLocalizedString(@"STR_STATE_8", @"Delaware");
    states[STATE_FLORIDA].name = NSLocalizedString(@"STR_STATE_9", @"Florida");
    states[STATE_GEORGIA].name = NSLocalizedString(@"STR_STATE_10", @"Georgia");
    states[STATE_HAWAII].name = NSLocalizedString(@"STR_STATE_11", @"Hawaii");
    states[STATE_IDAHO].name = NSLocalizedString(@"STR_STATE_12", @"Idaho");
    states[STATE_ILLINOIS].name = NSLocalizedString(@"STR_STATE_13", @"Illinois");
    states[STATE_INDIANA].name = NSLocalizedString(@"STR_STATE_14", @"Indiana");
    states[STATE_IOWA].name = NSLocalizedString(@"STR_STATE_15", @"Iowa");
    states[STATE_KANSAS].name = NSLocalizedString(@"STR_STATE_16", @"Kansas");
    states[STATE_KENTUCKY].name = NSLocalizedString(@"STR_STATE_17", @"Kentucky");
    states[STATE_LOISIANA].name = NSLocalizedString(@"STR_STATE_18", @"Louisiana");
    states[STATE_MAINE].name = NSLocalizedString(@"STR_STATE_19", @"Maine");
    states[STATE_MARYLAND].name = NSLocalizedString(@"STR_STATE_20", @"Maryland");
    states[STATE_MASSACHUSETTS].name = NSLocalizedString(@"STR_STATE_21", @"Massachusetts");
    states[STATE_MICHIGAN].name = NSLocalizedString(@"STR_STATE_22", @"Michigan");
    states[STATE_MINNESOTA].name = NSLocalizedString(@"STR_STATE_23", @"Minnesota");
    states[STATE_MISSISSIPPI].name = NSLocalizedString(@"STR_STATE_24", @"Mississippi");
    states[STATE_MISSOURI].name = NSLocalizedString(@"STR_STATE_25", @"Missouri");
    states[STATE_MONTANA].name = NSLocalizedString(@"STR_STATE_26", @"Montana");
    states[STATE_NEBRASKA].name = NSLocalizedString(@"STR_STATE_27", @"Nebraska");
    states[STATE_NEVADA].name = NSLocalizedString(@"STR_STATE_28", @"Nevada");
    states[STATE_NEW_HAMPSHIRE].name = NSLocalizedString(@"STR_STATE_29", @"New Hampshire");
    states[STATE_NEW_JERSEY].name = NSLocalizedString(@"STR_STATE_30", @"New Jersey");
    states[STATE_NEW_MEXICO].name = NSLocalizedString(@"STR_STATE_31", @"New Mexico");
    states[STATE_NEW_YORK].name = NSLocalizedString(@"STR_STATE_32", @"New York");
    states[STATE_NORTH_CAROLINA].name = NSLocalizedString(@"STR_STATE_33", @"North Carolina");
    states[STATE_NORTH_DAKOTA].name = NSLocalizedString(@"STR_STATE_34", @"North Dakota");
    states[STATE_OHIO].name = NSLocalizedString(@"STR_STATE_35", @"Ohio");
    states[STATE_OKLAHOMA].name = NSLocalizedString(@"STR_STATE_36", @"Oklahoma");
    states[STATE_OREGON].name = NSLocalizedString(@"STR_STATE_37", @"Oregon");
    states[STATE_PENNSYLVANIA].name = NSLocalizedString(@"STR_STATE_38", @"Pennsylvania");
    states[STATE_RHODE_ISLAND].name = NSLocalizedString(@"STR_STATE_39", @"Rhode Island");
    states[STATE_SOUTH_CAROLINA].name = NSLocalizedString(@"STR_STATE_40", @"South Carolina");
    states[STATE_SOUTH_DAKOTA].name = NSLocalizedString(@"STR_STATE_41", @"South Dakota");
    states[STATE_TENNESSEE].name = NSLocalizedString(@"STR_STATE_42", @"Tennessee");
    states[STATE_TEXAS].name = NSLocalizedString(@"STR_STATE_43", @"Texas");
    states[STATE_UTAH].name = NSLocalizedString(@"STR_STATE_44", @"Utah");
    states[STATE_VERMONT].name = NSLocalizedString(@"STR_STATE_45", @"Vermont");
    states[STATE_VIRGINIA].name = NSLocalizedString(@"STR_STATE_46", @"Virginia");
    states[STATE_WASHINGTON].name = NSLocalizedString(@"STR_STATE_47", @"Washington");
    states[STATE_WEST_VIRGINIA].name = NSLocalizedString(@"STR_STATE_48", @"West Virginia");
    states[STATE_WISCONSIN].name = NSLocalizedString(@"STR_STATE_49", @"Wisconsin");
}

- (id)initWithParent:(ViewController*)p
{
	if (self = [super initWithParent:p]) 
	{		
		[self initLocalizedNames];
        
		mapsList = nil;
		mapsList = [[MapsListParser create] retain];
#ifdef DEBUG
		BOOL showAssert = FALSE;
		for (int i = 0; i < [mapsList count]; i++)
		{
			LevelSet* set = (LevelSet*)[mapsList objectAtIndex:i];
			for (int j = 0; j < [set->list count]; j++)
			{
				NSString* mapName = [set->list objectAtIndex:j];
				for (int m = i; m < [mapsList count]; m++)
				{
					LevelSet* set2 = (LevelSet*)[mapsList objectAtIndex:m];
					for (int n = j+1; n < [set2->list count]; n++)
					{
						NSString* mapName2 = [set2->list objectAtIndex:n];
						if([mapName isEqualToString:mapName2])
						{
							showAssert = TRUE;
							NSLog(@"Duplicate map: %@", mapName);
						}
					}
				}
			}
		}
		ASSERT_MSG(!showAssert, @"Map duplicates found in maplist.xml, see output for more details.");
#endif
		[self createMainMenu];
		[self createScores];
		[self createNationalChampions];
		[nationalContainer setEnabled:FALSE];
		[self createWorldChampions];
		[worldContainer setEnabled:FALSE];
		[self createRegistration];		
		[self createCountryList];
		[self createStateList];
		
		scoreTables = 0;
//		for (int i = 0; i < COUNTRIES_COUNT; i++)
//		{
//			int lId = [MenuController getCountryById:i];
//			NSLog(@"%@ = %i", countries[lId].name, countries[lId].cId);
//		}
	}
	return self;
}

-(void)dealloc
{
	if(mapsList)
		[mapsList release];
	[super dealloc];	
}

-(void)showNews
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"bannerList"];
	NSData* data = [NSData dataWithContentsOfFile:path];	
	if(!data)return;
	NSArray* cachedBannerList = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	if(cachedBannerList)
	{
		for (FPBanner* banner in cachedBannerList)
		{
			if(!banner.showed)
			{
				Texture2D* t = [banner getImage];
				if(t)
				{
					[BannerBaloon showBaloonWithID:BALOON_NEWS Banner:t URL:banner.action
											 Image:[Image createWithResID:IMG_PERSONAGES Quad:IMG_PERSONAGES_dude02] Blocking:TRUE Type:BALOON_SINGLE inView:[self getView:VIEW_MAIN_MENU] Delegate:self];
					banner.showed = TRUE;
					break;
				}
			}
		}
	}
	NSData* data2 = [NSKeyedArchiver archivedDataWithRootObject:cachedBannerList];
	[data2 writeToFile:path atomically:TRUE];
	[cachedBannerList release];
}

-(void)activate
{
	[ChampionsSoundMgr playMusic:SND_INGAME_THEME1];
	[super activate];
	FPUser* user;
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if (rc)	
		user = rc.user;
		
	if(user.registered)
	{
		[self showView:VIEW_MAIN_MENU];	
		[self showNews];
	}
	else
	{
		ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
		int tutorialLevel = rc.user.tutorialLevel;	
		if (tutorialLevel >= TUTORIAL_LEVELS_COUNT)
		{
			rc.user.tutorialLevel = UNDEFINED;	
			[Baloon showBaloonWithID:BALOON_REGISTRATION_01 Text:NSLocalizedString(@"STR_TUTORIAL_TUTORIAL_REGISTRATION_01", @"Welcome to Finger Physics: Thumb Wars.  I'm here to help you win.  Let's get moving!") 
							   Image:[Image createWithResID:IMG_PERSONAGES Quad:IMG_PERSONAGES_dude02] Blocking:TRUE Type:BALOON_MULTIPLE_FIRST inView:[self getView:VIEW_REGISTRATION] Delegate:self];			
		}
		[self showView:VIEW_REGISTRATION];
	}
#ifdef FREE
	[rc setAdWhirlBanner];

#endif
}

-(void)deactivate
{
#ifdef FREE
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	[rc hideAdWhirlBanner];
#endif
//	[ChampionsSoundMgr stopMusic];
	[super deactivate];
}

-(void)showView:(int)v
{
	[super showView:v];
	
	switch(v)
	{
		case VIEW_REGISTRATION:
			[MenuController handleMenuVisited:WAS_IN_REGISTRATION];
			break;
			
		case VIEW_MAIN_MENU:
			[MenuController handleMenuVisited:WAS_IN_MAIN_MENU];							
			break;			
	}
}

-(void)scrollToLevelSelectForMode:(int)mode
{
	[mainContainer placeToScrollPoint:mode];	
}

-(void)scrollableContainer:(ScrollableContainer*)e reachedScrollPoint:(int)i
{
	if (i == 1 || i == 2)
	{
		[MenuController handleMenuVisited:WAS_IN_LEVEL_SELECT];
	}
}
-(void)scrollableContainer:(ScrollableContainer*)e changedTargetScrollPoint:(int)i
{
#ifdef FREE
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];		
	if(i != 0)
		[rc showAdWhirlBanner];
	else
		[rc hideAdWhirlBanner];
#endif
}

-(void)onButtonPressed:(int)n
{	
	switch (n)
	{
		case BUTTON_BUYFULL:
		{
			break;
		}
		case BUTTON_MODE1_POSITION:
		{
			[mainContainer moveToScrollPoint:1];
			break;
		}
		case BUTTON_MODE2_POSITION:
		{
			[mainContainer moveToScrollPoint:2];
			break;
		}
		case BUTTON_RESET_PROGRESS:
		{
			[[[UIAlertView alloc] initWithTitle:CLEAR_DATA_STRING message:NSLocalizedString(@"STR_CLEAR_WARNING", @"Are you sure you want to clear level progress and user statistics?") delegate:self cancelButtonTitle:NSLocalizedString(@"STR_CLEAR_YES", @"No") otherButtonTitles:NSLocalizedString(@"STR_CLEAR_NO", @"Yes"), nil] show];
			break;
		}			
		case BUTTON_FACEBOOK:
		{
			[FlurryAPI logEvent:@"FACEBOOK"];			
			[[UIApplication sharedApplication] openURL:
			 [NSURL URLWithString:@"http://bit.ly/aLkbez"]];

			break;
		}
		case BUTTON_TWITTER:
		{			
			[FlurryAPI logEvent:@"TWITTER"];
			[[UIApplication sharedApplication] openURL:
			 [NSURL URLWithString:@"http://bit.ly/b5Xy1t"]];
			break;
		}
		case BUTTON_MAIL:	
		{
			[FlurryAPI logEvent:@"EMAIL"];			
			NSString* to = @"support@pressokentertainment.com";
			NSString* subject = NSLocalizedString(@"STR_TITLE_FEEDBACK", NSLocalizedString(@"STR_FEEDBACK_SUBJECT", @"Finger Feedback"));
			NSString* body = @"";
			[ChampionsRootController mailWithSubject:subject body:body to:to isHTML:TRUE delegate:self];			
			break;
		}
		case BUTTON_MAIN_MENU:
		{
			[mainContainer moveToScrollPoint:0];
#ifdef FREE
		    [self scrollableContainer:mainContainer changedTargetScrollPoint:0];
#endif
			break;
		}
		case BUTTON_LEVELS:
		{			
			if([self optionsIsOpened] || [self statisticsIsOpened])return;
//			[self scrollToLevelSelectForMode:1];
			[mainContainer moveToScrollPoint:1];
#ifdef FREE
		    [self scrollableContainer:mainContainer changedTargetScrollPoint:1];
#endif
			[MenuController handleMenuVisited:WAS_IN_LEVEL_SELECT];							
			break;
		}			
		case BUTTON_WORLD_CHAMPIONS:
		{
			[scoresContainer setEnabled:FALSE];
			[worldContainer setEnabled:TRUE];
			[nationalContainer setEnabled:FALSE];
			break;
		}
			
		case BUTTON_NATIONAL_CHAMPIONS:
		{			
			[scoresContainer setEnabled:FALSE];
			[worldContainer setEnabled:FALSE];
			[nationalContainer setEnabled:TRUE];
			break;
		}
		
		case BUTTON_MAIN_SCORES:	
		{		
			[MenuController handleMenuVisited:WAS_IN_STATISTICS];
			[FlurryAPI logEvent:@"STATISTICS_PRESSED"];			
			
			if(statScreen->y == statScreenYPos)
			{
				ChampionsRootController* rc =(ChampionsRootController*)[Application sharedRootController];
				if(rc && rc.user)
				{
					if((scoreTables & TOP_ALL) != TOP_ALL)
					{
						[rc startLoadingAnimation];
						[rc.user topAll:self];
					}

					if((scoreTables & TOP_WORLD) != TOP_WORLD)
					{
						[rc startLoadingAnimation];
						[rc.user countries:self];
					}
					
					if(rc.user.countryId == COUNTRY_US && (scoreTables & TOP_NATIONAL) != TOP_NATIONAL)
					{					
						[rc startLoadingAnimation];
						[rc.user states:self];
					}
				}
				[statScreen playTimeline:0];
				mainContainer->maxTouchMoveLength = 0;
			}
			else
			{
				[statScreen playTimeline:1];
				mainContainer->maxTouchMoveLength = 50;
			}
			
			if([self optionsIsOpened])
			{
				[optionsBack playTimeline:1];
				mainContainer->maxTouchMoveLength = 50;
			}
			break;
		}
		case BUTTON_TOP_SCORES:
		{
			[scoresContainer setEnabled:TRUE];
			[worldContainer setEnabled:FALSE];
			[nationalContainer setEnabled:FALSE];
			break;
		}
		case BUTTON_STATE_CANCEL:
		{	
			[self showView:VIEW_REGISTRATION];
			break;
		}
		case BUTTON_STATE_EDIT:
		{
			[self showView:VIEW_STATE_LIST];
			break;
		}
		case BUTTON_OPENFEINT:
		{
			if([self optionsIsOpened] || [self statisticsIsOpened])return;
			// [OpenFeint launchDashboard];
			break;
		}
			
		case BUTTON_REGISTRATION_EDIT:
		{
			[self showView:VIEW_COUNTRY_LIST];
			break;
		}
			
		case BUTTON_COUNTRY_CANCEL:
		{
			[self showView:VIEW_REGISTRATION];
			break;
		}
		
		case BUTTON_REGISTRATION_OK:
		{
			scoreTables = 0;
			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			if (rc)
			{
				FPUser* user = rc.user;
				if(user)
				{	
					[rc startLoadingAnimation];
					[user countries:self];
					user.registered = TRUE;
					[user updateUserRegistration:FALSE];
					[rc saveGameProgress];					
				}
			}
			[self showView:VIEW_MAIN_MENU];
			break;
		}
			
		case BUTTON_REGISTRATION_CANCEL:
		{
			scoreTables = 0;
			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			if (rc)
			{
				FPUser* user = rc.user;
				if(user)
				{	user.registered = TRUE;				
					[rc saveGameProgress];
				}
			}
			[self showView:VIEW_MAIN_MENU];
			break;
		}
		case BUTTON_REGISTRATION:
		{
			if([self optionsIsOpened] || [self statisticsIsOpened])return;
			[self recreateRegistration];
			[self showView:VIEW_REGISTRATION];
			break;
		}
		case BUTTON_PLAY:
		{
			[FlurryAPI logEvent:@"PLAY_PRESSED"];			
			if([self optionsIsOpened] || [self statisticsIsOpened])return;
//			[ChampionsSoundMgr stopAll];		
			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			rc.selectedMap = rc.user.lastPlayedMap;
			[self deactivate];
			break;
		}
			
		case BUTTON_SOUND_ONOFF:
		{
			ChampionsPreferences* p = (ChampionsPreferences*)[Application sharedPreferences];
			bool soundOn = [p getBooleanForKey:(NSString*)PREFS_SOUND_ON];
			[p setBoolean:!soundOn forKey:(NSString*)PREFS_SOUND_ON];
			break;
		}

		case BUTTON_MUSIC_ONOFF:
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
			
		case BUTTON_OPTIONS:
		{	
			[MenuController handleMenuVisited:WAS_IN_OPTIONS];			
			
			Timeline* t = [optionsBack getCurrentTimeline];
			if(t && t->state == TIMELINE_PLAYING)break;
			
			if([self optionsIsOpened])
			{
				[optionsBack playTimeline:1];
				mainContainer->maxTouchMoveLength = 50;
			}
			else
			{
				[optionsBack playTimeline:0];
				mainContainer->maxTouchMoveLength = 0;
			}

			if ([self statisticsIsOpened]) 
			{
				[statScreen playTimeline:1];
			}
			[self optionsMenuEnableChild:0];
			break;
		}	
			
		case BUTTON_HELP:
		{
//			[helpContainer placeToScrollPoint:0]; 
//			[self showView:VIEW_HELP];
			break;
		}
					
		case BUTTON_FEEDBACK:
		{
			[self optionsMenuEnableChild:0];
			break;
		}
		case BUTTON_ABOUT:
		{
			[self optionsMenuEnableChild:1];
			break;
		}
		case BUTTON_CLEAR_PROGRESS:
		{
			[self optionsMenuEnableChild:2];
			break;
		}	
		case BUTTON_BACK_TO_MAIN_MENU:
		{
			[self showView:VIEW_MAIN_MENU];
			break;
		}			
		case BUTTON_BACK_TO_OPTIONS:
		{
			[self showView:VIEW_OPTIONS];
			break;
		}
	}
	
	[ChampionsSoundMgr playSound:SND_TAP];
}

-(void)onAlternateButtonPressed:(AlternateButton*)b andId:(int)n
{
	switch (n)
	{
		case BUTTON_PLAY_MAP:
		{

//			NSLog(@"%@", b->name);
#ifndef MAP_PICKER
			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			if(rc)
			{
				int tutorialLevel = rc.user.tutorialLevel;						
				if (tutorialLevel != UNDEFINED)
					rc.selectedMap = TUTORIAL_MAPS[tutorialLevel];			
				else
					rc.selectedMap = b->name;
			}
#endif
			[self deactivate];
			break;
		}
		case BUTTON_COUNTRY_SELECT:
		{
			[FlurryAPI logEvent:@"YOUR_COUNTRY_PRESSED"];				
			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			if (rc)
			{
				FPUser* user = rc.user;
				if(user)
				{
					user.countryId = [b->name intValue];
					if(user.countryId == COUNTRY_US)
					{
						[self showView:VIEW_STATE_LIST];
						[self recreateRegistration];
						break;
					}					
				}
			}
			[self recreateRegistration];
			[self showView:VIEW_REGISTRATION];			
			break;
		}
		case BUTTON_STATE_SELECT:
		{
			ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
			if (rc)
			{
				FPUser* user = rc.user;
				if(user)
				{

					user.stateId = [b->name intValue];
				}
			}
			[self recreateRegistration];
			[self showView:VIEW_REGISTRATION];
			
			break;
			
		}
		default:
			break;
	}
}
	
-(void)recreateRegistration
{
	if(activeViewID != VIEW_REGISTRATION)
	{
		[self deleteView:VIEW_REGISTRATION];
		[self createRegistration];
	}
	else
	{
		[self showView:VIEW_MAIN_MENU];
		[self deleteView:VIEW_REGISTRATION];
		[self createRegistration];
		[self showView:VIEW_REGISTRATION];
	}
}

-(void)recreateScores
{	
	[statScreen removeChild:scoresContainer];
	[self createScores];
}

-(void)recreateWorldChampions
{
	[statScreen removeChild:worldContainer];
	[self createWorldChampions];
}


-(void)recreateNationalChampions
{
	[statScreen removeChild:nationalContainer];
	[self createNationalChampions];
}

+(int)getCountryById:(int)cId
{
	for (int i = 0; i < COUNTRIES_COUNT; i++)
	{
		if(countries[i].cId == cId)
			return i;
	}
	return 0;
}

+(int)getStateById:(int)cId
{
	for (int i = 0; i < STATES_COUNT; i++)
	{
		if(states[i].cId == cId)
		{
			return i;
		}
	}
	return 0;
}

+(int)getStateIdByName:(NSString*)name
{
	for (int i = 0; i < STATES_COUNT; i++)
	{
		if([states[i].name isEqualToString:name])
		{
			return states[i].cId;
		}
	}
	return 0;
}

+(BOOL)isCountryInEu:(int)cId
{
	for (int i = 0; i < EU_COUNT; i++)
	{
		if(eu[i] == cId)return TRUE;
	}
	return FALSE;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[controller.view removeFromSuperview];
	[controller release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if([alertView.title isEqualToString:CLEAR_DATA_STRING])
	if(buttonIndex == 1)
	{
		scoreTables = 0;
		ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
		if(rc)
			[rc resetProgress];		
	}
	[alertView release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if(rc)
	{
		if(rc.user)
			[rc.user requestFinished:request];
	}
	if([request isMemberOfClass:[ASIFormDataRequest class]])
	{
		ASIFormDataRequest* r = (ASIFormDataRequest*)request;
		NSString* action = [r getPostValueForKey:@"extAction"];
		if([action isEqualToString:@"topall"])
		{
			scoreTables |= TOP_ALL;
			[self recreateScores];
		}
		if([action isEqualToString:@"countries"])
		{
			scoreTables |= TOP_WORLD;
			[self recreateWorldChampions];
			[mapGrid removeAllChilds];
			[self createPins];
		}
		if([action isEqualToString:@"states"])
		{
			scoreTables |= TOP_NATIONAL;
			[self recreateNationalChampions];
		}
	}
	if(rc)
		[rc stopLoadingAnimation];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if(rc)
	{
		if(rc.user)
			[rc.user requestFailed:request];
		[rc stopLoadingAnimation];
	}
}

+(void)handleMenuVisited:(int)m
{
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];	
	int prevVisits = rc.user.menusVisited;
	rc.user.menusVisited |= m;
	if (prevVisits != rc.user.menusVisited)
	{
		if (rc.user.menusVisited == (WAS_IN_LEVEL_SELECT | WAS_IN_MAIN_MENU | 
			WAS_IN_OPTIONS | WAS_IN_REGISTRATION | WAS_IN_STATISTICS))
		{
			[GameController unlockAchievement:AC_Navigator];
		}
	}
}

@end
