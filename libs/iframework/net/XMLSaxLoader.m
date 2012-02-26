//
//  XMLLoader.m
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XMLSaxLoader.h"

@implementation XMLSaxLoader

@synthesize delegate;

-(id)init
{
	if (self = [super init])
	{
		parser = [[XMLParser alloc] init];
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
		//TODO: think about error handling
		if ([delegate respondsToSelector:@selector(parser:parseErrorOccurred:)])
		{
			[delegate parser:parser.nsparser parseErrorOccurred:nil];
		}
		return;
	}
	
	parser.delegate = delegate;
	[parser parseData:data];
}

-(void)dealloc
{
	[parser release];
	[super dealloc];
}

@end
