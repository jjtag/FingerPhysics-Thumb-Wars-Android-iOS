//
//  main.m
//  blockit
//
//  Created by reaxion on 05.03.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = 0;
	@try
	{    
		retVal = UIApplicationMain(argc, argv, nil, @"ChampionsApp");
	}
	@catch ( NSException * exc )
	{		
	}
	
	[pool release];
    return retVal;
}
