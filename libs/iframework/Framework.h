//
//  Framework.h
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//main include file

#import "core/Application.h"
#import "core/Accelerometer.h"
#import "core/ApplicationSettings.h"
#import "core/FrameworkTypes.h"
#import "core/Debug.h"
#import "core/DynamicArray.h"
#import "core/Strings.h"
#import "core/ViewController.h"
#import "core/RootController.h"
#import "core/ResourceMgr.h"
#import "core/Device.h"
#import "core/Preferences.h"
#import "helpers/Mover.h"
#import "helpers/QuadTree.h"
#import "helpers/MathHelper.h"
#import "helpers/Camera2D.h"
#import "helpers/List.h"
#import "helpers/GameObject.h"
#import "visual/ElementFactory.h"
#import "visual/GLCanvas.h"
#import "visual/GLDrawer.h"
#import "visual/Image.h"
#import "visual/Font.h"
#import "visual/Button.h"
#import "visual/Text.h"
#import "visual/ColoredText.h"
#import "visual/Animation.h"
#import "visual/AnimationsPool.h"
#import "visual/ParticlesFactory.h"
#import "visual/ScrollableContainer.h"
#import "visual/HBox.h"
#import "visual/VBox.h"
#import "visual/ToggleButton.h"
#import "visual/Scrollbar.h"
#import "visual/BulletScrollbar.h"
#import "visual/PushButton.h"
#import "media/SoundMgr.h"

#ifndef CONVERTED_CODE

@interface NSObject (Allocations)
+(id)create;
+(id)allocAndAutorelease;
@end

#endif

