//
//  GLVBox.h
//  template
//
//  Created by Mac on 04.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"

// container used to automatically arrange it's childs vertically.
// currently doesn't support dynamic re-arrange of it's elements.
@interface VBox : BaseElement
{
	float offset;
	int align;
	
	float nextElementY;
}

-(id)initWithOffset:(float)of Align:(int)a Width:(float)w;

@end
