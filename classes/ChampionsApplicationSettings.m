//
//  BlockitApplicationSettings.m
//  blockit
//
//  Created by Efim Voinov on 20.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChampionsApplicationSettings.h"

const MixedNameValue TEMPLATE_APP_SETTINGS[] = 
{
	BOOL_VALUE(APP_SETTING_INTERACTION_ENABLED, TRUE),
	BOOL_VALUE(APP_SETTING_MULTITOUCH_ENABLED, FALSE),
	BOOL_VALUE(APP_SETTING_STATUSBAR_HIDDEN, TRUE),
	BOOL_VALUE(APP_SETTING_MAIN_LOOP_TIMERED, TRUE),
	BOOL_VALUE(APP_SETTING_FPS_METER_ENABLED, FALSE),
	INT_VALUE(APP_SETTING_FPS, 60),

	INT_VALUE(APP_SETTING_ORIENTATION, ORIENTATION_PORTRAIT),

	BOOL_VALUE(APP_SETTING_LOCALIZATION_ENABLED, FALSE),
	STRING_VALUE(APP_SETTING_LOCALE, @"en")
};

@implementation ChampionsApplicationSettings

-(MixedNameValue*)getSettingsDefaults
{
	return (MixedNameValue*)TEMPLATE_APP_SETTINGS;
}

@end
