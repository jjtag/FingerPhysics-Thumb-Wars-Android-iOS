//
//  StartupController.h
//  blockit
//
//  Created by Efim Voinov on 18.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Framework.h"
#import "ColoredText.h"

enum {BUTTON_BANNER_SHOW, BUTTON_BANNER_SKIP};

@interface StartupController : ViewController <ResourceMgrDelegate, TimelineDelegate, ButtonDelegate> 
{
}

@end
