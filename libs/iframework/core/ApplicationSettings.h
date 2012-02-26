//
//  ApplicationSettings.h
//  blockit
//
//  Created by Efim Voinov on 20.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef union MixedValue
{
	int intValue;
	NSString* stringValue;
	bool boolValue;
	float floatValue;
} MixedValue;

typedef struct MixedValueTyped
{
	int type;
	MixedValue values;
} MixedValueTyped;

enum {VT_INT, VT_STRING, VT_BOOL, VT_FLOAT};

typedef struct MixedNameValue
{
	int name;
	MixedValueTyped data;
} MixedNameValue;

enum {ORIENTATION_PORTRAIT, ORIENTATION_LANDSCAPE_LEFT, ORIENTATION_LANDSCAPE_RIGHT};

enum 
{
	APP_SETTING_INTERACTION_ENABLED = 0, // application accepts interaction
	APP_SETTING_MULTITOUCH_ENABLED, // mutliple touches enabled
	APP_SETTING_STATUSBAR_HIDDEN, // no status bar at the top
	APP_SETTING_MAIN_LOOP_TIMERED,	// timer - based loop (otherwise a blocking loop with system events handling)
	APP_SETTING_FPS_METER_ENABLED, // fps meter is active
	APP_SETTING_FPS, // global frame update rate
	APP_SETTING_ORIENTATION, // 0 - portrait, 1 - landscape left, 2 - landscape right
	APP_SETTING_LOCALIZATION_ENABLED, // enables locale - specific strings and branches
	APP_SETTING_LOCALE, // current device locale		
	APP_SETTINGS_CUSTOM
};

#define BOOL_VALUE(NAME, VALUE) { NAME, { VT_BOOL, {.boolValue = VALUE} } }
#define INT_VALUE(NAME, VALUE) { NAME, { VT_INT, {.intValue = VALUE} } }
#define STRING_VALUE(NAME, VALUE) { NAME, { VT_STRING, {.stringValue = VALUE} } }
#define FLOAT_VALUE(NAME, VALUE) { NAME, { VT_FLOAT, {.floatValue = VALUE} } }

// generic settings defaults
extern const MixedNameValue DEFAULT_APP_SETTINGS[];

// singleton settings for an application. subclass this to add your own settings
@interface ApplicationSettings : NSObject 
{
	MixedValueTyped* settings;		
}

-(void)initSettingsDefaults;
-(MixedValue)get:(int)s;

-(int)getInt:(int)s;
-(bool)getBool:(int)s;
-(NSString*)getString:(int)s;
-(float)getFloat:(int)s;

-(void)set:(int)s Int:(int)v;
-(void)set:(int)s Bool:(bool)v;
-(void)set:(int)s String:(NSString*)v;
-(void)set:(int)s Float:(float)v;

// override these methods
-(MixedNameValue*)getSettingsDefaults;
-(int)getSettingsCount;
@end
