//
//  View.h
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"
#import <UIKit/UIKit.h>

// base view class
@interface View : BaseElement
{
}
+(View*)create;

-(id)initFullscreen;

@end
