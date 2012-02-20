//
//  BannerParser.m
//  champions
//
//  Created by ikoryakin on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BannerParser.h"

@implementation BannerParser

-(void)downloadImage:(NSString*)path saveAs:(NSString*)savePath
{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
	NSURLResponse *response;	
	NSError *error = nil;	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	BOOL success = (!error) && ([(NSHTTPURLResponse *)response statusCode] == 200);
	if(success)
	{
		[responseData writeToFile:savePath atomically:TRUE];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"banner"])
	{
		if(!bannerList)
		{
			bannerList = [[NSMutableArray alloc] init];
		}
		FPBanner* banner = [[[FPBanner alloc] init] autorelease];
		banner.action = [attributeDict objectForKey:@"action"];
		banner.imagePath = [attributeDict objectForKey:@"image"];
		[bannerList addObject:banner];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"bannerList"];
	NSData* data = [NSData dataWithContentsOfFile:path];	
	if(data)
	{
		NSArray* cachedBannerList = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];	
		if(cachedBannerList)
		{
			for (FPBanner* banner in bannerList)
			{
				for (FPBanner* cachedBanner in cachedBannerList)
				{
					if(
					   [cachedBanner.action isEqualToString:banner.action] &&
					   [cachedBanner.imagePath isEqualToString:banner.imagePath]
					   )
					{
						banner.showed = cachedBanner.showed;
						break;
					}
				}
			}
		}
	}
	for (FPBanner* banner in bannerList)
	{
		if(!banner.showed)
		{
			NSString* imageName = [[banner.imagePath pathComponents] lastObject];
			NSString* bannerPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
			UIImage* image = [UIImage imageWithContentsOfFile:path];
			if(!image)
			{
				[self downloadImage:banner.imagePath saveAs:bannerPath];
			}
			
		}
	}
	
	if (bannerList && [bannerList count] > 0)
	{
		NSData* data = [NSKeyedArchiver archivedDataWithRootObject:bannerList];
		[data writeToFile:path atomically:TRUE];
	}
}

-(void)dealloc
{
	if(bannerList)
		[bannerList release];
	[super dealloc];
}
@end
