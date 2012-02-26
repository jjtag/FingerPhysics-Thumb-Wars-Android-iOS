//
//  FrameworkTypes.m
//  template
//
//  Created by Efim Voinov on 01.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FrameworkTypes.h"

const int LEFT = 1;
const int HCENTER = 2;
const int RIGHT = 4;
const int TOP = 8;
const int VCENTER = 16;
const int BOTTOM = 32;

const int CENTER = 2 | 16;

float SCREEN_WIDTH;
float SCREEN_HEIGHT;

const RGBAColor transparentRGBA = {0, 0, 0, 0};
const RGBAColor solidOpaqueRGBA = {1.0, 1.0, 1.0, 1.0};

const RGBAColor redRGBA = {1.0, 0.0, 0.0, 1.0};
const RGBAColor blueRGBA = {0.0, 0.0, 1.0, 1.0};
const RGBAColor greenRGBA = {0.0, 1.0, 0.0, 1.0};
const RGBAColor blackRGBA = {0.0, 0.0, 0.0, 1.0};
const RGBAColor whiteRGBA = {1.0, 1.0, 1.0, 1.0};

int mapStringsToInt(NSString* str, NSString** strs, int* ints, int count, int defaultInt)
{
	for (int i = 0; i < count; i++)
	{
		if ([str isEqualToString:strs[i]])
		{
			return ints[i];
		}
	}
	
	return defaultInt;
}

NSString* mapIntsToString(int value, NSString** strs, int* ints, int count, NSString* defaultString)
{
	for (int i = 0; i < count; i++)
	{
		if (value == ints[i])
		{
			return strs[i];
		}
	}
	
	return defaultString;
}