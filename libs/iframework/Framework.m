//
//  Framework.m
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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

@implementation NSObject (Dynamic)

-(const char*) getIVarType:(NSString*)name
{
	Ivar ivar = object_getInstanceVariable(self, [name UTF8String], nil);
	if (ivar)
	{
		return ivar_getTypeEncoding(ivar);
	}
	
	return nil;
}

-(void*)getIVar:(NSString*)name 
{
    if (name) 
	{
        Ivar ivar = object_getInstanceVariable(self, [name UTF8String], nil);
        if (ivar) 
		{
            return (void*)((char *)self + ivar_getOffset(ivar));
		}
    }
    return nil;
}

-(void)setIVar:(NSString*)name withValue:(void*)value
{
	Ivar ivar;
	if ((ivar = object_getInstanceVariable(self, [name UTF8String], nil)))
	{
		void** varIndex = (void **)((char *)self + ivar_getOffset(ivar));
		*varIndex = value;
	}
}

@end
