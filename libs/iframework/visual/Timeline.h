//
//  Timeline.h
//  template
//
//  Created by Mac on 23.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FrameworkTypes.h"

// timeline looping types
enum {TIMELINE_NO_LOOP, TIMELINE_REPLAY, TIMELINE_PING_PONG};

@class DynamicArray;
@class BaseElement;
@class Timeline;

typedef struct PosParams
{
	float x;
	float y;
} PosParams;

typedef struct ScaleParams
{
	float scaleX;
	float scaleY;
} ScaleParams;

typedef struct RotationParams
{
	float angle;
} RotationParams;

typedef struct ColorParams
{
	RGBAColor rgba;
} ColorParams;

typedef struct ActionParams
{
	DynamicArray* actionSet;
	
} ActionParams;

typedef union KeyFrameValue
{
	PosParams pos;
	ScaleParams scale;
	RotationParams rotation;
	ColorParams color;
	ActionParams action;
} KeyFrameValue;

enum {FRAME_TRANSITION_LINEAR, FRAME_TRANSITION_IMMEDIATE, FRAME_TRANSITION_EASE_IN, FRAME_TRANSITION_EASE_OUT};

typedef struct KeyFrame
{
	TimeType timeOffset;
	int trackType;
	int transitionType;
	KeyFrameValue value;
} KeyFrame;

@protocol TimelineDelegate
-(void)timeline:(Timeline*)t reachedKeyFrame:(KeyFrame*)k withIndex:(int)i;
-(void)timelineFinished:(Timeline*)t;
@end

enum {TRACK_POSITION, TRACK_SCALE, TRACK_ROTATION, TRACK_COLOR, TRACK_ACTION, TRACKS_COUNT};
enum {TRACK_NOT_ACTIVE, TRACK_ACTIVE};

typedef struct ActionData
{
	const NSString* actionName;
	int actionParam;
	int actionSubParam;
	
} ActionData;

@interface Action : NSObject
{
@public
	BaseElement* actionTarget;
	ActionData data;
}

@end

#ifdef __cplusplus
extern "C" {
#endif
	
	Action* createAction(BaseElement* target, NSString* action, int p, int sp);
	
	static inline KeyFrame makePos(int x, int y, int transition, TimeType time) {
		KeyFrameValue v; v.pos.x = x; v.pos.y = y;
	KeyFrame kf = {time, TRACK_POSITION, transition, v}; return kf; };
	
	static inline KeyFrame makeScale(float x, float y, int transition, TimeType time) {
		KeyFrameValue v; v.scale.scaleX = x; v.scale.scaleY = y;
	KeyFrame kf = {time, TRACK_SCALE, transition, v}; return kf; };
	
	static inline KeyFrame makeRotation(int r, int transition, TimeType time) {
		KeyFrameValue v; v.rotation.angle = r;
	KeyFrame kf = {time, TRACK_ROTATION, transition, v}; return kf; };
	
	static inline KeyFrame makeColor(RGBAColor c, int transition, TimeType time) {
		KeyFrameValue v; v.color.rgba = c;
	KeyFrame kf = {time, TRACK_COLOR, transition, v}; return kf; };
	
	static inline KeyFrame makeAction(DynamicArray* actions, TimeType time) {
		KeyFrameValue v; v.action.actionSet = actions;
	KeyFrame kf = {time, TRACK_ACTION, FRAME_TRANSITION_LINEAR, v}; return kf; };
	
#ifdef __cplusplus
}
#endif

@interface Track : NSObject
{
@public
	int type;
	int state;
	bool relative;
	
	TimeType startTime;
	TimeType endTime;

	int keyFramesCount;
	KeyFrame* keyFrames;	
	
	Timeline* t;
	
	int nextKeyFrame;
	int keyFramesCapacity;	
	KeyFrame currentStepPerSecond;
	KeyFrame currentStepAcceleration;
	TimeType keyFrameTimeLeft;
	KeyFrame elementPrevState;
	
	TimeType overrun;	
	DynamicArray* actionSets;
}

-(id)initWithTimeline:(Timeline*)timeline Type:(int)trackType andMaxKeyFrames:(int)m;
-(void)initActionKeyFrame:(KeyFrame*)kf andTime:(TimeType)time;
-(void)addKeyFrame:(KeyFrame)k;
-(void)setKeyFrame:(KeyFrame)k At:(int)i;
-(TimeType)getFrameTime:(int)f;
-(void)updateRange;

@end


enum {TIMELINE_STOPPED, TIMELINE_PLAYING, TIMELINE_PAUSED};

@interface Timeline : NSObject 
{
@public
	BaseElement* element;
	int state;
	id<TimelineDelegate> delegate;
	TimeType time;
	TimeType length;
	bool timelineDirReverse;
	
	int maxKeyFrames;
	int timelineLoopType;
	Track* tracks[TRACKS_COUNT];
}

@property (assign) id<TimelineDelegate> delegate;

-(id)initWithMaxKeyFramesOnTrack:(int)m;
-(void)setTimelineLoopType:(int)l;
-(void)playTimeline;
-(void)pauseTimeline;
-(void)stopTimeline;
-(Track*)getTrack:(int)t;
-(void)jumpToTrack:(int)t KeyFrame:(int)k;

-(void)addKeyFrame:(KeyFrame)k;
-(void)setKeyFrame:(KeyFrame)k At:(int)i;

@end

void updateActionTrack(Track* thiss, TimeType delta);
void updateTrack(Track* thiss, TimeType delta);
void updateTimeline(Timeline* thiss, TimeType delta);