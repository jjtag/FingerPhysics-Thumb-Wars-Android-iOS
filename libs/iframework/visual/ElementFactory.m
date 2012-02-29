//
//  GLElementFactory.m
//  template
//
//  Created by Mac on 30.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ElementFactory.h"
#import "Framework.h"

#define DEFAULT_MAX_KEY_FRAMES 20

@implementation PostLinkData
-(id)initWithAddress:(BaseElement**)a andName:(NSString*)n
{
	if (self = [super init])
	{
		address = a;
		name = [n retain];
	}
	
	return self;
}

-(void)dealloc
{
	[name release];
	[super dealloc];
}

@end


@implementation ElementFactory

-(id)init
{
	if (self = [super init])
	{
		postLink = [[DynamicArray alloc] init];		
	}
	
	return self;
}

-(void)dealloc
{
	[postLink release];
	[super dealloc];
}

-(BaseElement*)generateElement:(XMLNode*)xml
{		
	[postLink removeAllObjects];
	BaseElement* element = [self generateElementsRecursively:xml];
	
	for (PostLinkData* p in postLink)
	{
		BaseElement* child = [element getChildWithName:p->name];
		XML_ASSERT_MSG(child, @"Can't postlink timeline action", xml);
		*p->address = child;
	}
	
	return element;
}

-(BaseElement*)generateElementsRecursively:(XMLNode*)xml
{		
	NSString* tagName = xml->name;
	
	Class elementClass = NSClassFromString(tagName);
	
	if (elementClass == nil)
	{
		return nil;
	}

	BaseElement* element = [elementClass createFromXML:xml];
	[self setBasicParams:xml forElement:element];
	
	if (xml->childs)
	for (int i = 0; i < [xml->childs count]; i++)
	{
		XMLNode* c = [xml->childs objectAtIndex:i];
		NSString* childName = c->name;
		
		if ([childName isEqualToString:@"Timeline"] || [childName isEqualToString:@"Sequence"])
		{
			ASSERT(c->attributes);
			NSString* idObj = [c->attributes objectForKey:@"ID"];
			ASSERT(idObj);
			int tid = [idObj intValue];
			
			Timeline* t = [self createTimeline:c forElement:element];
			[element addTimeline:t withID:tid];
		}
		else
		{
			BaseElement* child = [self generateElementsRecursively:c];
			if (child)
			{
				[element addChild:child];
			}
		}
	}
	
	return element;
}

-(void)createKeyFrame:(XMLNode*)n forTimeline:(Timeline*)t ofType:(int)type  Element:(BaseElement*)e
{
	XML_ASSERT_DATA(n);
	NSString* data = n->data;
	NSArray* kf = [data componentsSeparatedByString:@"+"];
	TimeType time = 0;
	for (NSString* c in kf)
	{
		NSArray* sp = [c componentsSeparatedByString:@"@"];
		ASSERT_MSG([sp count] == 2, @"Error in timeline");
		time = [[sp objectAtIndex:1] floatValue];
		NSArray* ps = [[sp objectAtIndex:0] componentsSeparatedByString:@","];
		
		switch (type)
		{
			case TRACK_POSITION:
				XML_ASSERT_MSG([ps count] == 2, @"Error in timeline", n);		
				[t addKeyFrame:makePos([[ps objectAtIndex:0] floatValue], [[ps objectAtIndex:1] floatValue], 
									   FRAME_TRANSITION_LINEAR, time)];
				break;
				
			case TRACK_SCALE:
				XML_ASSERT_MSG([ps count] == 2, @"Error in timeline", n);		
				[t addKeyFrame:makeScale([[ps objectAtIndex:0] floatValue], [[ps objectAtIndex:1] floatValue], 
										 FRAME_TRANSITION_LINEAR, time)];				
				break;
				
			case TRACK_ROTATION:
				XML_ASSERT_MSG([ps count] == 1, @"Error in timeline", n);		
				[t addKeyFrame:makeRotation([[ps objectAtIndex:0] floatValue], FRAME_TRANSITION_LINEAR, time)];				
				break;
				
			case TRACK_COLOR:
				XML_ASSERT_MSG([ps count] == 4, @"Error in timeline", n);		
				RGBAColor c = MakeRGBA([[ps objectAtIndex:0] floatValue], [[ps objectAtIndex:1] floatValue], 
									   [[ps objectAtIndex:2] floatValue], [[ps objectAtIndex:3] floatValue]);
				
				[t addKeyFrame:makeColor(c, FRAME_TRANSITION_LINEAR, time)];				
				break;
				
			case TRACK_ACTION:
				XML_ASSERT_MSG([ps count] % 4 == 0, @"Error in timeline", n);		
				DynamicArray* as = [[DynamicArray allocAndAutorelease] init];
				for (int i = 0; i < [ps count]; i += 4)
				{
					NSString* action = [ps objectAtIndex:i];
					NSString* name = [ps objectAtIndex:i + 1];
					int param = [[ps objectAtIndex:i + 2] intValue];
					int subParam = [[ps objectAtIndex:i + 3] intValue];
					if ([name isEqualToString:@"self"])
					{
						[as addObject:createAction(e, action, param, subParam)];											
					}
					else
					{
						Action* ac = createAction(nil, action, param, subParam);
						[as addObject:ac];					
						PostLinkData* o = [[PostLinkData allocAndAutorelease] initWithAddress:&ac->actionTarget andName:name];
						[postLink addObject:o];
					}
				}
				[t addKeyFrame:makeAction(as, time)];
				break;
		}
	}
	
	Track* track = [t getTrack:type];
	
	if ([n hasAttr:@"relative"])
	{
		track->relative = [n intAttr:@"relative"] != 0;
	}
}

-(Timeline*)createTimeline:(XMLNode*)timeline forElement:(BaseElement*)e
{	
	int mf = ([timeline hasAttr:@"maxKeyFrames"]) ? [timeline intAttr:@"maxKeyFrames"] : DEFAULT_MAX_KEY_FRAMES;
	Timeline* t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:mf];
	int l = TIMELINE_NO_LOOP;
	
	if ([timeline hasAttr:@"loop"])
	{
		l = [timeline intAttr:@"loop"];
		[t setTimelineLoopType:l];
	}

	if ([timeline->name isEqualToString:@"Sequence"])
	{
		XML_ASSERT_DATA(timeline);
		NSArray* ps = [timeline->data componentsSeparatedByString:@","];		
		XML_ASSERT_ATTR(@"delay", timeline);
		float d = [timeline floatAttr:@"delay"];
		float cd;
		DynamicArray* as = nil;
		for (NSString* f in ps)
		{
			cd = d;
			
			if (l == TIMELINE_PING_PONG && t->tracks[TRACK_ACTION] == nil)
			{
				cd = 0.0;
			}
			
			as = [[DynamicArray allocAndAutorelease] init];
			if ([f rangeOfString:@"@"].length > 0)
			{
				NSArray* ps = [f componentsSeparatedByString:@"@"];	
				XML_ASSERT_MSG([ps count] == 2, @"Sequence error", timeline);
				NSString* v = [ps objectAtIndex:1];
				if ([v isEqualToString:@"p"])
				{
					[as addObject:createAction(e, (NSString*)ACTION_PAUSE_TIMELINE, 0, 0)];					
				}
				else
				{
					cd = [v floatValue];
				}
			}
			
			[as addObject:createAction(e, (NSString*)ACTION_SET_DRAWQUAD, [f intValue], 0)];
			[t addKeyFrame:makeAction(as, cd)];			
		}
		if (l == TIMELINE_REPLAY)
		{
			[t addKeyFrame:makeAction(as, cd)];			
		}						
		
		return t;
	}	
	
	XMLNode* posNode = [timeline findChildWithTagName:@"Pos" Recursively:FALSE];
	XMLNode* scaleNode = [timeline findChildWithTagName:@"Scale" Recursively:FALSE];
	XMLNode* rotationNode = [timeline findChildWithTagName:@"Rotation" Recursively:FALSE];
	XMLNode* colorNode = [timeline findChildWithTagName:@"Color" Recursively:FALSE];
	XMLNode* actionNode = [timeline findChildWithTagName:@"Action" Recursively:FALSE];
	
	if (posNode)
	{
		[self createKeyFrame:posNode forTimeline:t ofType:TRACK_POSITION Element:e];
	}
		
	if (scaleNode)
	{
		[self createKeyFrame:scaleNode forTimeline:t ofType:TRACK_SCALE Element:e];	
	}
	
	if (rotationNode)
	{
		[self createKeyFrame:rotationNode forTimeline:t ofType:TRACK_ROTATION Element:e];	
	}	
	
	if (colorNode)
	{
		[self createKeyFrame:colorNode forTimeline:t ofType:TRACK_COLOR Element:e];	
	}	
	
	if (actionNode)
	{
		[self createKeyFrame:actionNode forTimeline:t ofType:TRACK_ACTION Element:e];	
	}		
	
	return t;			   
}

-(void)setBasicParams:(XMLNode*)xml forElement:(BaseElement*)e
{
	if (!xml->attributes)
	{
		return;
	}
	
	NSArray* keys = [xml->attributes allKeys];
	for (int i = 0; i < [xml->attributes count]; i++)
	{
		NSString* n = [keys objectAtIndex:i];
        
		if ([n isEqualToString:@"name"])
		{
			[e setName:[xml stringAttr:n]];			
		}
		else if ([n isEqualToString:@"color"])
		{
			NSString* colorString = [xml stringAttr:n];
			NSArray* ar = [colorString componentsSeparatedByString:@","];
			XML_ASSERT_MSG([ar count] == 4, @"Wrong color", xml);
			e->color.r = [[ar objectAtIndex:0] floatValue];
			e->color.g = [[ar objectAtIndex:1] floatValue];
			e->color.b = [[ar objectAtIndex:2] floatValue];
			e->color.a = [[ar objectAtIndex:3] floatValue];
		}
		else if ([n isEqualToString:@"x"])
		{
			e->x = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"y"])
		{
			e->y = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"scaleX"])
		{
			e->scaleX = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"scaleY"])
		{
			e->scaleY = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"scale"])
		{
			e->scaleX = e->scaleY = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"rotation"])
		{
			e->rotation = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"rotationCenterX"])
		{
			e->rotationCenterX = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"rotationCenterY"])
		{
			e->rotationCenterY = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"translateX"])
		{
			e->translateX = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"translateY"])
		{
			e->translateY = [xml floatAttr:n];
		}
		else if ([n isEqualToString:@"visible"])
		{
			e->visible = [xml intAttr:n] != 0;
		}
		else if ([n isEqualToString:@"touchable"])
		{
			e->touchable = [xml intAttr:n] != 0;
		}
		else if ([n isEqualToString:@"updateable"])
		{
			e->updateable = [xml intAttr:n] != 0;
		}
		else if ([n isEqualToString:@"passTransformationsToChilds"])
		{
			e->passTransformationsToChilds = [xml intAttr:n] != 0;
		}
		else if ([n isEqualToString:@"passColorToChilds"])
		{
			e->passColorToChilds = [xml intAttr:n] != 0;
		}		
		else if ([n isEqualToString:@"passTouchEventsToAllChilds"])
		{
			e->passTouchEventsToAllChilds = [xml intAttr:n] != 0;
		}
		else if ([n isEqualToString:@"width"])
		{
			e->width = [xml intAttr:n];
		}		
		else if ([n isEqualToString:@"height"])
		{
			e->height = [xml intAttr:n];
		}
		else if ([n isEqualToString:@"anchor"])
		{
			e->anchor = [BaseElement parseAlignmentString:[xml stringAttr:n]];
		}		
		else if ([n isEqualToString:@"parentAnchor"])
		{
			e->parentAnchor = [BaseElement parseAlignmentString:[xml stringAttr:n]];
		}				
	}
}

@end
