//
//  GLText.m
//  rogatka
//
//  Created by Efim Voinov on 31.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Text.h"
#import "Framework.h"

#define DEFAULT_DRAWER_CAPACITY 10

@implementation FormattedString

-(id)initWithString:(NSString*)str AndWidth:(float)w
{
	if (self = [super init])
	{
		string = [str retain];
		width = w;
	}
	
	return self;
}

-(void)dealloc
{
	[string release];
	[super dealloc];
}

@end


@implementation Text

+(id)createWithFont:(Font*)i andString:(NSString*)str
{
	Text* t = [[[self class] allocAndAutorelease] initWithFont:i];
	[t setString:str];
	return t;
}

-(id)initWithFont:(Font*)i
{	
	if (self = [super init])
	{
		font = [i retain];
		formattedStrings = [[DynamicArray alloc] init];
		width = UNDEFINED;
		height = UNDEFINED;
		align = LEFT;
		d = [[ImageMultiDrawer alloc] initWithImage:i andCapacity:DEFAULT_DRAWER_CAPACITY];
		wrapLongWords = FALSE;
		maxHeight = UNDEFINED;
	}
	
	return self;
}

-(void)setString:(NSString*)newString
{
	[self setString:newString andWidth:INT_MAX];
}

-(void)setString:(NSString*)newString andWidth:(float)w
{
	[d resizeCapacity:[newString length]];
	
	[newString retain];	
	[string release];
	
	string = newString;	
	wrapWidth = w;
	
	[self formatText];	
	[self updateDrawerValues];	
}

-(void)updateDrawerValues
{
	float dx = 0;
	float dy = 0;	
	
	int itemHeight = [font fontHeight];		
	
	int n = 0;
	
	unichar dotsString[3];
	NSString* dots = @"..";
	[dots getCharacters:(unichar*)&dotsString];
	int dotsOffset = getCharOffset(font, dotsString, 0, 2);
	
	int linesToDraw = (maxHeight == UNDEFINED) ? [formattedStrings count] : 
		MIN([formattedStrings count], maxHeight / (itemHeight + font->lineOffset));
	bool drawEllipsis = (linesToDraw != [formattedStrings count]);
	
	for (int i = 0; i < linesToDraw; i++)
	{		
		FormattedString* str = [formattedStrings objectAtIndex:i];
		int len = [str->string length];
		unichar s[len + 1];
		[str->string getCharacters:(unichar*)&s];
		
		if (align != LEFT)
		{
			if (align == HCENTER)
			{
				dx = (wrapWidth - str->width) / 2;
			}
			else
			{
				ASSERT(align == RIGHT);
				dx = wrapWidth - str->width;
			}
		}
		else
		{
			dx = 0;
		}
		
		for(int c = 0; c < len; c++)
		{				
			if (s[c] == ' ')
			{
				dx += font->spaceWidth + getCharOffset(font, s, c, len);			
			}
			else
			{
				int quadIndex = [font getCharQuad:s[c]];		
				int itemWidth = font->texture->quadRects[quadIndex].w;
				[d mapTextureQuad:quadIndex AtX:round(dx) Y:round(dy) atIndex:n++];
				dx += itemWidth + getCharOffset(font, s, c, len);
			}
			
			if (drawEllipsis && i == linesToDraw - 1)
			{
				int dotIndex = [font getCharQuad:'.'];		
				int dotWidth = font->texture->quadRects[dotIndex].w;				
				if ((c == len - 1) || 
				 (c == len - 2 && dx + 3 * (dotWidth + dotsOffset) + font->spaceWidth > wrapWidth))
				{
					[d mapTextureQuad:dotIndex AtX:round(dx) Y:round(dy) atIndex:n++];
					dx += dotWidth + dotsOffset;					
					[d mapTextureQuad:dotIndex AtX:round(dx) Y:round(dy) atIndex:n++];
					dx += dotWidth + dotsOffset;					
					[d mapTextureQuad:dotIndex AtX:round(dx) Y:round(dy) atIndex:n++];					
					break;
				}
			}			
		}
		dy += itemHeight + font->lineOffset;
	}			
	
	if ([formattedStrings count] <= 1)
	{		
		height = [font fontHeight];
		width = dx;		
	}
	else 
	{
		height = ([font fontHeight] + font->lineOffset) * [formattedStrings count];			
		width = wrapWidth;	
	}
	
	if (maxHeight != UNDEFINED)
	{
		height = MIN(height, maxHeight);
	}	
}

-(NSString*)getString
{
	return string;
}

-(void)setAlignment:(int)a
{
	ASSERT(a == LEFT || a == HCENTER || a == RIGHT);
	align = a;
}

-(void)draw
{
	[self preDraw];
	glTranslatef(drawX, drawY, 0);
	[d drawNumberOfQuads:[string length]];	
	glTranslatef(-drawX, -drawY, 0);
	[self postDraw];
}

-(void)formatText
{
	const int MAX_STRING_INDEXES = 512;
	short* strIdx = malloc(sizeof(short) * MAX_STRING_INDEXES);
	unichar s[[string length] + 1];
	[string getCharacters:(unichar*)&s];

	int len = [string length];
	
	int idx = 0;
	int xc = 0;
	int wc = 0;
	int xp = 0;
	int xpe = 0;
	int wp = 0;
	int dx = 0;
	
	while(dx < len)
	{
		unichar c = s[dx++];
		
		if(c == ' ' || c == '\n')
		{
			wp += wc;
			xpe = dx - 1;
			wc = 0;
			xc = dx;
			
			if(c == ' ')
			{
				xc--;
				wc = font->spaceWidth + getCharOffset(font, s, dx - 1, len);
			}
		}
		else
		{
			int quadIndex = [font getCharQuad:c];		
			int charWidth = font->texture->quadRects[quadIndex].w;					
			wc += charWidth + getCharOffset(font, s, dx - 1, len);
		}
		
		bool tooLong = (wp + wc) > wrapWidth;
		
		if (wrapLongWords && tooLong && xpe == xp)
		{
			wp += wc;
			xpe = dx;
			wc = 0;
			xc = dx;
		}
		
		if((wp + wc) > wrapWidth && xpe != xp || c == '\n')
		{
			strIdx[idx++] = (short) xp;
			strIdx[idx++] = (short) xpe;
			while(xc < len && s[xc] == ' ')
			{
				xc++;
				wc -= font->spaceWidth;
			}
			
			xp = xc;
			xpe = xp;
			wp = 0;
		}
	}
	
	if(wc != 0)
	{
		strIdx[idx++] = (short) xp;
		strIdx[idx++] = (short) dx;
	}
	
	int strCount = idx >> 1;
	
	[formattedStrings removeAllObjects];

	for(int i = 0; i < strCount; i++)
	{
		int start = strIdx[i << 1];
		int end = strIdx[(i << 1) + 1];
		NSRange range = {start, (end - start)};
		NSString* str = [string substringWithRange:range];
		int wd = [font stringWidth:str];
		FormattedString* fs = [[[FormattedString alloc] initWithString:str AndWidth:wd] autorelease];
		[formattedStrings setObject:fs At:i];
	}
	
	free(strIdx);
}

+(BaseElement*)createFromXML:(XMLNode*)xml
{
	XML_ASSERT_ATTR(@"font", xml);
	int f = [xml intAttr:@"font"];
	Text* element = [[Text allocAndAutorelease] initWithFont:[[Application sharedResourceMgr] getResource:f]];
	
	if ([xml hasAttr:@"align"])
	{
		NSString* s = [xml stringAttr:@"align"];
		element->align = [self parseAlignmentString:s];
	}		
	
	if ([xml hasAttr:@"string"])
	{
		int s = [xml intAttr:@"string"];
		
		if ([xml hasAttr:@"width"])
		{
			[element setString:[[Application sharedResourceMgr] getString:s] andWidth:[xml floatAttr:@"width"]];			
		}
		else
		{
			[element setString:[[Application sharedResourceMgr] getString:s]];
		}		
	}	
	
	if ([xml hasAttr:@"height"])
	{
		element->maxHeight = [xml floatAttr:@"height"];
	}
	
	return element;
}

-(void)dealloc
{
	[d release];
	[string release];
	[font release];
	[formattedStrings release];
	[super dealloc];
}
@end
