//
//  Preferences.h
//  rogatka
//
//  Created by Efim Voinov on 01.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FrameworkTypes.h"

// Application - specific persistant preferences
@interface Preferences : NSObject 
{
	NSUserDefaults* prefs;
}

-(void)setInt:(int)v forKey:(NSString*)k;
-(void)setFloat:(float)v forKey:(NSString*)k;
-(void)setBoolean:(bool)v forKey:(NSString*)k;
-(void)setString:(NSString*)v forKey:(NSString*)k;
-(void)setObject:(id)v forKey:(NSString*)k;

-(int)getIntForKey:(NSString*)k;
-(float)getFloatForKey:(NSString*)k;
-(bool)getBooleanForKey:(NSString*)k;
-(NSString*)getStringForKey:(NSString*)k;
-(id)getObjectForKey:(NSString*)k;

-(void)savePreferences;

@end
