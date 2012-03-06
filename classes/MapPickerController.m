//
//  MapPickerController.m
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#ifdef MAP_PICKER

#import "MapPickerController.h"
#import "MenuView.h"
#import "ChampionsResourceMgr.h"

#define kLoadButtonY 250.0
#define kStdButtonWidth 200.0
#define kStdButtonHeight 50.0

#define kPickerElementHeight 40.0

@implementation MapPickerController

@synthesize selectedMap;

-(id)initWithParent:(ViewController*)p;
{
	if (self = [super initWithParent:p]) 
	{					
		listLoader = [[XMLSaxLoader alloc] init];		
		[listLoader turnOnCache];
		selectedMap = nil;
		maplist = nil;
		[self createPickerView];		
		// this is a simple controller and we can allow ourselves not to use model
		listLoader.delegate = self;
		
		View* loadingView = [[[View alloc] initFullscreen] autorelease];		
		Texture2D* img = [ChampionsResourceMgr getResource:IMG_LOADING_SCREEN_01];
		Image* glimg = [[[Image alloc] initWithTexture:img] autorelease];
		[loadingView addChild:glimg];
		[self addView:loadingView withID:VIEW_MAPLIST_LOADING];
	}
	return self;
}

- (void)createPickerView
{
	// create view and point it's control delegate methods to self
	MenuView* pickerView = [[MenuView alloc] initFullscreen];			

	picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
	CGSize pickerSize = [picker sizeThatFits:CGSizeMake(0.0, 0.0)];
	picker.frame = CGRectMake(0.0, 150.0, pickerSize.width, pickerSize.height);
	
	picker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	picker.showsSelectionIndicator = YES;	// note this is default to NO
	picker.delegate = self;
	
	//[pickerView addSubview:picker];
	
	// gl ui test
	
	// create background image
	Texture2D* img = [ChampionsResourceMgr getResource:IMG_LOADING_SCREEN_01];
	Image* glimg = [[[Image alloc] initWithTexture:img] autorelease];	
	
	/*// create animation
	AnimationStrip* bee = [[[AnimationStrip alloc] initWithTexture:[ChampionsResourceMgr getResource:BLOCKIT_RESOURCE_IMG_TEST_ANIM]
															 andFrames:4] autorelease];
	bee.anchor = CENTER;
	FramedAnimationDescription* anim = [[[FramedAnimationDescription alloc] initWithDelay:0.02 Looped:TRUE Count:4 Sequence:0,1,2,3] autorelease];
	[bee addAnimation:anim withID:ANIMATION_BEE];
	bee.x = 50;
	bee.y = 350;
	*/
	
	// create button
	Texture2D* img2 = [ChampionsResourceMgr getResource:IMG_MENU_LOAD_BUTTON];
	Texture2D* img3 = [ChampionsResourceMgr getResource:IMG_MENU_LOAD_LEVEL];

	Image* gi1 = [[[Image alloc] initWithTexture:img3] autorelease];
    Image* gi2 = [[[Image alloc] initWithTexture:img3] autorelease];
	Image* gi1b = [[[Image alloc] initWithTexture:img2] autorelease];
    Image* gi2b = [[[Image alloc] initWithTexture:img2] autorelease];
	gi1b->anchor = CENTER;
	gi1b->parentAnchor = CENTER;
	gi2b->anchor = CENTER;
	gi2b->parentAnchor = CENTER;
	
	[gi1 addChild:gi1b withID:0];
	[gi2 addChild:gi2b withID:0];
	
	gi2b->scaleX = 1.1;
	gi2b->scaleY = 1.1;
	Button* b = [[[Button alloc] initWithUpElement:gi1 DownElement:gi2 andID:0] autorelease];	
	b->x = SCREEN_WIDTH / 2;
	b->y = 420;
	b->anchor = CENTER;
	b.delegate = self;
	
	[pickerView addChild:glimg withID:BACKGROUND];
	[pickerView addChild:b withID:BUTTON_LOAD];
	
	[self addView:pickerView withID:VIEW_MAIN];	
	
	[pickerView release];
}

-(void)activate
{
	[super activate];	
	
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
//	NSString* searchScriptLink = [userDefaults stringForKey:@"searchScriptLink"];
#ifdef AMAZON
	NSString* searchScriptLink = @"http://fpchampions.s3.amazonaws.com/levels/maplist.xml";	
#else
//	NSString* searchScriptLink = @"http://model.reaxion.com/incoming_php/search.php?name=fpc";	
	NSString* searchScriptLink = @"http://reaxion.com/mapeditor/search.php?name=../fpchampions";
#endif
	
	[listLoader load:searchScriptLink];
	

	[self showView:VIEW_MAPLIST_LOADING];	
}

-(void)deactivate
{
	[picker removeFromSuperview];
	[super deactivate];
}

// gl button
-(void)onButtonPressed:(int)n
{
	// kill controller and return control to parent (GameController)
	[self deactivate];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	// starting tag => init maps array
	if ([elementName isEqualToString:@"maplist"])
	{
		[maplist release];
		maplist = [[DynamicArray alloc] init];
	}
	else if ([elementName isEqualToString:@"mapfile"])
	{
		// push map name to array
		NSString* str = [attributeDict objectForKey:@"name"];
		[maplist addObject:str];
		
		// save initial map name
		if ([maplist count] == 1 && selectedMap == nil)
		{
			selectedMap = [[maplist objectAtIndex:0] retain];			
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{	
	// ending tag => activate view
	if ([elementName isEqualToString:@"maplist"])
	{
		[self showView:VIEW_MAIN];
		[[Application sharedCanvas] addSubview:picker];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	ASSERT(FALSE);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[selectedMap release];
	selectedMap = [[maplist objectAtIndex:row] retain];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [maplist objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return pickerView.frame.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return kPickerElementHeight;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [maplist count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
 
- (void)dealloc
{
	[listLoader release];
	[selectedMap release];
	[maplist release];
	[picker release];
	[super dealloc];
}

@end

#endif // MAP_PICKER