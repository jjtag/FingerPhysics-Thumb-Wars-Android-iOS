//
//  Device.h
//  template
//
//  Created by Mac on 16.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IPHONE_1G_NAMESTRING @"iPhone1,1"
#define IPHONE_3G_NAMESTRING @"iPhone1,2"
#define IPOD_1G_NAMESTRING @"iPod1,1"
#define IPOD_2G_NAMESTRING @"iPod2,1" 

@interface Device : NSObject
{
}

// check if network is available
+(bool)connectedToNetwork;
// get device type
+(NSString*)platform;

@end
