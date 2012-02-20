//
//  FPScores.m
//  champions
//
//  Created by ikoryakin on 6/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FPScores.h"


@implementation FPScores

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt:scores forKey:@"scores"];
	[coder encodeFloat:bumper forKey:@"bumper"];
	[coder encodeInt:bonuses forKey:@"bonuses"];
	[coder encodeInt:time forKey:@"time"];
	[coder encodeInt:medal forKey:@"medal"];
}


-(id)initWithCoder:(NSCoder *)coder
{
	if(self = [super init])
	{
		scores = [coder decodeIntForKey:@"scores"];
		bumper = [coder decodeFloatForKey:@"bumper"];
		bonuses = [coder decodeIntForKey:@"bonuses"];
		time = [coder decodeIntForKey:@"time"];
		medal = [coder decodeIntForKey:@"medal"];
	}
	return self;
}

@end
