//
//  BannerParser.h
//  champions
//
//  Created by ikoryakin on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPBanner.h"
#import "FrameworkTypes.h"

@interface BannerParser : NSXMLParser
{
	NSMutableArray* bannerList;
}

@end
