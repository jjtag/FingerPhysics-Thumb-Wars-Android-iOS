//
//  FPBanner.m
//  champions
//
//  Created by ikoryakin on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FPBanner.h"


@implementation FPBanner
@synthesize action, imagePath, showed;

-(id)init
{
	if(self = [super init])
	{
		showed = FALSE;
		imagePath = nil;
		action = nil;
	}
	return self;
}

-(void)dealloc
{
	self.action = nil;
	self.imagePath = nil;
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.action forKey:@"action"];
	[coder encodeObject:self.imagePath forKey:@"imagePath"];
	[coder encodeBool:self.showed forKey:@"showed"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if(self = [super init])
	{
		imagePath = nil;
		action = nil;
		self.action = [coder decodeObjectForKey:@"action"];
		self.imagePath = [coder decodeObjectForKey:@"imagePath"];
		self.showed = [coder decodeBoolForKey:@"showed"];
	}
	return self;
}

-(Texture2D*)getImage
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* imageName = [[imagePath pathComponents] lastObject];
	NSString* bannerPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
	UIImage* image = nil;
	image = [UIImage imageWithContentsOfFile:bannerPath];
	if(image)
	{
		Texture2D* t = [[[Texture2D alloc] initWithImage:image] autorelease];
		return t;
	}
	return nil;
}

@end
