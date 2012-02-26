//
//  Preferences.m
//  rogatka
//
//  Created by Efim Voinov on 01.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

-(id)init
{
	if (self = [super init])
	{
		prefs = [NSUserDefaults standardUserDefaults];		
	}
	
	return self;
}

-(void)setInt:(int)v forKey:(NSString*)k
{
	[prefs setInteger:v forKey:k];
}

-(void)setFloat:(float)v forKey:(NSString*)k
{
	[prefs setFloat:v forKey:k];	
}

-(void)setBoolean:(bool)v forKey:(NSString*)k
{
	[prefs setBool:v forKey:k];
}

-(void)setString:(NSString*)v forKey:(NSString*)k
{
	[prefs setObject:v forKey:k];
}

-(void)setObject:(id)v forKey:(NSString*)k
{
	[prefs setObject:v forKey:k];	
}

-(int)getIntForKey:(NSString*)k
{
	return [prefs integerForKey:k];
}

-(float)getFloatForKey:(NSString*)k
{
	return [prefs floatForKey:k];
}

-(bool)getBooleanForKey:(NSString*)k
{
	return [prefs boolForKey:k];
}

-(NSString*)getStringForKey:(NSString*)k
{
	return (NSString*)[prefs objectForKey:k];	
}

-(id)getObjectForKey:(NSString*)k
{
	return [prefs objectForKey:k];
}

-(void)savePreferences
{
	[prefs synchronize];
}

@end
