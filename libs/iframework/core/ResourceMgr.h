//
//  ResourceMgr.h
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamicArray.h"
#import "Timer.h"

@class XMLNode;
@class Texture2D;
@class ElementFactory;

@protocol ResourceMgrDelegate
-(void)resourceLoaded:(int)res;
-(void)allResourcesLoaded;
@end

///////////////////////////////////////////////////////////////////

// resource types
enum 
{
	IMAGE, 
	FONT,
	SOUND,		
	BINARY,
	STRINGS,
	ELEMENT,	
};

/////////////////////////////////////////////////////////////////////

typedef struct ResEntry
{
	NSString* path;
	int type;
	NSString* data;
} ResEntry;

///////////////////////////////////////////////////////////////////////

// singleton timer-based resource manager
@interface ResourceMgr : Timer 
{
	id<ResourceMgrDelegate> resourcesDelegate;

@protected	
	DynamicArray* resources;
	DynamicArray* loadQueue;
	int loadCount;
	int loaded;
	
	ResEntry* resList;
	
	ElementFactory* ef;
}

@property(assign) id<ResourceMgrDelegate> resourcesDelegate;

// you must set pointer to resource description list
-(void)setResList:(ResEntry*)rl;

// resource load queue handling
-(void)initLoading;
-(void)addResourceToLoadQueue:(int)resID;
// load asynchronously
-(void)startLoading;
// load synchronously
-(void)loadImmediately;
// TRUE if we are loading resources
-(bool)isBusy;

-(int)getPercentLoaded;

-(bool)hasResource:(int)resID;
-(id)getResource:(int)resID;
-(NSString*)getString:(int)strID;
-(void)freeResource:(int)resID;

// packs handling
-(void)loadPack:(int*)p;
-(void)freePack:(int*)p;

// resource loading
-(id)loadResource:(int)r;
-(id)loadTextureImage:(NSString*)path Info:(XMLNode*)i;
-(id)loadPVRTCTextureImage:(NSString*)path Info:(XMLNode*)i;
-(id)loadSound:(NSString*)path Info:(XMLNode*)i;
-(id)loadVariableFont:(NSString*)path Info:(XMLNode*)i;
-(id)loadBinary:(NSString*)path Info:(XMLNode*)i;
-(id)loadStrings:(NSString*)path Info:(XMLNode*)i;
-(id)loadElement:(NSString*)path Info:(XMLNode*)i;

-(int)getResourceIDFromPath:(NSString*)p;
+(NSString*) fullPathFromRelativePath:(NSString*) relPath;

-(void)setQuads:(Texture2D*)t Info:(XMLNode*)i;

@end
