//
//  NewsParser.m
//  champions
//
//  Created by ikoryakin on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewsParser.h"


@implementation NewsParser

-(void)dealloc
{
	if(newsArray)
		[newsArray release];
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	if([elementName isEqualToString:@"text"])
	{
		if(!newsArray)
			newsArray = [[NSMutableArray alloc] init];
		[newsArray addObject:[attributeDict objectForKey:@"string"]];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	if(newsArray && [newsArray count] > 0)
	{
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
		NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"news"];
		[newsArray writeToFile:path atomically:TRUE];
	}
}

@end
