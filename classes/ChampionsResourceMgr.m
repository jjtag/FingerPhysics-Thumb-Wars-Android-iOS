//  BlockitResourceMgr.m
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChampionsResourceMgr.h"
#import "Framework.h"

@implementation ChampionsResourceMgr

-(id)init
{
	if (self = [super init])
	{
		[self setResList:(ResEntry*)RES_DATA];
	}
	
	return self;
}

+(id)getResource:(int)resID
{
	return [[Application sharedResourceMgr] getResource:resID];
}

+(NSString*)getString:(int)strID
{
	return [[Application sharedResourceMgr] getString:strID];
}

-(void)freeResource:(int)resID
{
	ASSERT(resID >= 0 && resID < [resources count]);
	id res = [self getResource:resID];
	int rc = [res retainCount];
	if (res)
	{
		if (rc > 1)
		{
			ResEntry* re = &resList[resID];
			ASSERT_MSG(FALSE, FORMAT_STRING(@"Resource ID: %d (%@) not freed because retainCount = %d", resID, re->path, rc )); 
		}
		[resources unsetObjectAtIndex:resID];		
	}
}

@end
