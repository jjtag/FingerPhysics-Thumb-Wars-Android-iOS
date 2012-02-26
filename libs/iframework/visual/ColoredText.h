//
//  ColoredText.h
//  champions
//
//  Created by Mac on 18.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Text.h"

@interface ColorChange : NSObject
{
@public
	int charIndex;
	RGBAColor color;
}

@end

// Text element capable of drawing colored symbols
// Example: "[#000000]Hey, [#FF0000]username[#000000], how [#00FF00]a[#0000FF]r[#FFFF00]e[#000000] you?"
@interface ColoredText : Text
{
	DynamicArray* colorChanges;
}

-(void)formatText;

@end
