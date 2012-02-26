//
//  Loader.m
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Loader.h"
#import "Debug.h"
#import "FrameworkTypes.h"

@implementation Loader

@synthesize loaderDelegate;

-(void)load:(NSString*)url;
{
	[url retain];
	[loaderUrl release];
	
	loaderUrl = url;
	// create the request	
	NSURLRequest* theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
	
	NSURLConnection* theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection)
	{
		NSMutableData* data = [[NSMutableData data] retain];
		[receivedData release];
		receivedData = data;
	} 
	else
	{
		// inform the user that the download could not be made
		[loaderDelegate loaderFinishedWith:nil from:loaderUrl withSuccess:NO];
	}	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[receivedData setLength:0];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{	
    [connection release];

	if (useCache)
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);		
		NSString* cacheDir = [paths objectAtIndex:0];
		NSString* file = FORMAT_STRING(@"%@%d.tmp", cacheDir, [loaderUrl hash]);
		NSMutableData* data = [[NSMutableData alloc] initWithContentsOfFile:file];
		[receivedData release];
		receivedData = data;		
		
		if (data)
		{
			[loaderDelegate loaderFinishedWith:receivedData from:loaderUrl withSuccess:YES];
			return;
		}		
	}
    
	LOG(FORMAT_STRING(@"Connection failed! %@, %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]));
	BLOCKING_ERROR_ALERT(FORMAT_STRING(@"Connection failed! %@, %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]));
	// inform delegate with error
	[loaderDelegate loaderFinishedWith:nil from:loaderUrl withSuccess:NO];
    //[receivedData release];	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [connection release];
    
	LOG(FORMAT_STRING(@"Succeeded! Received %d bytes of data", [receivedData length]));

	if (useCache)
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);		
		NSString* cacheDir = [paths objectAtIndex:0];
		NSString* file = FORMAT_STRING(@"%@%d.tmp", cacheDir, [loaderUrl hash]);
		if (![receivedData writeToFile:file atomically:TRUE])
		{
			LOG(@"Error! Writing network cache failed!");
		}
	}
	
	[loaderDelegate loaderFinishedWith:receivedData from:loaderUrl withSuccess:YES];	
    //[receivedData release];	
}

-(void)turnOnCache
{
	useCache = TRUE;
}

-(void)deleteCache
{
}

-(void)dealloc
{
	[loaderUrl release];
	[receivedData release];	
	[super dealloc];
}

@end
