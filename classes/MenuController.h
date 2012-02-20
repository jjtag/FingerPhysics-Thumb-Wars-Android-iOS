//
//  MenuController.h
//  blockit
//
//  Created by Mac on 02.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Framework.h"
#import "ChampionsApplicationSettings.h"
#import "ChampionsApp.h"
#import "AlternateButton.h"
#import "AlternateImage.h"
#import "MapsListParser.h"
#import "FPScrollbar.h"
#import "FPScrollableContainer.h"
#import "Baloon.h"
#import <MessageUI/MessageUI.h>
#import "ASIFormDataRequest.h"

#define FLAG_HEIGHT 25
#define FLAG_WIDTH 32
#define MAX_COUNTRY_ENTRY_ON_SCREEN 7
#define MAX_STATE_ENTRY_ON_SCREEN 5
#define MAX_SCORE_ENTRY_ON_SCREEN 3
#define MAX_AVATAR_SIZE 60
#define optionsBackYPos -65
#define statScreenYPos 60
#define statTablesYPos 120
#define STRING_NO_DATA NSLocalizedString(@"STR_NO_DATA", @"You need a data connection to check the rankings. Hop to it finger soldier!")
#define MODS_COUNT 2
#define MAP_ENTRY_HEIGHT 60
#define DEFAULT_MAPS_UNLOCKED 4
#define MAPS_UNLOCK_FOR_LVL_COMPLETE 1
#define CLEAR_DATA_STRING NSLocalizedString(@"STR_CLEAR_DATA", @"Clear all progress?")
#define STRING_REGISTRATION_INSPIRING_TEXT NSLocalizedString(@"STR_SELECT_SQUAD", @"Select your finger squad:")

enum {VIEW_MAIN_MENU, VIEW_OPTIONS, VIEW_HELP, VIEW_ABOUT, VIEW_REGISTRATION,
		VIEW_COUNTRY_LIST, VIEW_STATE_LIST, VIEW_TOP_SCORES, VIEW_NATIONAL_CHAMPIONS, VIEW_WORLD_CHAMPIONS, VIRTUAL_VIEW_LEVEL_SELECT};

enum {BUTTON_PLAY,BUTTON_PLAY_MAP, BUTTON_LEVELS, BUTTON_BUY, BUTTON_MAIN_MENU, BUTTON_OPTIONS, BUTTON_SOUND_ONOFF,
	BUTTON_MUSIC_ONOFF, BUTTON_ABOUT, BUTTON_HELP, BUTTON_BACK_TO_MAIN_MENU,
	BUTTON_BACK_TO_OPTIONS, BUTTON_REGISTRATION, BUTTON_REGISTRATION_OK, BUTTON_REGISTRATION_CANCEL,
	BUTTON_REGISTRATION_EDIT, BUTTON_COUNTRY_CANCEL, BUTTON_COUNTRY_SELECT, BUTTON_OPENFEINT,
	BUTTON_STATE_CANCEL, BUTTON_STATE_SELECT, BUTTON_STATE_EDIT, BUTTON_MAIN_SCORES, BUTTON_TOP_SCORES, 
	BUTTON_NATIONAL_CHAMPIONS, BUTTON_WORLD_CHAMPIONS, BUTTON_FEEDBACK,
	BUTTON_FACEBOOK, BUTTON_TWITTER, BUTTON_YOUTUBE, BUTTON_MAIL, BUTTON_CLEAR_PROGRESS, BUTTON_RESET_PROGRESS,
	BUTTON_MODE1_POSITION, BUTTON_MODE2_POSITION, BUTTON_BUYFULL,
};


typedef struct CountryProperties
{
	int cId;
	NSString* name;
	NSString* flag;
	CGPoint p;
};

typedef struct StateProperties
{
	int cId;
	NSString* name;
	NSString* flag;
};

enum CountriesId
{
	COUNTRY_UNKNOWN = 0,
	COUNTRY_US,
	COUNTRY_UK,
	COUNTRY_DE,
	COUNTRY_SE,	
	COUNTRY_AU,	
	COUNTRY_AT,	
	COUNTRY_DK,	
	COUNTRY_CA,	
	COUNTRY_JP,	
	COUNTRY_FR,	
	COUNTRY_IE,
	COUNTRY_BY,
	COUNTRY_RU,
	COUNTRY_UA,
	COUNTRY_AR,
	COUNTRY_AM,
	COUNTRY_BH,
	COUNTRY_BE,
	COUNTRY_BW,
	COUNTRY_BR,
	COUNTRY_BG,
	COUNTRY_CM,
	COUNTRY_CF,
	COUNTRY_CL,
	COUNTRY_CN,
	COUNTRY_CO,
	COUNTRY_CR,
	COUNTRY_HR,
	COUNTRY_CZ,
	COUNTRY_DO,
	COUNTRY_EC,
	COUNTRY_SV,
	COUNTRY_EG,
	COUNTRY_EE,
	COUNTRY_GQ,
	COUNTRY_FI,
	COUNTRY_GR,
	COUNTRY_GT,
	COUNTRY_GW,
	COUNTRY_GN,
	COUNTRY_HO,
	COUNTRY_HK,
	COUNTRY_HU,
	COUNTRY_IN,
	COUNTRY_ID,
	COUNTRY_IL,
	COUNTRY_IT,
	COUNTRY_CI,
	COUNTRY_JM,
	COUNTRY_JO,
	COUNTRY_KE,
	COUNTRY_KO,
	COUNTRY_KW,
	COUNTRY_LV,
	COUNTRY_LI,
	COUNTRY_LT,
	COUNTRY_LU,
	COUNTRY_MO,
	COUNTRY_MK,
	COUNTRY_MG,
	COUNTRY_MY,
	COUNTRY_ML,
	COUNTRY_MT,
	COUNTRY_MA,
	COUNTRY_MU,
	COUNTRY_MX,
	COUNTRY_MD,
	COUNTRY_ME,
	COUNTRY_MZ,
	COUNTRY_NL,
	COUNTRY_NZ,
	COUNTRY_NI,
	COUNTRY_NE,
	COUNTRY_NG,
	COUNTRY_NO,
	COUNTRY_OM,
	COUNTRY_PA,
	COUNTRY_PY,
	COUNTRY_PE,
	COUNTRY_PH,
	COUNTRY_PL,
	COUNTRY_PT,
	COUNTRY_PR,
	COUNTRY_QA,
	COUNTRY_RO,
	COUNTRY_SA,
	COUNTRY_SN,
	COUNTRY_SG,
	COUNTRY_SK,
	COUNTRY_ZA,
	COUNTRY_ES,
	COUNTRY_CH,
	COUNTRY_TW,
	COUNTRY_TH,
	COUNTRY_TN,
	COUNTRY_TR,
	COUNTRY_UG,
	COUNTRY_AE,
	COUNTRY_UY,
	COUNTRY_VE,
	COUNTRY_VN,
	TOTAL_COUNTRIES_COUNT,
};

enum StatesId
{
	STATE_UNKNOWN = 0,
	STATE_ALABAMA, 	
	STATE_ALASKA,
	STATE_ARIZONA,
	STATE_ARKANSAS, 	
	STATE_CALIFORNIA,
	STATE_COLORADO,
	STATE_CONNECTICUT,
	STATE_DELAWARE,
	STATE_FLORIDA,
	STATE_GEORGIA,
	STATE_HAWAII,
	STATE_IDAHO,
	STATE_ILLINOIS,
	STATE_INDIANA,
	STATE_IOWA, 	
	STATE_KANSAS,
	STATE_KENTUCKY,
	STATE_LOISIANA,
	STATE_MAINE,
	STATE_MARYLAND,
	STATE_MASSACHUSETTS,
	STATE_MICHIGAN,
	STATE_MINNESOTA,
	STATE_MISSISSIPPI,
	STATE_MISSOURI,
	STATE_MONTANA,
	STATE_NEBRASKA,
	STATE_NEVADA,
	STATE_NEW_HAMPSHIRE,
	STATE_NEW_JERSEY,
	STATE_NEW_MEXICO,
	STATE_NEW_YORK,
	STATE_NORTH_CAROLINA,
	STATE_NORTH_DAKOTA,
	STATE_OHIO,
	STATE_OKLAHOMA,
	STATE_OREGON,
	STATE_PENNSYLVANIA,
	STATE_RHODE_ISLAND,
	STATE_SOUTH_CAROLINA,
	STATE_SOUTH_DAKOTA,
	STATE_TENNESSEE,
	STATE_TEXAS,
	STATE_UTAH,
	STATE_VERMONT,
	STATE_VIRGINIA,
	STATE_WASHINGTON,
	STATE_WEST_VIRGINIA,
	STATE_WISCONSIN,
	STATE_WYOMING,
	TOTAL_STATES_COUNT
};

const int eu[] = 
{
	COUNTRY_UK,
	COUNTRY_DE,
	COUNTRY_DK,
	COUNTRY_FR,
	COUNTRY_IE,
	COUNTRY_AT,
	COUNTRY_SE,
	
	COUNTRY_BG,
	COUNTRY_CZ,
	COUNTRY_EE,
	COUNTRY_FI,
	COUNTRY_FR,
	COUNTRY_GR,
	COUNTRY_HU,
	COUNTRY_ES,
	COUNTRY_SK,
	COUNTRY_RO,
	COUNTRY_PT,
	COUNTRY_PL,
	COUNTRY_NL,
	COUNTRY_MT,
	COUNTRY_LU,
	COUNTRY_LT,
	COUNTRY_LV,
	COUNTRY_IT,
	COUNTRY_BE,
};

//const StateProperties countries[] = 
//{
//	{COUNTRY_UNKNOWN, NSLocalizedString(@"STR_COUNTRY_0", @"Unknown"), @""},
//	{COUNTRY_US, NSLocalizedString(@"STR_COUNTRY_1", @"United States"), @"United-States-Flag-32.png"},
//	{COUNTRY_UK, NSLocalizedString(@"STR_COUNTRY_2", @"United Kingdom"), @"United-Kingdom-flag-32.png"},
//	{COUNTRY_DE, NSLocalizedString(@"STR_COUNTRY_5", @"Germany"), @"Germany-Flag-32.png"},
//	{COUNTRY_SE, NSLocalizedString(@"STR_COUNTRY_6", @"Sweden"), @"Sweden-Flag-32.png"},
//	{COUNTRY_AU, NSLocalizedString(@"STR_COUNTRY_4", @"Australia"), @"Australia-Flag-32.png"},
//	{COUNTRY_AT, NSLocalizedString(@"STR_COUNTRY_8", @"Austria"), @"Austria-Flag-32.png"},
//	{COUNTRY_DK, NSLocalizedString(@"STR_COUNTRY_9", @"Denmark"), @"Denmark-Flag-32.png"},
//	{COUNTRY_CA, NSLocalizedString(@"STR_COUNTRY_3", @"Canada"), @"Canada-Flag-32.png"},
//	{COUNTRY_JP, NSLocalizedString(@"STR_COUNTRY_10", @"Japan"), @"Japan-Flag-32.png"},
//	{COUNTRY_FR, NSLocalizedString(@"STR_COUNTRY_7", @"France"), @"France-Flag-32.png"},
//	{COUNTRY_IE, NSLocalizedString(@"STR_COUNTRY_46", @"Ireland"), @"Ireland-Flag-32.png"},
//	{COUNTRY_BY, NSLocalizedString(@"STR_COUNTRY_13", @"Belarus"), @"Belarus-Flag-32.png"},
//	{COUNTRY_RU, NSLocalizedString(@"STR_COUNTRY_11", @"Russia"), @"Russia-Flag-32.png"},
//};

static CountryProperties countries[] =
{
	{COUNTRY_UNKNOWN, nil, @"", {0, 0}},
	{COUNTRY_US, nil, @"United-States-Flag-32.png", {46, 34}},
	{COUNTRY_UK, nil, @"United-Kingdom-flag-32.png", {122, 22}},
	{COUNTRY_CA, nil, @"Canada-Flag-32.png", {50, 20}},
	{COUNTRY_AU, nil, @"Australia-Flag-32.png", {234, 98}},
	{COUNTRY_DE, nil, @"Germany-Flag-32.png", {128, 28}},
	{COUNTRY_SE, nil, @"Sweden-Flag-32.png", {134, 16}},
	{COUNTRY_FR, nil, @"France-Flag-32.png", {124, 30}},
	{COUNTRY_AT, nil, @"Austria-Flag-32.png", {134, 30}},
	{COUNTRY_DK, nil, @"Denmark-Flag-32.png", {128, 24}},
	{COUNTRY_JP, nil, @"Japan-Flag-32.png", {234, 38}},
	{COUNTRY_RU, nil, @"Russia-Flag-32.png", {186, 18}},
	{COUNTRY_UA, nil, @"Ukraine-Flag-32.png", {148, 28}},
	{COUNTRY_BY, nil, @"Belarus-Flag-32.png", {144, 26}},
	{COUNTRY_AR, nil, @"Argentina-Flag-32.png", {70, 110}},
	{COUNTRY_AM, nil, @"Armenia-Flag-32.png", {156, 36}},
	{COUNTRY_BH, nil, @"Bahrain-Flag-32.png", {166, 50}},
	{COUNTRY_BE, nil, @"Belgium-Flag-32.png", {124, 26}},
	{COUNTRY_BW, nil, @"Botswana-Flag-32.png", {142, 94}},
	{COUNTRY_BR, nil, @"Brazil-Flag-32.png", {78, 84}},
	{COUNTRY_BG, nil, @"Bulgaria-Flag-32.png", {142, 34}},
	{COUNTRY_CM, nil, @"Cameroon-Flag-32.png", {132, 68}},
	{COUNTRY_CF, nil, @"CentralAfricanRepublic32.png", {140, 68}},
	{COUNTRY_CL, nil, @"Chile-Flag-32.png", {66, 100}},
	{COUNTRY_CN, nil, @"China-Flag-32.png", {212, 42}},
	{COUNTRY_CO, nil, @"Colombia-Flag-32.png", {60, 70}},
	{COUNTRY_CR, nil, @"Costa-Rica-Flag-32.png", {52, 66}},
	{COUNTRY_HR, nil, @"Croatian-Flag-32.png", {138, 34}},
	{COUNTRY_CZ, nil, @"Czech-Republic-Flag-32.png", {134, 28}},
	{COUNTRY_DO, nil, @"Dominican-Republic-Flag-32.png", {62, 58}},
	{COUNTRY_EC, nil, @"Ecuador-Flag-32.png", {56, 78}},
	{COUNTRY_SV, nil, @"El-Salvador-Flag-32.png", {50, 64}},
	{COUNTRY_EG, nil, @"Egypt-Flag-32.png", {146, 48}},
	{COUNTRY_EE, nil, @"Estonia-Flag-32.png", {142, 18}},
	{COUNTRY_GQ, nil, @"Equatorial-Guinea-Flag-32.png", {132, 72}},
	{COUNTRY_FI, nil, @"Finland-Flag-32.png", {138, 14}},
	{COUNTRY_GR, nil, @"Greece-Flag-32.png", {140, 38}},
	{COUNTRY_GT, nil, @"Guatemala-Flag-32.png", {46, 62}},
	{COUNTRY_GW, nil, @"Guinea-Bissau-Flag-32.png", {110, 60}},
	{COUNTRY_GN, nil, @"Guinea-Flag-32.png", {116, 62}},
	{COUNTRY_HO, nil, @"Honduras-Flag-32.png", {46, 64}},
	{COUNTRY_HK, nil, @"Hong-Kong-Flag-32.png", {218, 54}},
	{COUNTRY_HU, nil, @"Hungary-Flag-32.png", {136, 28}},
	{COUNTRY_IN, nil, @"India-Flag-32.png", {188, 60}},
	{COUNTRY_ID, nil, @"Indonesia-Flag-32.png", {226, 78}},
	{COUNTRY_IL, nil, @"Israel-Flag-32.png", {150, 44}},
	{COUNTRY_IE, nil, @"Ireland-Flag-32.png", {116, 24}},
	{COUNTRY_IT, nil, @"Italy-Flag-32.png", {134, 36}},
	{COUNTRY_CI, nil, @"Ivory-Coast-Flag-32.png", {118, 68}},
	{COUNTRY_JM, nil, @"Jamaica-Flag-32.png", {58, 60}},
	{COUNTRY_JO, nil, @"Jordan-Flag-32.png", {152, 44}},
	{COUNTRY_KE, nil, @"Kenya-Flag-32.png", {156, 76}},
	{COUNTRY_KO, nil, @"Korea-Flag-32.png", {222, 38}},
	{COUNTRY_KW, nil, @"Kuwait-Flag-32.png", {162, 46}},
	{COUNTRY_LV, nil, @"Latvia-Flag-32.png", {142, 22}},
	{COUNTRY_LI, nil, @"Liechtenstein-Flag-32.png", {130, 30}},
	{COUNTRY_LT, nil, @"Lithuania-Flag-32.png", {138, 22}},
	{COUNTRY_LU, nil, @"Luxembourg-Flag-32.png", {128, 26}},
	{COUNTRY_MO, nil, @"Macau-Flag-32.png", {216, 54}},
	{COUNTRY_MK, nil, @"Macedonia-Flag-32.png", {140, 34}},
	{COUNTRY_MG, nil, @"Madagascar-Flag-32.png", {158, 98}},
	{COUNTRY_MY, nil, @"Malaysia-Flag-32.png", {218, 72}},
	{COUNTRY_ML, nil, @"Mali-Flag-32.png", {124, 56}},
	{COUNTRY_MT, nil, @"Malta-Flag-32.png", {134, 40}},
	{COUNTRY_MA, nil, @"Morocco-Flag-32.png", {118, 44}},
	{COUNTRY_MU, nil, @"Mauritius-Flag-32.png", {116, 56}},
	{COUNTRY_MX, nil, @"Mexico-Flag-32.png", {38, 52}},
	{COUNTRY_MD, nil, @"Moldova-Flag-32.png", {144, 32}},
	{COUNTRY_ME, nil, @"Montenegro-Flag-32.png", {138, 34}},
	{COUNTRY_MZ, nil, @"Mozambique-Flag-32.png", {152, 94}},
	{COUNTRY_NL, nil, @"Netherlands-Flag-32.png", {126, 26}},
	{COUNTRY_NZ, nil, @"New-Zealand-Flag-32.png", {248, 118}},
	{COUNTRY_NI, nil, @"Nicaragua-Flag-32.png", {52, 62}},
	{COUNTRY_NE, nil, @"Niger-Flag-32.png", {130, 58}},
	{COUNTRY_NG, nil, @"Nigeria-Flag-32.png", {130, 64}},
	{COUNTRY_NO, nil, @"Norway-Flag-32.png", {128, 16}},
	{COUNTRY_OM, nil, @"Oman-Flag-32.png", {170, 54}},
	{COUNTRY_PA, nil, @"Panama-Flag-32.png", {54, 66}},
	{COUNTRY_PY, nil, @"Paraguay-Flag-32.png", {74, 98}},
	{COUNTRY_PE, nil, @"Peru-Flag-32.png", {60, 80}},
	{COUNTRY_PH, nil, @"Philippines-Flag-32.png", {224, 64}},
	{COUNTRY_PL, nil, @"Poland-Flag-32.png", {136, 24}},
	{COUNTRY_PT, nil, @"Portugal-Flag-32.png", {116, 36}},
	{COUNTRY_PR, nil, @"Puerto-Rico-Flag-32.png", {64, 58}},
	{COUNTRY_QA, nil, @"Qatar-Flag-32.png", {166, 52}},
	{COUNTRY_RO, nil, @"Romania-Flag-32.png", {142, 32}},
	{COUNTRY_SA, nil, @"Saudi-Arabia-Flag-32.png", {160, 54}},
	{COUNTRY_SN, nil, @"Senegal-Flag-32.png", {112, 58}},
	{COUNTRY_SG, nil, @"Singapore-Flag-32.png", {210, 76}},
	{COUNTRY_SK, nil, @"Slovakia-Flag-32.png", {140, 28}},
	{COUNTRY_ZA, nil, @"South-Africa-Flag-32.png", {142, 100}},
	{COUNTRY_ES, nil, @"Spain-Flag-32.png", {120, 36}},
	{COUNTRY_CH, nil, @"Switzerland-Flag-32.png", {130, 32}},
	{COUNTRY_TW, nil, @"Taiwan-Flag-32.png", {222, 54}},
	{COUNTRY_TH, nil, @"Thailand-Flag-32.png", {208, 60}},
	{COUNTRY_TN, nil, @"Tunisia-Flag-32.png", {130, 40}},
	{COUNTRY_TR, nil, @"Turkey-Flag-32.png", {150, 38}},
	{COUNTRY_UG, nil, @"Uganda-Flag-32.png", {150, 72}},
	{COUNTRY_AE, nil, @"United-Arab-Emirates-32.png", {166, 52}},
	{COUNTRY_UY, nil, @"Uruguay-Flag-32.png", {78, 104}},
	{COUNTRY_VE, nil, @"Venezuela-Flag-32.png", {66, 68}},
	{COUNTRY_VN, nil, @"Vietnam-Flag-32.png", {214, 62}},
};

static StateProperties states[] = 
{
	{STATE_UNKNOWN, nil, @""},
	{STATE_ALABAMA, nil, @"Alabama-Flag-32.png" }, 	
	{STATE_ALASKA, nil, @"Alaska-Flag-32.png" },
	{STATE_ARIZONA, nil, @"Arizona-Flag-32.png" }, 	
	{STATE_ARKANSAS, nil, @"Arkansas-Flag-32.png" }, 	
	{STATE_CALIFORNIA, nil, @"California-Flag-32.png" }, 	
	{STATE_COLORADO, nil, @"Colorado-Flag-32.png" }, 	
	{STATE_CONNECTICUT, nil, @"Connecticut-Flag-32.png" }, 
	{STATE_DELAWARE, nil, @"Delaware-Flag-32.png" }, 	
	{STATE_FLORIDA, nil, @"Florida-Flag-32.png" }, 	
	{STATE_GEORGIA, nil, @"Georgia-Flag-32.png" }, 	
	{STATE_HAWAII, nil, @"Hawaii-Flag-32.png" },
	{STATE_IDAHO, nil, @"Idaho-Flag-32.png" },
	{STATE_ILLINOIS, nil, @"Illinois-Flag-32.png" },
	{STATE_INDIANA, nil, @"Indiana-Flag-32.png" }, 
	{STATE_IOWA, nil, @"Iowa-Flag-32.png" }, 	
	{STATE_KANSAS, nil, @"Kansas-Flag-32.png" }, 	
	{STATE_KENTUCKY, nil, @"Kentucky-Flag-32.png" },
	{STATE_LOISIANA, nil, @"Louisiana-Flag-32.png" },
	{STATE_MAINE, nil, @"Maine-Flag-32.png" },
	{STATE_MARYLAND, nil, @"Maryland-Flag-32.png" },
	{STATE_MASSACHUSETTS, nil, @"Massachusetts-Flag-32.png" },
	{STATE_MICHIGAN, nil, @"Michigan-Flag-32.png" },
	{STATE_MINNESOTA, nil, @"Minnesota-Flag-32.png" },
	{STATE_MISSISSIPPI, nil, @"Mississippi-Flag-32.png" },
	{STATE_MISSOURI, nil, @"Missouri-Flag-32.png" },
	{STATE_MONTANA, nil, @"Montana-Flag-32.png" },
	{STATE_NEBRASKA, nil, @"Nebraska-Flag-32.png" },
	{STATE_NEVADA, nil, @"Nevada-Flag-32.png" },
	{STATE_NEW_HAMPSHIRE, nil, @"New-Hampshire-Flag-32.png" },
	{STATE_NEW_JERSEY, nil, @"New-Jersey-Flag-32.png" },
	{STATE_NEW_MEXICO, nil, @"New-Mexico-Flag-32.png" },
	{STATE_NEW_YORK, nil, @"New-York-Flag-32.png" },
	{STATE_NORTH_CAROLINA, nil, @"North-Carolina-Flag-32.png" },
	{STATE_NORTH_DAKOTA, nil, @"North-Dakota-Flag-32.png" },
	{STATE_OHIO, nil, @"Ohio-Flag-32.png" },
	{STATE_OKLAHOMA, nil, @"Oklahoma-Flag-32.png" },
	{STATE_OREGON, nil, @"Oregon-Flag-32.png" },
	{STATE_PENNSYLVANIA, nil, @"Pennsylvania-Flag-32.png" },
	{STATE_RHODE_ISLAND, nil, @"Rhode-Island-Flag-32.png" },
	{STATE_SOUTH_CAROLINA, nil, @"South-Carolina-Flag-32.png" },
	{STATE_SOUTH_DAKOTA, nil, @"South-Dakota-Flag-32.png" },
	{STATE_TENNESSEE, nil, @"Tennessee-Flag-32.png" },
	{STATE_TEXAS, nil, @"Texas-Flag-32.png" },
	{STATE_UTAH, nil, @"Utah-Flag-32.png" },
	{STATE_VERMONT, nil, @"Vermont-Flag-32.png" },
	{STATE_VIRGINIA, nil, @"Virginia-Flag-32.png" },
	{STATE_WASHINGTON, nil, @"Washington-Flag-32.png" },
	{STATE_WEST_VIRGINIA, nil, @"West-Virginia-Flag-32.png" },
	{STATE_WISCONSIN, nil, @"Wisconsin-Flag-32.png" },
};

extern const int STATES_COUNT;
extern const int COUNTRIES_COUNT;
extern const int EU_COUNT;

extern const RGBAColor grayColor;
extern const RGBAColor lightGrayColor;
extern const RGBAColor darkGrayColor;
extern const RGBAColor lightBlueColor;
extern const RGBAColor darkBlueColor;
extern const RGBAColor dirtRedColor;

@interface MenuController : ViewController <ButtonDelegate, AlternateButtonDelegate,
	MFMailComposeViewControllerDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate,
	BaloonDelegate, ScrollableContainerProtocol>
{	
	FPScrollableContainer* mainContainer;
	Image* levelsScrollBack1;
	Image* levelsScrollBack2;
	Image* mapGrid;

	FPScrollbar* scroll1;
	FPScrollbar* scroll2;
	
	BaseElement* statScreen;
	BaseElement* scoresContainer;
	BaseElement* nationalContainer;
	BaseElement* worldContainer;
	
	Image* optionsBack;
	BaseElement* optionsMenu;
	Image* mainBack;
	Button* bphoto;
	DynamicArray* mapsList;

	int scoreTables;
	
@public
	ScrollableContainer* levels1Container;
	ScrollableContainer* levels2Container;	
}

-(void)createMainMenu;
-(void)createScores;
-(void)createNationalChampions;
-(void)createWorldChampions;
-(BaseElement*)createOptions;
//-(void)createHelp;

-(BaseElement*)createOptionsBox;
-(BaseElement*)createAboutBox;
-(BaseElement*)createFingerFeedbackBox;
-(BaseElement*)createClearProgressBox;

-(void)recreateRegistration;
-(void)recreateScores;
-(void)recreateNationalChampions;
-(void)recreateWorldChampions;

+(ToggleButton*)createToggleButtonWithBack:(int)tback toggleFront:(int)tfront Text:(NSString*)text ID:(int)bid Delegate:(id)d;
+(Button*)createButtonWithTextureUp:(Texture2D*)up Down:(Texture2D*)down ID:(int)bID scaleRatio:(float)scaleRatio;
+(Button*)createButtonWithText:(NSString*)str fontID:(int)fontID ID:(int)bid Delegate:(id)d color:(RGBAColor)color;
+(ToggleButton*)createToggleButtonWithText1:(NSString*)str1 Text2:(NSString*)str2 ID:(int)bid Delegate:(id)d;
+(Button*)createButtonWithImage:(int)resID ID:(int)bid Delegate:(id)d;
+(AlternateImage*)createLabel:(NSString*)str font:(NSString*)font color:(RGBAColor)c width:(float)w height:(float)h fontSize:(int)fontSize;
//+(Button*)createBackButtonWithDelegate:(id)d;
//+(Image*)createBackground;

+(int)getCountryById:(int)cId;
+(int)getStateById:(int)cId;
+(int)getStateIdByName:(NSString*)name;
+(BOOL)isCountryInEu:(int)cId;
+(Image*)createStateEntryForId:(int)index custom:(BOOL)b;
+(Image*)createCountryEntryForId:(int)index custom:(BOOL)b;
+(BaseElement*)createStateScoreEntry:(int)stateId rank:(int)rank points:(NSString*)points;
+(BaseElement*)createTitle:(NSString*)str active:(BOOL)active;
+(Image*)createFlag:(int)cId;
+(Image*)createStateFlag:(int)cId;
-(void)updateUserData;

-(void)scrollToLevelSelectForMode:(int)mode;

+(void)handleMenuVisited:(int)m;

@property (assign) DynamicArray *mapsList;

@end
