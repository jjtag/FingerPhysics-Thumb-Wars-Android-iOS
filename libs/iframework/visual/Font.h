//
//  GLFont.h
//  blockit
//
//  Created by Efim Voinov on 19.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Image.h"

// used to create variable char size fonts
typedef struct FontCharInfo
{
	Rectangle quad;
} FontCharInfo;

// Bitmap font, supports fixed and variable size char quads
@interface Font : Image
{
	NSString* chars;
	
@public
	float charOffset;
	float lineOffset;	
	float spaceWidth;
	
	NSMutableDictionary* kerning;	
}
-(id)initWithVariableSizeChars:(NSString*)string charMapFile:(Texture2D*)charmapfile Kerning:(NSMutableDictionary*)k;

-(int)getCharQuad:(unichar)c;
-(void)drawQuadWOBind:(int)n AtX:(float)dx Y:(float)dy;

-(float)stringWidth:(NSString*)str;
-(float)fontHeight;

-(void)setCharOffset:(float)co LineOffset:(float)lo SpaceWidth:(float)sw;

@end
#ifdef __cplusplus
extern "C"
{
#endif	
	int getCharOffset(Font* f, unichar* s, int c, int len);
#ifdef __cplusplus
}
#endif	
