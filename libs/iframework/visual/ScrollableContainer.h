//
//  GLScrollableContainer.h
//  rogatka
//
//  Created by Mac on 28.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"
#import "Scrollbar.h"

@class ScrollableContainer;

@protocol ScrollableContainerProtocol
-(void)reachedScrollableContainer:(ScrollableContainer*)e scrollPoint:(int)i;
-(void)changedScrollableContainer:(ScrollableContainer*)e targetScrollPoint:(int)i;
@end


enum {TOUCH_STATE_UP, TOUCH_STATE_DOWN, TOUCH_STATE_MOVING};

// touch - scrollable container. All childs coordinates are relative to the top left corner of the container.
// redraws only visible childs. supports "scroll points" - stable scroll positions. 
@interface ScrollableContainer : BaseElement <ScrollbarProvider>
{
@protected
	BaseElement* container;
	Vector dragStart;
	Vector move;
	bool movingByInertion;
	float inertiaTimeoutLeft;	

	float calcNearesetSpointTimout;
	bool movingToSpoint;
	int targetSpoint;
	int lastTargetSpoint;
	float scrollToPointDurationMultiplier;
	
	Vector* spoints;
	int spointsNum;
	int spointsCapacity;
	
	id <ScrollableContainerProtocol> delegate; 
	
	float touchState;
	
	TimeType touchTimer;
	TimeType touchReleaseTimer;
	Vector savedTouch;
	Vector totalDrag;
	bool passTouches;
	
@public
	
	float deaccelerationSpeed; // deacceleration of inertial-scrolling 
	float inertiaTimeout; // timeout between touchMove and touchUp after which no inertial-scrolling occurs	
	float scrollToPointDuration; // the higher this value, the faster scrolling to point will occur	
	
	bool canSkipScrollPoints; // if TRUE, you can move only between neighbor scroll points, if FALSE - they will be skipped based on movement speed;
	bool shouldBounceHorizontally;
	bool shouldBounceVertically;
	
	float touchMoveIgnoreLength; // minimum touch move length that will be passed to childs
	float maxTouchMoveLength; // maximum touch move length
	
    TimeType touchPassTimeout; // timeout after which touch down will be passed to childs
	
	bool resetScrollOnShow; // container will automatically scroll to beginning when shown
	bool dontHandleTouchDownsHandledByChilds; // if touch event was handled by child, dont try to handle it
	bool dontHandleTouchMovesHandledByChilds;
	bool dontHandleTouchUpsHandledByChilds;

	bool untouchChildsOnMove; // if container moved - send up events to childs
}

@property (assign) id<ScrollableContainerProtocol> delegate;

// container should be provided
-(id)initWithWidth:(float)w Height:(float)h Container:(BaseElement*)c;

// container will be created
-(id)initWithWidth:(float)w Height:(float)h ContainerWidth:(float)cw Height:(float)ch;

// support for scroll points
-(void)turnScrollPointsOnWithCapacity:(int)n;

// scroll point coordinates are set as the offset from the top left corner of the scrollable container to the top left corner of the screen
-(int)addScrollPointAtX:(float)sx Y:(float)sy;
-(void)addScrollPointAtX:(float)sx Y:(float)sy withID:(int)i;

-(Vector)getScroll;
-(Vector)getMaxScroll;
-(void)setScroll:(Vector)s;
-(void)placeToScrollPoint:(int)sp;

// private
-(void)calculateNearsetScrollPoint;
-(void)moveContainerBy:(Vector)off;

-(void)moveToPoint:(Vector)tsp Delta:(TimeType)delta Duration:(float)scrollDuration;

@end
