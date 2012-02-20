//
//  LevelSet.h
//  champions
//
//  Created by ikoryakin on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamicArray.h"

@interface LevelSet : NSObject
{
@public
	NSString* name;
	int type;
	int queue;
	DynamicArray* list;
}

@property (retain) NSString* name;
@end
