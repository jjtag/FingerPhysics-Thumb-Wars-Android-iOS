//
//  GLFont.m
//  blockit
//
//  Created by Efim Voinov on 19.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Font.h"
#import "Debug.h"

int getCharOffset(Font* f, unichar* s, int c, int len)
{
	if (!f->kerning || c == len - 1) return f->charOffset;
	NSString* chars = FORMAT_STRING(@"%c%c", s[c], s[c+1]);
	NSString* v = [f->kerning objectForKey:chars];
	if (v)
	{
		return [v intValue];
	}
	else
	{
		return f->charOffset;
	}	
}

@interface Font (Private)
-(void)initCharTextureCoords;
@end

@implementation Font

-(id)initWithVariableSizeChars:(NSString*)string charMapFile:(Texture2D*)charmapfile Kerning:(NSMutableDictionary*)k
{
	if (self = [super initWithTexture:charmapfile])
	{
		chars = [string copy];
		kerning = ([k count] > 0) ? [k retain] : nil;
		charOffset = 0;
		lineOffset = 0;
	}
	
	return self;		
}

-(void)setCharOffset:(float)co LineOffset:(float)lo SpaceWidth:(float)sw
{
	charOffset = co;
	lineOffset = lo;	
	spaceWidth = sw;
}

-(void)dealloc
{
	[chars release];
	[kerning release];
	[super dealloc];
}	

//TODO: slow, possibly should change to hash
-(int)getCharQuad:(unichar)c
{
	int len = [chars length];
	unichar s[len + 1];
	[chars getCharacters:(unichar*)&s];
	for (int i = 0; i < texture->quadsCount; i++)
	{
		if (s[i] == c)
		{
			return i;
		}
	}

	ASSERT_MSG(FORMAT_STRING(@"Char %@ not found in font", [NSString stringWithCharacters:&c length:1]), FALSE);
	return UNDEFINED;
}

-(void)draw
{
	ASSERT_MSG(@"Can't draw font directly", FALSE);
}

-(void)drawQuadWOBind:(int)n AtX:(float)dx Y:(float)dy
{
	ASSERT(n >= 0 && n < texture->quadsCount);
	float quadWidth = texture->quadRects[n].w;
	float quadHeight = texture->quadRects[n].h;
	
	GLfloat vertices[] = {	
		dx, dy,
		dx + quadWidth, dy,
		dx, dy + quadHeight,
	dx + quadWidth, dy + quadHeight };	

	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, &texture->quads[n]);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(float)stringWidth:(NSString*)str
{
	float strWidth = 0;
	int len = [str length];
	unichar s[len + 1];
	[str getCharacters:(unichar*)&s];

	float lastOffset = 0;
	
	for(int c = 0; c < len; c++) 
	{	
		lastOffset = getCharOffset(self, s, c, len);

		if (s[c] == ' ')
		{
			strWidth += spaceWidth + lastOffset;			
		}
		else
		{
			int quadIndex = [self getCharQuad:s[c]];		
			int itemWidth = texture->quadRects[quadIndex].w;
			strWidth += itemWidth + lastOffset;
		}
	}
	strWidth -= lastOffset;
	return strWidth;
}

-(float)fontHeight
{
	return texture->quadRects[0].h;
}

@end
