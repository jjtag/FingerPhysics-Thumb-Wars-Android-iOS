//
//  BlockitResourceMgr.h
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ResourceMgr.h"
#import "res.h"

@interface ChampionsResourceMgr : ResourceMgr 
{
}

+(id)getResource:(int)resID;
+(NSString*)getString:(int)strID;
@end
