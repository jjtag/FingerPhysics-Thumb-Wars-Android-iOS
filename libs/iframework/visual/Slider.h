//
//  Slider.h
//  buck
//
//  Created by Mac on 01.04.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"

@class Slider;

@protocol SliderDelegate
-(void)onSlider:(Slider*)s ValueChangedTo:(float)v;
@end

// vertical or horizontal slider
@interface Slider : BaseElement
{
@public
	BaseElement* back;
	BaseElement* fill;
	BaseElement* nub;
	
	float minValue;
	float maxValue;
	float step;
	float value;
	
	bool dragging;
	Vector draggingOffset;
	
	bool vertical;	
	id delegate;
}

-(id)initWithBack:(BaseElement*)b Fill:(BaseElement*)f Nub:(BaseElement*)n Min:(float)min Max:(float)max Step:(float)s;
-(void)setValue:(float)v;
@end
