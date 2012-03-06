//
//  Framework.m
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#ifndef CONVERTED_CODE

#import "Framework.h"
#include <objc/runtime.h>

@implementation NSObject (Allocations)

+(id)create
{
	return [[[[self class] alloc] init] autorelease];
}

+(id)allocAndAutorelease
{
	return [[[self class] alloc] autorelease];
}

@end

#endif // CONVERTED_CODE