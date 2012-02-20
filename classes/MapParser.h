//
//  MapParser.h
//  champions
//
//  Created by ikoryakin on 3/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Framework.h"
#import "FPBody.h"
#import "FPSettings.h"
#import "FPPolyShape.h"
#import "FPJoint.h"

enum sections
{
	SECTION_NONE = 0,
	SECTION_LIBRARY,
	SECTION_LEVEL,
};

@interface MapParser : NSObject {
	FPSettings* settings;
	DynamicArray* elements;
	DynamicArray* queuedElements;
	DynamicArray* bonuses;
	DynamicArray* library;
	DynamicArray* joints;
	@private
	FPBody* lastBody;
	FPPolyShape* lastPolyShape;
	FPBody* defaultBody;
	FPShape* defaultShape;
	int currentSection;
	int shapesCounter;
	BOOL shapeInLib;
	DynamicArray* outlineVerts;
}

+(Vector)parseCoordinates:(NSString*)str;
-(void)sortQueuedObjects;

+(FPBody*)getBodyFromArray:(DynamicArray*)array withName:(NSString*)bodyName;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@property (readonly) FPSettings *settings;
@property (assign) DynamicArray *elements, *queuedElements, *bonuses, *joints;
@property (retain) DynamicArray *outlineVerts;
@end
