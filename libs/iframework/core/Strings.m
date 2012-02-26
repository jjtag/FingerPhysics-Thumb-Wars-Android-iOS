//
//  Strings.m
//  template
//
//  Created by Efim Voinov on 23.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Strings.h"
#import "Framework.h"

@implementation LocaleSet

-(id)init
{
	if (self = [super init])
	{
		stringArray = [[DynamicArray alloc] init];
	}
	
	return self;
}

-(void)dealloc
{
	[stringArray release];
	[super dealloc];
}

@end

@interface Strings (Private)
-(void)parseXML:(XMLNode*)xml;
@end

@implementation Strings

-(id)initWithXML:(XMLNode*)xml;
{
	if (self = [super init])
	{
		locales = [[NSMutableDictionary alloc] init];
		[self parseXML:xml];
	}
	
	return self;
}

-(void)parseXML:(XMLNode*)xml
{
	NSString* localesAttr = [xml->attributes objectForKey:@"locales"];
	ASSERT(localesAttr);
	NSArray* localesArray = [localesAttr componentsSeparatedByString:@","];
	int localesCount = [localesArray count];
	ASSERT(localesCount > 0);
	for (NSString* l in localesArray)
	{
		LocaleSet* locale = [LocaleSet create];
		[locales setObject:locale forKey:l];
		if ([l isEqualToString:DEFAULT_LOCALE] || localesCount == 1)
		{
			defaultLocale = locale;
		}
	}
	
	DynamicArray* strings = xml->childs;
	ASSERT(strings);
	int i = 0;
	for (XMLNode* str in strings)
	{
		DynamicArray* ltext = str->childs;
		ASSERT(ltext);
		for (XMLNode* text in ltext)
		{
			LocaleSet* set = [locales objectForKey:text->name];
			ASSERT(set);
			[set->stringArray setObject:text->data At:i];
		}
		i++;
	}
}

-(NSString*)getString:(int)sid
{
	if ([locales count] > 1)
	{
		NSString* currentLocale = [[Application sharedAppSettings] getString:APP_SETTING_LOCALE];
		LocaleSet* locale = [locales objectForKey:currentLocale];
		if (locale)
		{
			return [locale->stringArray objectAtIndex:sid];
		}
	}
	
	return [defaultLocale->stringArray objectAtIndex:sid];
}

-(void)dealloc
{
	[locales release];
	[super dealloc];
}

@end
