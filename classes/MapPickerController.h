//
//  MapPickerController.h
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Framework.h"
//#define AMAZON

#ifdef MAP_PICKER

@interface MapPickerController : ViewController <UIPickerViewDelegate, ButtonDelegate>
{
	enum 
	{
		VIEW_MAIN, 
		VIEW_MAPLIST_LOADING
	} MPC_VIEWS;
	
	enum 
	{
		BACKGROUND,
		BUTTON_LOAD		
	} MPC_ELEMENTS;
	
	XMLSaxLoader* listLoader;
	
	// parsed map names array
	DynamicArray* maplist;
	
	// we store selected map name here so GameController could read this
	NSString* selectedMap;
	
	// Standard UI picker view
	UIPickerView* picker;
}

- (void)createPickerView;

@property (readonly) NSString* selectedMap;

@end

#endif // MAP_PICKER