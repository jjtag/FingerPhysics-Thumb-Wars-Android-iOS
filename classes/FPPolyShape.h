//
//  FPPolyShape.h
//  champions
//
//  Created by ikoryakin on 3/16/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "FPShape.h"
#import "Framework.h"

@interface FPPolyShape : FPShape <NSCopying> {

	DynamicArray* vertices;
	DynamicArray* outlineVerts;
}

@property (assign) DynamicArray *vertices;
@end
