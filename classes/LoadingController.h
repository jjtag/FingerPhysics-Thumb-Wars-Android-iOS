//
//  LoadingController.h
//  rogatka
//
//  Created by Efim Voinov on 26.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "ResourceMgr.h"

@interface LoadingController : ViewController <ResourceMgrDelegate>
{
@public
	int nextController;
	int nextView;
}

@end
