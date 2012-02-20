//
//  FPScores.h
//  champions
//
//  Created by ikoryakin on 6/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FPScores : NSObject <NSCoding>
{
@public
	int scores;
	float bumper;
	int bonuses;
	int time;
	int medal;
}

@end
