//
//  FPCircleShape.h
//  champions
//
//  Created by ikoryakin on 3/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPShape.h"

@interface FPCircleShape : FPShape <NSCopying> {
	float radius;
}

@property (assign) float radius;

@end
