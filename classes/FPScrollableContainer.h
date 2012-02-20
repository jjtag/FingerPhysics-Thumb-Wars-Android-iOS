//
//  FPScrollbarContainer.h
//  champions
//
//  Created by ikoryakin on 6/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Framework.h"


@interface FPScrollableContainer : ScrollableContainer
{
	Mover* mover;
}

-(void)moveToScrollPoint:(int)p;

@end
