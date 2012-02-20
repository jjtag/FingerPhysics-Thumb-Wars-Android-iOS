//
//  MapsListParser.m
//  champions
//
//  Created by ikoryakin on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Framework.h"
#import "MapsListParser.h"

@implementation MapsListParser

+(DynamicArray*)create
{
//#ifdef MAP_PICKER
//	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
//	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"maplist.xml"];
//#else
	NSString* path = [[NSBundle mainBundle] pathForResource:@"maplist" ofType:@"xml"];
//#endif
	NSData* data = [NSData dataWithContentsOfFile:path];
	if(data)
	{
		MapsListParser* listParser = [[[[self class] alloc] initWithData:data] autorelease];
		[listParser setDelegate:listParser];
		[listParser parse];
		return listParser->mapslist;
	}
	return nil;
}

-(id)initWithData:(NSData*)data
{
	if(self = [super initWithData:data])
	{
		mapslist = [[DynamicArray alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[mapslist release];
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"levelset"])
	{
		LevelSet* set = [[[LevelSet alloc] init] autorelease];
		set.name = [attributeDict objectForKey:@"name"];
		set->type = [[attributeDict objectForKey:@"type"] intValue];
		set->queue = [[attributeDict objectForKey:@"queue"] intValue];
		if(mapslist)
		{
			lastLevelSet = set;
			[mapslist addObject:set];
		}
	}
	
	if([elementName isEqualToString:@"map"])
	{
		if(lastLevelSet)
		{
			NSString* mapName = [attributeDict objectForKey:@"name"];
			[lastLevelSet->list addObject:mapName];
#ifdef DEBUG 
#ifndef MAP_PICKER			
			NSString* path = [[NSBundle mainBundle] pathForResource:mapName ofType:@""];
			ASSERT_MSG(path, FORMAT_STRING(@"Map not found: %@", mapName));
#endif
#endif
		}
	}
}

+(int)countMapsWitPrefix:(NSString*)prefix inList:(DynamicArray*)mapslist
{
	int count = 0;
	for (LevelSet* set in mapslist)
	{
		for(NSString* mapName in set->list)
		{
			if([mapName hasPrefix:prefix])
				count++;
		}
	}
	return count;
}

@end
