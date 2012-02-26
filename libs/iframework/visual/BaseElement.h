//
//  InteractiveAnimatable.h
//  blockit
//
//  Created by Efim Voinov on 26.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamicArray.h"
#import "FrameworkTypes.h"
#import "Timeline.h"

// general actions
extern const NSString* ACTION_SET_VISIBLE;
extern const NSString* ACTION_SET_TOUCHABLE;
extern const NSString* ACTION_SET_UPDATEABLE;

extern const NSString* ACTION_PLAY_TIMELINE;
extern const NSString* ACTION_PAUSE_TIMELINE;
extern const NSString* ACTION_STOP_TIMELINE;
extern const NSString* ACTION_JUMP_TO_TIMELINE_FRAME;

@class XMLNode;

// base class for all drawable and animatable objects
@interface BaseElement : NSObject 
{
@public	
	BaseElement* parent;	
	
	bool visible;
	bool touchable;
	bool updateable;
	
	NSString* name;
	
	float x;
	float y;

	// absolute coords of top left corner
	float drawX;
	float drawY;		
	
	int width;
	int height;
	
	float rotation;

	// rotation center offset from the element center
	float rotationCenterX;
	float rotationCenterY;
	
	// use scaleX = -1 for horizontal flip, scaleY = -1 for vertical
	float scaleX;
	float scaleY;
	
	RGBAColor color;
	
	float translateX;
	float translateY;	

	// sets anchor on the element
	char anchor;
	// sets anchor on the parent
	char parentAnchor;
	
	// features
    
	// childs will inherit transformations of the parent
	bool passTransformationsToChilds;

	// childs will inherit color of the parent
	bool passColorToChilds;

	// touch events can be handled by multiple childs
	bool passTouchEventsToAllChilds;

@protected	
	DynamicArray* childs;
	DynamicArray* timelines;
	
@private
	int currentTimelineIndex;
	Timeline* currentTimeline;
}

@property (assign) BaseElement* parent;

// general behavior
-(id)init;
-(void)preDraw;
-(void)draw;
-(void)postDraw;
-(void)update:(TimeType)delta;
-(BaseElement*)getChildWithName:(NSString*)n;

// element show / hide
-(void)show;
-(void)hide;

// xml element creation
+(BaseElement*)createFromXML:(XMLNode*)xml;
+(int)parseAlignmentString:(NSString*)s;

// action handling
-(bool)handleAction:(ActionData)a;

// child handling
-(void)addChild:(BaseElement*)c withID:(int)i;
// adds child to first empty slot and returns it's id
-(int)addChild:(BaseElement*)c;
-(void)removeChildWithID:(int)i;
-(void)removeChild:(BaseElement*)c;
-(void)removeAllChilds;
-(BaseElement*)getChild:(int)i;
-(int)childsCount;
-(DynamicArray*)getChilds;

// timeline
-(int)addTimeline:(Timeline*)t;
-(void)addTimeline:(Timeline*)t withID:(int)i;
-(void)playTimeline:(int)t;
-(void)pauseCurrentTimeline;
-(void)stopCurrentTimeline;
-(Timeline*)getCurrentTimeline;
-(Timeline*)getTimeline:(int)n;
-(int)getCurrentTimelineIndex;

// single touch handling, returnes TRUE if touch changed element, FALSE otherwise
-(bool)onTouchDownX:(float)tx Y:(float)ty;
-(bool)onTouchUpX:(float)tx Y:(float)ty;
-(bool)onTouchMoveX:(float)tx Y:(float)ty;

-(void)setEnabled:(bool)e;
-(bool)isEnabled;

-(void)setName:(NSString*)n;
-(void)setSizeToChildsBounds;

@end

#ifdef __cplusplus
extern "C" {
#endif
void restoreTransformations(BaseElement* t);
void calculateTopLeft(BaseElement* e);
#ifdef __cplusplus
}
#endif