//
//  FPBanner.h
//  champions
//
//  Created by ikoryakin on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"

@interface FPBanner : NSObject <NSCoding>
{
	NSString* action;
	NSString* imagePath;	
	BOOL showed;
}
-(Texture2D*)getImage;

@property (retain) NSString *action, *imagePath;
@property (assign) BOOL showed;
@end
