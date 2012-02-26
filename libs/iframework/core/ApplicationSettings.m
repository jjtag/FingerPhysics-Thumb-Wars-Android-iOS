//
//  ApplicationSettings.m
//  blockit
//
//  Created by Efim Voinov on 20.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApplicationSettings.h"
#import "Debug.h"

// generic settings defaults
const MixedNameValue DEFAULT_APP_SETTINGS[] = 
{
	BOOL_VALUE(APP_SETTING_INTERACTION_ENABLED, TRUE),
	BOOL_VALUE(APP_SETTING_MULTITOUCH_ENABLED, TRUE),
	BOOL_VALUE(APP_SETTING_STATUSBAR_HIDDEN, TRUE),
	BOOL_VALUE(APP_SETTING_MAIN_LOOP_TIMERED, TRUE),
	BOOL_VALUE(APP_SETTING_FPS_METER_ENABLED, TRUE),
	INT_VALUE(APP_SETTING_FPS, 60),
	INT_VALUE(APP_SETTING_ORIENTATION, ORIENTATION_PORTRAIT),
	BOOL_VALUE(APP_SETTING_LOCALIZATION_ENABLED, FALSE),
	STRING_VALUE(APP_SETTING_LOCALE, @"en"),
};

@implementation ApplicationSettings

-(id)init
{
	if (self = [super init])
	{
		int size = sizeof(MixedValueTyped) * [self getSettingsCount];
		settings = malloc(size);
		bzero(settings, size);
		[self initSettingsDefaults];
	}
	
	return self;
}

-(void)dealloc
{
	for (int i = 0; i < [self getSettingsCount]; i++)
	{
		if (settings[i].type == VT_STRING)
		{
			[settings[i].values.stringValue release];
		}
	}
	
	free(settings);
	[super dealloc];
}

-(MixedValue)get:(int)s
{
	ASSERT(s >= 0 && s < [self getSettingsCount]);
	return settings[s].values;
}

-(int)getInt:(int)s
{
	return [self get:s].intValue;
}

-(bool)getBool:(int)s
{
	return [self get:s].boolValue;
}

-(NSString*)getString:(int)s
{
	return [self get:s].stringValue;
}

-(float)getFloat:(int)s
{
	return [self get:s].floatValue;
}

-(void)set:(int)s Int:(int)v
{
	ASSERT(s >= 0 && s < [self getSettingsCount]);
	settings[s].values.intValue = v;	
}

-(void)set:(int)s Bool:(bool)v
{
	ASSERT(s >= 0 && s < [self getSettingsCount]);
	settings[s].values.boolValue = v;	
}

-(void)set:(int)s String:(NSString*)v
{
	ASSERT(s >= 0 && s < [self getSettingsCount]);
	[settings[s].values.stringValue release];
	settings[s].values.stringValue = [v retain];	
}

-(void)set:(int)s Float:(float)v
{
	ASSERT(s >= 0 && s < [self getSettingsCount]);
	settings[s].values.floatValue = v;	
}

-(void)initSettingsDefaults
{
	for (int i = 0; i < [self getSettingsCount]; i++)
	{
		MixedNameValue* defaults = [self getSettingsDefaults];
		switch (defaults[i].data.type)
		{
			case VT_INT:
				[self set:defaults[i].name Int:defaults[i].data.values.intValue];
				break;
				
			case VT_STRING:
				[self set:defaults[i].name String:defaults[i].data.values.stringValue];
				break;

			case VT_BOOL:
				[self set:defaults[i].name Bool:defaults[i].data.values.boolValue];
				break;
				
			case VT_FLOAT:
				[self set:defaults[i].name Float:defaults[i].data.values.floatValue];
				break;
			
			default:
				ASSERT(FALSE);
				
		}
	}
}

// override these methods
-(MixedNameValue*)getSettingsDefaults
{
	return (MixedNameValue*)DEFAULT_APP_SETTINGS;
}

-(int)getSettingsCount
{
	return APP_SETTINGS_CUSTOM;
}

@end
