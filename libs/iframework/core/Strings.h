//
//  Strings.h
//  template
//
//  Created by Efim Voinov on 23.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DynamicArray.h"
#import "XMLDocument.h"

// we will use this locale if there will be no string available in native device locale
#define DEFAULT_LOCALE @"en"

// here we keep strings for certain locale
@interface LocaleSet : NSObject
{
@public
	DynamicArray* stringArray;
}

@end

// pack of localesets
@interface Strings : NSObject 
{
	NSMutableDictionary* locales;
	LocaleSet* defaultLocale;
}

-(id)initWithXML:(XMLNode*)xml;
-(NSString*)getString:(int)sid;

-(void)parseXML:(XMLNode*)xml;

@end
