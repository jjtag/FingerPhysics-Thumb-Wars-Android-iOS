//
//  ColoredText.m
//  champions
//
//  Created by Mac on 18.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ColoredText.h"
#import "Framework.h"

@implementation ColorChange
@end

@implementation ColoredText

-(id)initWithFont:(Font*)i
{
	if (self = [super initWithFont:i])
	{
		colorChanges = [[DynamicArray alloc] init];
	}
	
	return self;
}

-(void)formatText
{
	unichar s[[string length] + 1];
	[string getCharacters:(unichar*)&s];	
	int len = [string length];	
	
	int i = 0;
	while (i < len)
	{
		unichar c = s[i];
		// found color change
		if (c == '[' && s[i + 1] == '#' && s[i + 8] == ']')
		{
			NSString* rs = [string substringWithRange:NSMakeRange(i + 2,  2)];
			NSString* gs = [string substringWithRange:NSMakeRange(i + 4,  2)];
			NSString* bs = [string substringWithRange:NSMakeRange(i + 6,  2)];			
			unsigned int rv, gv, bv;  
			[[NSScanner scannerWithString:rs] scanHexInt:&rv];  
			[[NSScanner scannerWithString:gs] scanHexInt:&gv];  
			[[NSScanner scannerWithString:bs] scanHexInt:&bv]; 
			
			ColorChange* cch = [[ColorChange allocAndAutorelease] init];
			cch->color = MakeRGBA(rv / 255.0, gv / 255.0, bv / 255.0, 1.0);
			cch->charIndex = i;
			i += 9;
			[colorChanges addObject:cch];
		}	
		i++;
	}
	
	NSMutableString* tmp = [[NSMutableString allocAndAutorelease] initWithString:string];			
	
	// cut commands from text and count spaces (they are not drawn)
	int si = 0;
	int prevIndex = 0;
	int cutedSpaces = 0;
	for (ColorChange* cch in colorChanges)
	{
		cch->charIndex -= si;
		[tmp deleteCharactersInRange:NSMakeRange(cch->charIndex, 9)];
		si += 9;

		[tmp getCharacters:(unichar*)&s];		
		int ci = cch->charIndex;
		cch->charIndex -= cutedSpaces;
		for (int i = prevIndex; i < ci; i++)
		{
			if (s[i] == ' ') 
			{
				cch->charIndex--;
				cutedSpaces++;
			}
		}
		
		prevIndex = ci;
	}
	
	[tmp retain];	
	[string release];	
	string = tmp;	
	
	[super formatText];
}

-(void)draw
{
	[self preDraw];
	glTranslatef(drawX, drawY, 0);
	int ccount = [colorChanges count];
	for (int i = 0; i < ccount; i++)
	{				
		ColorChange* cch1 = [colorChanges objectAtIndex:i];
		ColorChange* cch2 = (i == ccount - 1) ? nil : [colorChanges objectAtIndex:i + 1];
	
		if (i == 0 && cch1->charIndex > 0)
		{
			glColor4f(color.r, color.g, color.b, color.a);			
			[d drawNumberOfQuads:cch1->charIndex StartingFrom:0];
		}
		
		glColor4f(cch1->color.r, cch1->color.g, cch1->color.b, cch1->color.a);
		int num = (i == ccount - 1) ? ([string length] - cch1->charIndex) : (cch2->charIndex - cch1->charIndex);
		[d drawNumberOfQuads:num StartingFrom:cch1->charIndex];
	}

	if (ccount == 0)
	{
		[d drawNumberOfQuads:[string length] StartingFrom:0];		
	}
	
	glTranslatef(-drawX, -drawY, 0);
	glColor4f(color.r, color.g, color.b, color.a);	
	[self postDraw];
}

-(void)dealloc
{
	[colorChanges release];
	[super dealloc];
}

@end
