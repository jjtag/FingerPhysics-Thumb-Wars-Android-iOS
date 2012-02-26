//
//  Timeline.m
//  template
//
//  Created by Mac on 23.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Timeline.h"
#import "Framework.h"

@interface Track (Private)
-(void)initKeyFrameStepFrom:(KeyFrame*)src To:(KeyFrame*)dst withTime:(TimeType)time;
-(void)timelineKeyFrameFinished;
-(void)setElementFromKeyFrame:(KeyFrame*)kf;
-(void)setKeyFrameFromElement:(KeyFrame*)kf;
@end

// c-functions used for speed increase 
void updateActionTrack(Track* this, TimeType delta)
{
	if (this->state == TRACK_NOT_ACTIVE)
	{		
		if (!this->t->timelineDirReverse)
		{
			if (!(this->t->time - delta > this->endTime || this->t->time < this->startTime))
			{			
				if (this->keyFramesCount > 1)
				{
					this->state = TRACK_ACTIVE;
					this->nextKeyFrame = 0;
					this->overrun = this->t->time - this->startTime;								
					this->nextKeyFrame++;	
					[this initActionKeyFrame:&this->keyFrames[this->nextKeyFrame - 1] andTime:this->keyFrames[this->nextKeyFrame].timeOffset];			
				}
				else
				{
					[this initActionKeyFrame:&this->keyFrames[0] andTime:0.0];					
				}
			}
		}
		else
		{
			if (!(this->t->time + delta < this->startTime || this->t->time > this->endTime))
			{
				if (this->keyFramesCount > 1)
				{
					this->state = TRACK_ACTIVE;
					this->nextKeyFrame = this->keyFramesCount - 1;
					this->overrun = this->endTime - this->t->time;
					this->nextKeyFrame--;	
					[this initActionKeyFrame:&this->keyFrames[this->nextKeyFrame + 1] andTime:this->keyFrames[this->nextKeyFrame + 1].timeOffset];
				}
				else
				{
					[this initActionKeyFrame:&this->keyFrames[0] andTime:0.0];					
				}
			}
		}			
		return;
	}	
	
	this->keyFrameTimeLeft -= delta;
	
	// FLOAT_PRECISION is used to fix the situation when timeline time >= timeline length but keyFrameTimeLeft is not <= 0 
	if (this->keyFrameTimeLeft <= FLOAT_PRECISION)
	{
		[this->t->delegate timeline:this->t reachedKeyFrame:&this->keyFrames[this->nextKeyFrame] withIndex:this->nextKeyFrame];
		this->overrun = -this->keyFrameTimeLeft;
		
		if (this->nextKeyFrame == this->keyFramesCount - 1)
		{
			[this setElementFromKeyFrame:&this->keyFrames[this->nextKeyFrame]];
			this->state = TRACK_NOT_ACTIVE;
		}
		else if (this->nextKeyFrame == 0)
		{
			[this setElementFromKeyFrame:&this->keyFrames[this->nextKeyFrame]];				
			this->state = TRACK_NOT_ACTIVE;
		}		
		else
		{
			if (!this->t->timelineDirReverse)
			{
				this->nextKeyFrame++;	
				[this initActionKeyFrame:&this->keyFrames[this->nextKeyFrame - 1] andTime:this->keyFrames[this->nextKeyFrame].timeOffset];				
			}
			else
			{			
				this->nextKeyFrame--;					
				[this initActionKeyFrame:&this->keyFrames[this->nextKeyFrame + 1] andTime:this->keyFrames[this->nextKeyFrame + 1].timeOffset];
			}
		}
	}
}

void updateTrack(Track* this, TimeType delta)
{
	Timeline* t = this->t;
	
	if (this->state == TRACK_NOT_ACTIVE)
	{		
		if (t->time >= this->startTime && t->time <= this->endTime)
		{
			this->state = TRACK_ACTIVE;
			
			if (!t->timelineDirReverse)
			{
				this->nextKeyFrame = 0;
				this->overrun = t->time - this->startTime;
				this->nextKeyFrame++;				
				[this initKeyFrameStepFrom:&this->keyFrames[this->nextKeyFrame - 1] To:&this->keyFrames[this->nextKeyFrame] withTime:this->keyFrames[this->nextKeyFrame].timeOffset];
			}
			else
			{
				this->nextKeyFrame = this->keyFramesCount - 1;
				this->overrun = this->endTime -t->time;
				this->nextKeyFrame--;		
				[this initKeyFrameStepFrom:&this->keyFrames[this->nextKeyFrame + 1] To:&this->keyFrames[this->nextKeyFrame] withTime:this->keyFrames[this->nextKeyFrame + 1].timeOffset];			
			}			
			
		}
		return;
	}	
	
	this->keyFrameTimeLeft -= delta;
	
	if (this->keyFrames[this->nextKeyFrame].transitionType == FRAME_TRANSITION_EASE_IN || 
		this->keyFrames[this->nextKeyFrame].transitionType == FRAME_TRANSITION_EASE_OUT)
	{
		KeyFrame oldPos = this->currentStepPerSecond;
		switch (this->type)
		{
			case TRACK_POSITION:	
			{
				float xDelta = this->currentStepAcceleration.value.pos.x * delta;
				float yDelta = this->currentStepAcceleration.value.pos.y * delta;
				this->currentStepPerSecond.value.pos.x += xDelta;	
				this->currentStepPerSecond.value.pos.y += yDelta;
				t->element->x += (oldPos.value.pos.x + xDelta / 2.0) * delta;	
				t->element->y += (oldPos.value.pos.y + yDelta / 2.0) * delta;							
				break;
			}
				
			case TRACK_SCALE:				
			{
				float xDelta = this->currentStepAcceleration.value.scale.scaleX * delta;
				float yDelta = this->currentStepAcceleration.value.scale.scaleY * delta;
				this->currentStepPerSecond.value.scale.scaleX += xDelta;	
				this->currentStepPerSecond.value.scale.scaleY += yDelta;
				t->element->scaleX += (oldPos.value.scale.scaleX + xDelta / 2.0) * delta;	
				t->element->scaleY += (oldPos.value.scale.scaleY + yDelta / 2.0) * delta;
				break;
			}
				
			case TRACK_ROTATION:
			{
				float delta = this->currentStepAcceleration.value.rotation.angle * delta;
				this->currentStepPerSecond.value.rotation.angle += delta;	
				t->element->rotation += (oldPos.value.rotation.angle + delta / 2.0) * delta;					
				break;
			}
				
			case TRACK_COLOR:
			{
				this->currentStepPerSecond.value.color.rgba.r += this->currentStepAcceleration.value.color.rgba.r * delta;	
				this->currentStepPerSecond.value.color.rgba.g += this->currentStepAcceleration.value.color.rgba.g * delta;	
				this->currentStepPerSecond.value.color.rgba.b += this->currentStepAcceleration.value.color.rgba.b * delta;	
				this->currentStepPerSecond.value.color.rgba.a += this->currentStepAcceleration.value.color.rgba.a * delta;
				
				float deltaR = this->currentStepAcceleration.value.color.rgba.r * delta;
				float deltaG = this->currentStepAcceleration.value.color.rgba.g * delta;
				float deltaB = this->currentStepAcceleration.value.color.rgba.b * delta;
				float deltaA = this->currentStepAcceleration.value.color.rgba.a * delta;

				this->currentStepPerSecond.value.color.rgba.r += deltaR;	
				this->currentStepPerSecond.value.color.rgba.g += deltaG;
				this->currentStepPerSecond.value.color.rgba.b += deltaB;
				this->currentStepPerSecond.value.color.rgba.a += deltaA;
				
				t->element->color.r += (oldPos.value.color.rgba.r + deltaR / 2.0) * delta;				
				t->element->color.g += (oldPos.value.color.rgba.g + deltaG / 2.0) * delta;
				t->element->color.b += (oldPos.value.color.rgba.b + deltaB / 2.0) * delta;
				t->element->color.a += (oldPos.value.color.rgba.a + deltaA / 2.0) * delta;				
				break;
			}
		}		
	}
	else if (this->keyFrames[this->nextKeyFrame].transitionType == FRAME_TRANSITION_LINEAR)
	{
		switch (this->type)
		{
			case TRACK_POSITION:
				t->element->x += this->currentStepPerSecond.value.pos.x * delta;	
				t->element->y += this->currentStepPerSecond.value.pos.y * delta;			
				break;
				
			case TRACK_SCALE:
				t->element->scaleX += this->currentStepPerSecond.value.scale.scaleX * delta;	
				t->element->scaleY += this->currentStepPerSecond.value.scale.scaleY * delta;	
				break;
				
			case TRACK_ROTATION:
				t->element->rotation += this->currentStepPerSecond.value.rotation.angle * delta;	
				break;
				
			case TRACK_COLOR:
				t->element->color.r += this->currentStepPerSecond.value.color.rgba.r * delta;	
				t->element->color.g += this->currentStepPerSecond.value.color.rgba.g * delta;	
				t->element->color.b += this->currentStepPerSecond.value.color.rgba.b * delta;	
				t->element->color.a += this->currentStepPerSecond.value.color.rgba.a * delta;				
				break;
		}
	}
	
	if (this->keyFrameTimeLeft <= FLOAT_PRECISION)
	{
		[t->delegate timeline:t reachedKeyFrame:&this->keyFrames[this->nextKeyFrame] withIndex:this->nextKeyFrame];
		this->overrun = -this->keyFrameTimeLeft;
		
		if (this->nextKeyFrame == this->keyFramesCount - 1)
		{
			[this setElementFromKeyFrame:&this->keyFrames[this->nextKeyFrame]];
			this->state = TRACK_NOT_ACTIVE;
		}
		else if (this->nextKeyFrame == 0)
		{
			[this setElementFromKeyFrame:&this->keyFrames[this->nextKeyFrame]];				
			this->state = TRACK_NOT_ACTIVE;
		}		
		else
		{
			if (!t->timelineDirReverse)
			{
				this->nextKeyFrame++;	
				[this initKeyFrameStepFrom:&this->keyFrames[this->nextKeyFrame - 1] To:&this->keyFrames[this->nextKeyFrame] withTime:this->keyFrames[this->nextKeyFrame].timeOffset];
			}
			else
			{			
				this->nextKeyFrame--;	
				[this initKeyFrameStepFrom:&this->keyFrames[this->nextKeyFrame + 1] To:&this->keyFrames[this->nextKeyFrame] withTime:this->keyFrames[this->nextKeyFrame + 1].timeOffset];				
			}
		}
	}
}

void updateTimeline(Timeline* this, TimeType delta)
{
	if (this->state != TIMELINE_PLAYING)
	{
		return;
	}
		
	if (!this->timelineDirReverse)
	{
		this->time += delta;
	}
	else
	{
		this->time -= delta;
	}
	
	for (int i = 0; i < TRACKS_COUNT; i++)
	{
		if (this->tracks[i] != nil)
		{
			if (this->tracks[i]->type == TRACK_ACTION)
			{
				updateActionTrack(this->tracks[i], delta);				
			}
			else
			{
				updateTrack(this->tracks[i], delta);
			}
		}
	}	
	
	switch (this->timelineLoopType)	
	{					
		case TIMELINE_PING_PONG:
		{
			bool reachedEnd = (this->timelineDirReverse == FALSE) && this->time >= this->length - FLOAT_PRECISION;
			bool reachedStart = this->timelineDirReverse && this->time <= FLOAT_PRECISION;
			if (reachedEnd)
			{
				this->time = MAX(0, this->length - (this->time - this->length));
				this->timelineDirReverse = TRUE;
			}	
			else if (reachedStart)
			{
				this->time = MIN(-this->time, this->length);
				this->timelineDirReverse = FALSE;
			}		
		}
		break;
			
		case TIMELINE_REPLAY:
			if (this->time >= this->length - FLOAT_PRECISION)
			{
				this->time = MIN(this->time - this->length, this->length);				
			}
			break;
			
		case TIMELINE_NO_LOOP:
			if (this->time >= this->length - FLOAT_PRECISION)
			{
				[this stopTimeline];
				[this->delegate timelineFinished:this];				
			}
			break;
	}			
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Action* createAction(BaseElement* target, NSString* action, int p, int sp)
{
	Action* a = [[Action alloc] init];
	a->actionTarget = target;
	a->data.actionName = [action retain];
	a->data.actionParam = p;
	a->data.actionSubParam = sp;
	
	return [a autorelease];
}

@interface Timeline (Private)
-(void)deactivateTracks;
@end

@implementation Action

-(void)dealloc
{
	[data.actionName release];
	[super dealloc];
}

@end

@implementation Track

-(id)initWithTimeline:(Timeline*)timeline Type:(int)trackType andMaxKeyFrames:(int)m
{
	if (self = [super init])
	{
		ASSERT(!keyFrames);
		ASSERT(m > 0);
		ASSERT(timeline);
		
		t = timeline;
		type = trackType;
		state = TRACK_NOT_ACTIVE;
		relative = FALSE;
		nextKeyFrame = UNDEFINED;
		keyFramesCount = 0;
		
		keyFramesCapacity = m;
		keyFrames = malloc(sizeof(KeyFrame) * keyFramesCapacity);
		
		if (type == TRACK_ACTION)
		{
			actionSets = [[DynamicArray alloc] init];
		}
	}
	
	return self;
}

-(void)dealloc
{
	free(keyFrames);
	if (type == TRACK_ACTION)
	{
		[actionSets release];
	}
	[super dealloc];
}

-(void)addKeyFrame:(KeyFrame)k
{
	[self setKeyFrame:k At:keyFramesCount];
}

-(void)setKeyFrame:(KeyFrame)k At:(int)i
{
	ASSERT(i >= 0 && i < keyFramesCapacity);
	ASSERT(k.timeOffset >= 0);
	
	keyFrames[i] = k;
	
	if (i >= keyFramesCount)
	{
		keyFramesCount = i + 1;
	}
	
	if (type == TRACK_ACTION)
	{
		ASSERT(actionSets);
		[actionSets addObject:k.value.action.actionSet];
	}
}

-(TimeType)getFrameTime:(int)f
{
	ASSERT(f >= 0 && f < keyFramesCount);
	TimeType res = 0.0;
	for (int i = 0; i <= f; i++)
	{
		res += keyFrames[i].timeOffset;
	}
	
	return res;
}

-(void)updateRange
{
	startTime = [self getFrameTime:0];
	endTime = [self getFrameTime:(keyFramesCount - 1)];	
}

-(void)setElementFromKeyFrame:(KeyFrame*)kf
{
	switch (type)
	{
		case TRACK_POSITION:	
			if (!relative)
			{
				t->element->x = kf->value.pos.x;
				t->element->y = kf->value.pos.y;
			}
			else
			{
				t->element->x = elementPrevState.value.pos.x + kf->value.pos.x;
				t->element->y = elementPrevState.value.pos.y + kf->value.pos.y;				
			}
			break;
			
		case TRACK_SCALE:
			if (!relative)
			{
				t->element->scaleX = kf->value.scale.scaleX;
				t->element->scaleY = kf->value.scale.scaleY;
			}
			else
			{
				t->element->scaleX = elementPrevState.value.scale.scaleX + kf->value.scale.scaleX;
				t->element->scaleY = elementPrevState.value.scale.scaleY + kf->value.scale.scaleY;				
			}
			break;
			
		case TRACK_ROTATION:
			if (!relative)
			{
				t->element->rotation = kf->value.rotation.angle;
			}
			else
			{
				t->element->rotation = elementPrevState.value.rotation.angle + kf->value.rotation.angle;				
			}
			break;
			
		case TRACK_COLOR:
			if (!relative)
			{
				t->element->color = kf->value.color.rgba;
			}
			else
			{
				t->element->color.r = elementPrevState.value.color.rgba.r + kf->value.color.rgba.r;				
				t->element->color.g = elementPrevState.value.color.rgba.g + kf->value.color.rgba.g;				
				t->element->color.b = elementPrevState.value.color.rgba.b + kf->value.color.rgba.b;				
				t->element->color.a = elementPrevState.value.color.rgba.a + kf->value.color.rgba.a;				

			}
			break;
			
		case TRACK_ACTION:
			for (int i = 0; i < [kf->value.action.actionSet count]; i++)
			{
				Action* a = [kf->value.action.actionSet objectAtIndex:i];
				[a->actionTarget handleAction:a->data];
			}
			break;
	}
	
}

-(void)setKeyFrameFromElement:(KeyFrame*)kf
{
	switch (type)
	{
		case TRACK_POSITION:	
			kf->value.pos.x = t->element->x;
			kf->value.pos.y = t->element->y;
			break;
			
		case TRACK_SCALE:
			kf->value.scale.scaleX = t->element->scaleX;
			kf->value.scale.scaleY = t->element->scaleY;
			break;
			
		case TRACK_ROTATION:
			kf->value.rotation.angle = t->element->rotation;
			break;
			
		case TRACK_COLOR:			
			kf->value.color.rgba = t->element->color;
			break;
			
		case TRACK_ACTION:
			break;
	}	
}

-(void)initKeyFrameStepFrom:(KeyFrame*)src To:(KeyFrame*)dst withTime:(TimeType)time
{
	keyFrameTimeLeft = time;

	//if (!relative)
	//{
		[self setKeyFrameFromElement:&elementPrevState];	
	//}
	
	[self setElementFromKeyFrame:src];

	switch (type)
	{
		case TRACK_POSITION:	
			currentStepPerSecond.value.pos.x = (dst->value.pos.x - src->value.pos.x) / keyFrameTimeLeft;
			currentStepPerSecond.value.pos.y = (dst->value.pos.y - src->value.pos.y) / keyFrameTimeLeft;	
			break;
			
		case TRACK_SCALE:
			currentStepPerSecond.value.scale.scaleX = (dst->value.scale.scaleX - src->value.scale.scaleX) / keyFrameTimeLeft;
			currentStepPerSecond.value.scale.scaleY = (dst->value.scale.scaleY - src->value.scale.scaleY) / keyFrameTimeLeft;
			break;
			
		case TRACK_ROTATION:
			currentStepPerSecond.value.rotation.angle = (dst->value.rotation.angle - src->value.rotation.angle) / keyFrameTimeLeft;
			break;
			
		case TRACK_COLOR:			
			currentStepPerSecond.value.color.rgba.r = (dst->value.color.rgba.r - src->value.color.rgba.r) / keyFrameTimeLeft;
			currentStepPerSecond.value.color.rgba.g = (dst->value.color.rgba.g - src->value.color.rgba.g) / keyFrameTimeLeft;
			currentStepPerSecond.value.color.rgba.b = (dst->value.color.rgba.b - src->value.color.rgba.b) / keyFrameTimeLeft;
			currentStepPerSecond.value.color.rgba.a = (dst->value.color.rgba.a - src->value.color.rgba.a) / keyFrameTimeLeft;
			break;
			
		case TRACK_ACTION:
			break;
	}
	
	if (dst->transitionType == FRAME_TRANSITION_EASE_IN || 
		dst->transitionType == FRAME_TRANSITION_EASE_OUT)
	{
		switch (type)
		{
			case TRACK_POSITION:	
				currentStepPerSecond.value.pos.x *= 2.0;
				currentStepPerSecond.value.pos.y *= 2.0;				
				currentStepAcceleration.value.pos.x = currentStepPerSecond.value.pos.x / keyFrameTimeLeft;
				currentStepAcceleration.value.pos.y = currentStepPerSecond.value.pos.y / keyFrameTimeLeft;
				if (dst->transitionType == FRAME_TRANSITION_EASE_IN)
				{
					currentStepPerSecond.value.pos.x = 0.0;
					currentStepPerSecond.value.pos.y = 0.0;
				}
				else
				{
					currentStepAcceleration.value.pos.x *= -1;					
					currentStepAcceleration.value.pos.y *= -1;					
				}
				break;
				
			case TRACK_SCALE:
				currentStepPerSecond.value.scale.scaleX *= 2;
				currentStepPerSecond.value.scale.scaleY *= 2;	
				currentStepAcceleration.value.scale.scaleX = currentStepPerSecond.value.scale.scaleX / keyFrameTimeLeft;
				currentStepAcceleration.value.scale.scaleY = currentStepPerSecond.value.scale.scaleY / keyFrameTimeLeft;
				if (dst->transitionType == FRAME_TRANSITION_EASE_IN)
				{
					currentStepPerSecond.value.scale.scaleX = 0.0;
					currentStepPerSecond.value.scale.scaleY = 0.0;
				}
				else
				{
					currentStepAcceleration.value.scale.scaleX *= -1;					
					currentStepAcceleration.value.scale.scaleY *= -1;					
				}				
				break;
				
			case TRACK_ROTATION:
				currentStepPerSecond.value.rotation.angle *= 2;
				currentStepAcceleration.value.rotation.angle = currentStepPerSecond.value.rotation.angle / keyFrameTimeLeft;
				if (dst->transitionType == FRAME_TRANSITION_EASE_IN)
				{
					currentStepPerSecond.value.rotation.angle = 0.0;
				}
				else
				{
					currentStepAcceleration.value.rotation.angle *= -1;					
				}					
				break;
				
			case TRACK_COLOR:			
				currentStepPerSecond.value.color.rgba.r *= 2;
				currentStepPerSecond.value.color.rgba.g *= 2;
				currentStepPerSecond.value.color.rgba.b *= 2;
				currentStepPerSecond.value.color.rgba.a *= 2;
				currentStepAcceleration.value.color.rgba.r = currentStepPerSecond.value.color.rgba.r / keyFrameTimeLeft;
				currentStepAcceleration.value.color.rgba.g = currentStepPerSecond.value.color.rgba.g / keyFrameTimeLeft;
				currentStepAcceleration.value.color.rgba.b = currentStepPerSecond.value.color.rgba.b / keyFrameTimeLeft;
				currentStepAcceleration.value.color.rgba.a = currentStepPerSecond.value.color.rgba.a / keyFrameTimeLeft;

				if (dst->transitionType == FRAME_TRANSITION_EASE_IN)
				{
					currentStepPerSecond.value.color.rgba.r = 0.0;
					currentStepPerSecond.value.color.rgba.g = 0.0;
					currentStepPerSecond.value.color.rgba.b = 0.0;
					currentStepPerSecond.value.color.rgba.a = 0.0;
				}
				else
				{
					currentStepAcceleration.value.color.rgba.r *= -1;					
					currentStepAcceleration.value.color.rgba.g *= -1;					
					currentStepAcceleration.value.color.rgba.b *= -1;					
					currentStepAcceleration.value.color.rgba.a *= -1;										
				}
				
				break;
				
			case TRACK_ACTION:
				break;
		}		
	}
	
	if (overrun > 0)
	{
		updateTrack(self, overrun);
		overrun = 0;
	}
}

-(void)initActionKeyFrame:(KeyFrame*)kf andTime:(TimeType)time
{
	keyFrameTimeLeft = time;

	[self setElementFromKeyFrame:kf];
		
	if (overrun > 0)
	{
		updateActionTrack(self, overrun);
		overrun = 0;
	}
}

@end

@implementation Timeline

@synthesize delegate;

// state that we'll use timeline
-(id)initWithMaxKeyFramesOnTrack:(int)m
{
	if (self = [super init])
	{
		ASSERT(m > 0);
		maxKeyFrames = m;
		time = 0.0;
		length = 0.0;
		state = TIMELINE_STOPPED;
		timelineLoopType = TIMELINE_NO_LOOP;
	}
	
	return self;
}

-(void)dealloc
{
	for (int i = 0; i < TRACKS_COUNT; i++)
	{
		[tracks[i] release];
	}
	[super dealloc];
}

-(void)setTimelineLoopType:(int)l
{
	ASSERT(timelineLoopType == TIMELINE_NO_LOOP || timelineLoopType == TIMELINE_PING_PONG || timelineLoopType == TIMELINE_REPLAY);
	timelineLoopType = l;
}

-(void)addKeyFrame:(KeyFrame)k
{
	ASSERT(k.timeOffset >= 0);
	int index = (tracks[k.trackType] == nil) ? 0 : tracks[k.trackType]->keyFramesCount;
	
	[self setKeyFrame:k At:index];
}

-(void)setKeyFrame:(KeyFrame)k At:(int)i
{
	ASSERT(k.timeOffset >= 0);
	
	if (tracks[k.trackType] == nil)
	{
		tracks[k.trackType] = [[Track alloc] initWithTimeline:self Type:k.trackType andMaxKeyFrames:maxKeyFrames];
	}	
	
	[tracks[k.trackType] setKeyFrame:k At:i];
}

-(Track*)getTrack:(int)t
{
	ASSERT(t >= 0 && t < TRACKS_COUNT);
	return tracks[t];
}

// start playing the timeline from the beginning
-(void)playTimeline
{
	//ASSERT(state != TIMELINE_PLAYING);
	ASSERT(element);
	if (state != TIMELINE_PAUSED)
	{
		time = 0.0;
		timelineDirReverse = FALSE;
		length = 0.0;
		
		for (int i = 0; i < TRACKS_COUNT; i++)
		{
			if (tracks[i] != nil)
			{
				[tracks[i] updateRange];
				if (tracks[i]->endTime > length)
				{
					length = tracks[i]->endTime;
				}
			}
		}
		//[self timelineKeyFrameFinished];	
	}
	state = TIMELINE_PLAYING;	

	updateTimeline(self, 0.0);
}

-(void)pauseTimeline
{
	ASSERT(state == TIMELINE_PLAYING);
	state = TIMELINE_PAUSED;
}

-(void)jumpToTrack:(int)t KeyFrame:(int)k
{
	if (state == TIMELINE_STOPPED)
	{
		state = TIMELINE_PAUSED;
	}

	ASSERT(tracks[t]);
	time = [tracks[t] getFrameTime:k];
	//	[self timelineKeyFrameFinished];
}

-(void)stopTimeline
{
	state = TIMELINE_STOPPED;
	[self deactivateTracks];
}

-(void)deactivateTracks
{
	for (int i = 0; i < TRACKS_COUNT; i++)
	{
		if (tracks[i] != nil)
		{
			tracks[i]->state = TRACK_NOT_ACTIVE;
		}
	}
}

@end
