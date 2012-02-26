//
//  XMLParser.m
//  rogatka
//
//  Created by Efim Voinov on 31.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

@synthesize nsparser;
@synthesize delegate;

-(id)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

-(void)parseData:(NSData*)data
{
	if (nsparser)
	{
		[nsparser release];
	}
	
	nsparser = [[NSXMLParser alloc] initWithData:data];
	[nsparser setDelegate:delegate];	
	[nsparser setShouldResolveExternalEntities:YES];		
	
	// start parsing XML and send parse messages to delegate
	[nsparser parse];		
}

-(void)dealloc
{
	[nsparser release];
	[super dealloc];
}

@end
