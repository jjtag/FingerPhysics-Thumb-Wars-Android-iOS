//
//  MapsListParser.h
//  champions
//
//  Created by ikoryakin on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Framework.h"
#import "LevelSet.h"

@interface MapsListParser : NSXMLParser
{
	DynamicArray* mapslist;
	LevelSet* lastLevelSet;
}

+(DynamicArray*)create;
+(int)countMapsWitPrefix:(NSString*)prefix inList:(DynamicArray*)mapslist;

@end
