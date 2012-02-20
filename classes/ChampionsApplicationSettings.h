//
//  BlockitApplicationSettings.h
//  blockit
//
//  Created by Efim Voinov on 20.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApplicationSettings.h"

// in this singleton class we set different application settings

extern const MixedNameValue TEMPLATE_APP_SETTINGS[];

@interface ChampionsApplicationSettings : ApplicationSettings 
{
}

-(MixedNameValue*)getSettingsDefaults;
@end
