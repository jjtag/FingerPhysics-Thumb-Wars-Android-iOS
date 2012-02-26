//
//  XMLDomLoader.m
//  template
//
//  Created by Efim Voinov on 20.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XMLDomLoader.h"

@implementation XMLDomLoader

@synthesize delegate;

-(id)init
{
	if (self = [super init])
	{
		parser = nil;
	}
	
	return self;
}

-(void)load:(NSString*)url
{
	loaderDelegate = self;
	[super load:url];
}

-(void)loaderFinishedWith:(NSMutableData*)data from:(NSString*)url withSuccess:(BOOL)success
{
	if (!success)
	{
		[delegate xmlLoaderFinishedWith:nil from:url withSuccess:FALSE];
		return;
	}
	
	if (parser)
	{
		[parser release];
	}
	
	parser = [[XMLDocument alloc] init];		
	[parser parseData:data];

	[delegate xmlLoaderFinishedWith:parser->root from:url withSuccess:TRUE];
}

-(void)dealloc
{
	[parser release];
	[super dealloc];
}

@end
