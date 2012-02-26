//
//  Device.m
//  template
//
//  Created by Mac on 16.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Device.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>
#import <sys/sysctl.h>
#import "Debug.h"

@implementation Device

+(bool)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    bool didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        LOG(@"Error. Could not recover network reachability flags\n");
        return 0;
    }
	
    bool isReachable = flags & kSCNetworkFlagsReachable;
    bool needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

+(NSString *)platform
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	free(machine);
	return platform;
}

@end
