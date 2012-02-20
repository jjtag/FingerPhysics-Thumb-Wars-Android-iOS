//
//  MapParser.m
//  champions
//
//  Created by ikoryakin on 3/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "MapParser.h"
#import "Bonus.h"
#import "ChampionsResourceMgr.h"

@implementation MapParser

@synthesize settings;
@synthesize elements, queuedElements, bonuses, joints, outlineVerts;

-(id)init
{
	if(self = [super init])
	{
		joints = nil;
		library = nil;
		bonuses = nil;
		queuedElements = nil;
		elements = nil;
		settings = nil;
		lastBody = nil;
		lastPolyShape = nil;
		defaultBody = nil;
		defaultShape = nil;
		outlineVerts = nil;		
	}
	return self;
}

-(void)dealloc
{
	[joints release];
	[library release];
	[settings release];
	[elements release];
	[queuedElements release];
	[bonuses release];
	self.outlineVerts = nil;
	[super dealloc];
}

+(Vector)parseCoordinates:(NSString*)str
{
	if ([str isEqualToString:@"0"]) {
		return vectZero;
	}
		 
	NSArray* xy = [str componentsSeparatedByString:@" "];
	return vect([[xy objectAtIndex:0] floatValue]/PTM_RATIO, -[[xy objectAtIndex:1] floatValue]/PTM_RATIO);
	
}

-(FPBody*)searchBodyInLibrary:(NSString*)name
{
	ASSERT(library);
	for(int i = 0; i < [library count]; i++)
	{
		FPBody* body = (FPBody*)[library objectAtIndex:i];
		if([body.name isEqualToString:name])
		{
			return body;
		}
	}
	return nil;
}

#pragma mark body parsing
-(FPBody*)bodyGenericParse:(NSDictionary *)attributeDict
{	
	FPBody* body;
	
	if([attributeDict objectForKey:@"name"])
	{
		NSString* name = [attributeDict objectForKey:@"name"];
		FPBody* libBody = [self searchBodyInLibrary:name];
		if(libBody)
		{
			body = [[libBody copy] autorelease];
			shapeInLib = TRUE;
		}
		else
		{
			body = [[defaultBody copy] autorelease];
			[body.shapes removeAllObjects];
			shapeInLib = FALSE;
			body.name = name;
		}
	}
	else
	{
		if(!defaultBody && SECTION_LIBRARY == currentSection)
			body = [[[FPBody alloc] init] autorelease];
	}

	if([attributeDict objectForKey:@"pos"])
	{
		Vector pos = [MapParser parseCoordinates:[attributeDict objectForKey:@"pos"]];	
		body.pos = vect(pos.x, pos.y+SCREEN_HEIGHT/PTM_RATIO);
	}
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.pos = defaultBody.pos;
		}
	}
	
	if([attributeDict objectForKey:@"massCenter"])
		body.massCenter = [MapParser parseCoordinates:[attributeDict objectForKey:@"massCenter"]];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.massCenter = defaultBody.massCenter;
		}
	}
	
	if([attributeDict objectForKey:@"mass"])
		body.mass = [[attributeDict objectForKey:@"mass"] floatValue];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.mass = defaultBody.mass;
		}
	}
	
	if([attributeDict objectForKey:@"inertia"])
		body.inertia = [[attributeDict objectForKey:@"inertia"] floatValue] / PTM_RATIO / PTM_RATIO;
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.inertia = defaultBody.inertia;
		}
	}
	
	if([attributeDict objectForKey:@"angle"])
		body.angle = DEGREES_TO_RADIANS([[attributeDict objectForKey:@"angle"] floatValue]);
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.angle = defaultBody.angle;
		}
	}
	
	if([attributeDict objectForKey:@"isStatic"])
		body.isStatic = [[attributeDict objectForKey:@"isStatic"] boolValue];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.isStatic = defaultBody.isStatic;
		}
	}

	if([attributeDict objectForKey:@"isExplodable"])
		body->isExplodable = [[attributeDict objectForKey:@"isExplodable"] boolValue];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body->isExplodable = defaultBody->isExplodable;
		}
	}

	if([body.name isEqualToString:@"bumper"])
		body.isStatic = FALSE;
	if([attributeDict objectForKey:@"isFixedRotation"])
		body.isFixedRotation = [[attributeDict objectForKey:@"isFixedRotation"] boolValue];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.isFixedRotation = defaultBody.isFixedRotation;
		}
	}
	
	if([attributeDict objectForKey:@"isTouchable"])
		body.isTouchable = [[attributeDict objectForKey:@"isTouchable"] boolValue];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.isTouchable = defaultBody.isTouchable;
		}
	}

	if([attributeDict objectForKey:@"isBreakable"])
		body.isBreakable = [[attributeDict objectForKey:@"isBreakable"] boolValue];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.isBreakable = defaultBody.isBreakable;
		}
	}
	
	if([attributeDict objectForKey:@"queue"])
		body.queue = [[attributeDict objectForKey:@"queue"] intValue];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.queue = defaultBody.queue;
		}
	}
	
	if([attributeDict objectForKey:@"uniqId"])
		body.uniqId = [[attributeDict objectForKey:@"uniqId"] intValue];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body.uniqId = defaultBody.uniqId;
		}
	}
	
	if([attributeDict objectForKey:@"charge"])
		body->charge = [[attributeDict objectForKey:@"charge"] intValue];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body->charge = defaultBody->charge;
		}
	}

	if([attributeDict objectForKey:@"force"])
		body->force = [MapParser parseCoordinates:[attributeDict objectForKey:@"force"]];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body->force = defaultBody->force;
		}
	}

	if([attributeDict objectForKey:@"forceOffset"])
		body->forceOffset = [MapParser parseCoordinates:[attributeDict objectForKey:@"forceOffset"]];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body->forceOffset = defaultBody->forceOffset;
		}
	}

	if([attributeDict objectForKey:@"forceOffset"])
		body->arrowOffset = [MapParser parseCoordinates:[attributeDict objectForKey:@"arrowOffset"]];
	else
	{
		if(defaultBody && !shapeInLib)
		{
			body->arrowOffset = defaultBody->arrowOffset;
		}
	}
	
	switch (currentSection) {
		case SECTION_LIBRARY:
		{
			if(0 == [library count])
				defaultBody = body;
			[library addObject:body];
			break;
		}
			
		case SECTION_LEVEL:
		{
			if([body.name isEqualToString:@"bonus_star"])
			{
				Bonus* bonus = (Bonus*)[Bonus create:[ChampionsResourceMgr getResource:IMG_STARS_ANIM]];
				[bonus setDrawQuad:IMG_STARS_ANIM_SILVER];
				bonus.body = body;
				bonus->anchor = CENTER;

				Image* shadow = [Image createWithResID:IMG_STARS];
				[shadow setDrawQuad:1];
				shadow->color = MakeRGBA(0, 0, 0, 0.2);
				bonus.shadow = shadow;
				[bonuses addObject:bonus];
				break;
			}
			
			if(body.queue > 0)
			{
				[queuedElements addObject:body];
			}
			else
			{
				[elements addObject:body];
			}	
			break;
		}
		default:
			break;
	}
	return body;
}

#pragma mark shape parsing
-(void)shapeGenericParse:(NSDictionary *)attributeDict shape:(FPShape*)shape
{
	if(0 == shapesCounter)
	{
		[lastBody.shapes removeAllObjects];
		[lastBody releaseOutlineVerts];
	}
	shapesCounter++;
	
	if([attributeDict objectForKey:@"angle"])
		shape.angle = DEGREES_TO_RADIANS([[attributeDict objectForKey:@"angle"] floatValue]);	
	else
	{
		if(defaultShape && !shapeInLib)
		{
			shape.angle = defaultShape.angle;
		}
	}
	if([attributeDict objectForKey:@"density"])
		shape.density = [[attributeDict objectForKey:@"density"] floatValue];
	else
	{
		if(defaultShape && !shapeInLib)
		{
			shape.density = defaultShape.density;
		}
	}
	
	if([attributeDict objectForKey:@"friction"])
		shape.friction = [[attributeDict objectForKey:@"friction"] floatValue];
	else
	{
		if(defaultShape && !shapeInLib)
		{
			shape.friction = defaultShape.friction;
		}
	}
	if([attributeDict objectForKey:@"isSensor"])
		shape.isSensor = [[attributeDict objectForKey:@"isSensor"] boolValue];
	else
	{
		if(defaultShape && !shapeInLib)
		{
			shape.isSensor = defaultShape.isSensor;
		}
	}
	
	if([attributeDict objectForKey:@"restitution"])
		shape.restitution = [[attributeDict objectForKey:@"restitution"] floatValue];
	else
	{
		if(defaultShape && !shapeInLib)
		{
			shape.restitution = defaultShape.restitution;
		}
	}
	
	if([attributeDict objectForKey:@"offset"])
		shape.offset = [MapParser parseCoordinates:[attributeDict objectForKey:@"offset"]];
	else
	{
		if(defaultShape && !shapeInLib)
		{
			shape.offset = defaultShape.offset;
		}
	}
	if([attributeDict objectForKey:@"isVisible"])
		shape.isVisible = [[attributeDict objectForKey:@"isVisible"] boolValue];
	else
	{
		if(defaultShape && !shapeInLib)
		{
			shape.isVisible = defaultShape.isVisible;
		}
	}
	
	[lastBody.shapes addObject:shape];
	shapeInLib = FALSE;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"library"])
	{
		currentSection = SECTION_LIBRARY;
		[library release];
		library = [[DynamicArray alloc] init];
	}

	if([elementName isEqualToString:@"level"])
	{
		currentSection = SECTION_LEVEL;
		[elements release];
		[queuedElements release];
		[bonuses release];
		[joints release];
		elements = [[DynamicArray alloc] init];
		queuedElements = [[DynamicArray alloc] init];
		bonuses = [[DynamicArray alloc] init];
		joints = [[DynamicArray alloc] init];

		lastBody = nil;
		lastPolyShape = nil;
	}
	
	if([elementName isEqualToString:@"body"])
	{
		ASSERT_MSG(!lastBody, FORMAT_STRING(@"Error in xml file at line %i\n", [parser lineNumber]));
		lastBody = [self bodyGenericParse:attributeDict];
		shapesCounter = 0;
		self.outlineVerts = [[[DynamicArray alloc] init] autorelease];
	}
	
	if([elementName isEqualToString:@"shape"])
	{
		ASSERT(SECTION_LIBRARY == currentSection);
		ASSERT_MSG(lastBody, FORMAT_STRING(@"Error in xml file at line %i\n", [parser lineNumber]));
		FPShape* shape = [[[FPShape alloc] init] autorelease];
		[self shapeGenericParse:attributeDict shape:shape];
		defaultShape = shape;
	}
	
	if([elementName isEqualToString:@"circle"])
	{
		ASSERT_MSG(lastBody, FORMAT_STRING(@"Error in xml file at line %i\n", [parser lineNumber]));
		FPCircleShape* shape = [[[FPCircleShape alloc] init] autorelease];		
		if(defaultShape)
			[shape copyAttributesFrom:defaultShape];
		shape.radius = [[attributeDict objectForKey:@"radius"] floatValue] / PTM_RATIO;
		[self shapeGenericParse:attributeDict shape:shape];
	}
	
	if([elementName isEqualToString:@"poly"])
	{
		ASSERT_MSG(lastBody, FORMAT_STRING(@"Error in xml file at line %i\n", [parser lineNumber]));
		FPPolyShape* shape;
		shape = [[[FPPolyShape alloc] init] autorelease];
	
		if(defaultShape)
			[shape copyAttributesFrom:defaultShape];
		
		lastPolyShape = shape;
		[self shapeGenericParse:attributeDict shape:shape];
	}
	
	if([elementName isEqualToString:@"vert"])
	{
		ASSERT_MSG(lastPolyShape, FORMAT_STRING(@"Error in xml file at line %i\n", [parser lineNumber]));
		NSString* xy = [attributeDict objectForKey:@"xy"];
		[lastPolyShape.vertices addObject:xy];
		
		if([attributeDict objectForKey:@"v"])
		{
			ASSERT(outlineVerts);
			int v = [[attributeDict objectForKey:@"v"] intValue];
			Vector vxy = [MapParser parseCoordinates:xy];
			vxy = vectAdd(vxy, lastPolyShape.offset);
			vxy = vectRotate(vxy, lastPolyShape.angle);
			vxy = vectMult(vxy, PTM_RATIO);
			[outlineVerts setObject:FORMAT_STRING(@"%f %f", vxy.x, -vxy.y) At:v-1];
		}
	}
#pragma mark Settings		
	if([elementName isEqualToString:@"settings"])
	{
			switch (currentSection) {
				case SECTION_LIBRARY:
				{
					self.outlineVerts = [[[DynamicArray alloc] init] autorelease];

					ASSERT_MSG(!lastBody, FORMAT_STRING(@"Error in xml file at line %i\n", [parser lineNumber]));
					lastBody = [self bodyGenericParse:attributeDict];
					ASSERT([library getObjectIndex:lastBody] == 0);
					break;
				}
				case SECTION_LEVEL:
				{
					[settings release];
					settings = [[FPSettings alloc] init];
					settings.description = [attributeDict objectForKey:@"descr"];
					settings.gravity = [MapParser parseCoordinates:[attributeDict objectForKey:@"gravity"]];
					settings.mode = [[attributeDict objectForKey:@"mode"] intValue];
					settings.height = [[attributeDict objectForKey:@"height"] floatValue];
					settings.width = [[attributeDict objectForKey:@"width"] floatValue];
					settings.iterations = [[attributeDict objectForKey:@"iterations"] intValue];					
					settings.maxMouseForce = [[attributeDict objectForKey:@"maxMouseForce"] floatValue];
					
					if([attributeDict objectForKey:@"mouseBodyMass"])
					{
						settings->mouseBodyMass = [[attributeDict objectForKey:@"mouseBodyMass"] floatValue];
					}
					else
					{
						settings->mouseBodyMass = 0.1f;
					}
					
					if([attributeDict objectForKey:@"magnetDampingRatio"])
					{
						settings->magnetDampingRatio = [[attributeDict objectForKey:@"magnetDampingRatio"] floatValue];
					}
					else
					{
						settings->magnetDampingRatio = 1.0f;
					}
					
					if([attributeDict objectForKey:@"magnetFreqHz"])
					{
						settings->magnetFreqHz = [[attributeDict objectForKey:@"magnetFreqHz"] intValue];
					}
					else
					{
						settings->magnetFreqHz = 30;
					}
					
					if([attributeDict objectForKey:@"magnetImpulseMultiplier"])
					{
						settings->magnetImpulseMultiplier = [[attributeDict objectForKey:@"magnetImpulseMultiplier"] intValue];
					}
					else
					{
						settings->magnetImpulseMultiplier = 5;
					}
					
					if([attributeDict objectForKey:@"magnetMinJointDistance"])
					{
						settings->magnetMinJointDistance = [[attributeDict objectForKey:@"magnetMinJointDistance"] intValue]/PTM_RATIO;
					}
					else
					{
						settings->magnetMinJointDistance = 1;
					}					
					
					if([attributeDict objectForKey:@"shockWaveWidth"])
					{
						settings->shockWaveWidth = [[attributeDict objectForKey:@"shockWaveWidth"] floatValue];
					}
					else
					{
						settings->shockWaveWidth = 30.0f;
					}

					if([attributeDict objectForKey:@"shockWaveSpeed"])
					{
						settings->shockWaveSpeed = [[attributeDict objectForKey:@"shockWaveSpeed"] floatValue];
					}
					else
					{
						settings->shockWaveSpeed = 500;
					}

					if([attributeDict objectForKey:@"shockWaveImpulseFactor"])
					{
						settings->shockWaveImpulseFactor = [[attributeDict objectForKey:@"shockWaveImpulseFactor"] floatValue];
					}
					else
					{
						settings->shockWaveImpulseFactor = 200;
					}
					
					if([attributeDict objectForKey:@"shockWaveMaxRadius"])
					{
						settings->shockWaveMaxRadius = [[attributeDict objectForKey:@"shockWaveMaxRadius"] floatValue];
					}
					else
					{
						settings->shockWaveMaxRadius = 1000;
					}
					
					if([attributeDict objectForKey:@"maxShockWaveBodyVelocity"])
					{
						settings->maxShockWaveBodyVelocity = [[attributeDict objectForKey:@"maxShockWaveBodyVelocity"] floatValue];
					}
					else
					{
						settings->maxShockWaveBodyVelocity = 50;
					}
					
					if(settings.maxMouseForce == 0) settings.maxMouseForce = 1000;
					if(settings.width == 0) settings.width = SCREEN_WIDTH;
					if(settings.height == 0) settings.height = SCREEN_HEIGHT; 
					break;
				}
				default:
					break;
			}
	}
#pragma mark Joint
	if([elementName isEqualToString:@"joint"] && currentSection == SECTION_LEVEL)
	{
		FPJoint* joint = [[[FPJoint alloc] init] autorelease];
		[joints addObject:joint];
		
		joint->type = [[attributeDict objectForKey:@"type"] intValue];
		joint->rotationOffset = [MapParser parseCoordinates:[attributeDict objectForKey:@"rotationOffset"]];
		joint->offsetBody1 = [MapParser parseCoordinates:[attributeDict objectForKey:@"offset1"]];
		joint->offsetBody2 = [MapParser parseCoordinates:[attributeDict objectForKey:@"offset2"]];
		joint->rotationSpeed = [[attributeDict objectForKey:@"rotationSpeed"] floatValue];
		joint->maxMotorTorque = [[attributeDict objectForKey:@"maxMotorTorque"] floatValue];
		joint->body1Id = [[attributeDict objectForKey:@"body1Id"] intValue];
		joint->body2Id = [[attributeDict objectForKey:@"body2Id"] intValue];
		joint->collideConnected = [[attributeDict objectForKey:@"isCollides"] boolValue];
		joint->freqHz = [[attributeDict objectForKey:@"freqHz"] floatValue];
		joint->dampingRatio = [[attributeDict objectForKey:@"dampingRatio"] floatValue];
		
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if([elementName isEqualToString:@"poly"])
	{
		
		lastPolyShape = nil;
	}
	
	if([elementName isEqualToString:@"body"])
	{
		int vertexCount = [outlineVerts count];
		if(outlineVerts && lastBody)
		{
			if (vertexCount != 0)
			{
				[lastBody allocOutlineVerts:vertexCount];	
			
				for (int i = 0; i < vertexCount; i++)
				{
					Vector vect = [MapParser parseCoordinates:[outlineVerts objectAtIndex:i]];
					vect = vectMult(vect, PTM_RATIO);
					lastBody.outlineVerts[i*2] = vect.x;
					lastBody.outlineVerts[i*2+1] = vect.y;			
				}
			}	
		}
		self.outlineVerts = nil;
	}
	
	if([elementName isEqualToString:@"body"] || ([elementName isEqualToString:@"settings"] && SECTION_LIBRARY == currentSection))
	{
		ASSERT_MSG([lastBody.shapes count] > 0, FORMAT_STRING(@"Error in xml file at line %i.\nBody must have at least one shape.\n", [parser lineNumber]));
		
		shapeInLib = FALSE;
		lastBody = nil;
	}
	
	if([elementName isEqualToString:@"library"] || [elementName isEqualToString:@"level"])
	{
		currentSection = SECTION_NONE;
	}
	
	if([elementName isEqualToString:@"level"])
	{
		defaultBody = nil;
		defaultShape = nil;
		lastBody = nil;
		lastPolyShape = nil;
	}
}

-(void)sortQueuedObjects
{
	int count = [queuedElements count];
	for(int i = 0; i < count-1; i++)
	{
		for(int j = 0; j<=count-2-i; j++)
		{
			FPBody* fpb = [queuedElements objectAtIndex:j];
			FPBody* fpb2 = [queuedElements objectAtIndex:j+1];
			if(fpb.queue > fpb2.queue)
			{
				[queuedElements setObject:fpb At:j+1];
				[queuedElements setObject:fpb2 At:j];
			}
		}
	}
}

+(FPBody*)getBodyFromArray:(DynamicArray*)array withName:(NSString*)bodyName
{
	for(int i = 0; i < [array count]; i++)
	{
		FPBody* body = (FPBody*)[array objectAtIndex:i];
		if([body.name isEqualToString:bodyName])
		{
			return body;
		}
	}
	return nil;
}

@end
