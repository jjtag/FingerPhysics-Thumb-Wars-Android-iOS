//
//  GLText.h
//  rogatka
//
//  Created by Efim Voinov on 31.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Font.h"
#import "ImageMultiDrawer.h"

@interface FormattedString : NSObject
{
@public
	NSString* string;
	float width;
}
-(id)initWithString:(NSString*)str AndWidth:(float)w;
@end

// multi-line text drawer
@interface Text : BaseElement 
{
	int align;
	NSString* string;
	
@protected
	Font* font;
	float wrapWidth;
	
	DynamicArray* formattedStrings;
	ImageMultiDrawer* d;
	
@public
	float maxHeight;
	bool wrapLongWords;
}

+(id)createWithFont:(Font*)i andString:(NSString*)str;
-(id)initWithFont:(Font*)i;
-(void)setString:(NSString*)newString andWidth:(float)w;
-(void)setString:(NSString*)newString;
-(NSString*)getString;
-(void)setAlignment:(int)a;
-(void)draw;

-(void)updateDrawerValues;
-(void)formatText;

@end
