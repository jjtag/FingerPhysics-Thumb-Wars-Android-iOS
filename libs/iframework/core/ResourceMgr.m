//
//  ResourceMgr.m
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "../support/Texture2D.h"
#import "Framework.h"

#define LOADING_TIMER_INTERVAL 1.0 / 20.0

@implementation ResourceMgr

@synthesize resourcesDelegate;

+(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[relPath pathComponents]];
	ASSERT(imagePathComponents);
	NSString* file = [imagePathComponents lastObject];
	ASSERT(file);	
	[imagePathComponents removeLastObject];
	NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
	
	return [[NSBundle mainBundle] pathForResource:file ofType:nil inDirectory:imageDirectory];	
}

-(id)init
{
	if (self = [super init])
	{
		resList = nil;
		resources = [[DynamicArray alloc] init];
		loadQueue = [[DynamicArray alloc] init];
		updateInterval = LOADING_TIMER_INTERVAL;
		ef = [[ElementFactory alloc] init];
	}
	
	return self;
}

-(void)setResList:(ResEntry*)rl
{
	resList = rl;
}

-(void)initLoading
{
	[loadQueue removeAllObjects];
	loaded = 0;
	loadCount = 0;
	[self stopTimer];	
}

-(void)addResourceToLoadQueue:(int)resID
{
	ASSERT_MSG([resources count] <= resID || [resources objectAtIndex:resID] == nil, @"Resource already loaded");

	NSNumber* r = [NSNumber numberWithInt:resID]; 
	[loadQueue setObject:r At:loadCount];
	loadCount++;
}

-(void)startLoading
{
	[self startTimer];
}

-(void)loadImmediately
{
	for (NSNumber* r in loadQueue)
	{
		if ([self loadResource:[r intValue]])
		{
			loaded++;
		}
		else
		{
			//TODO: handle resource load error
			ASSERT(FALSE);
		}
	}
}

-(id)loadResource:(int)r
{
	ASSERT(resList);
	id res = nil;
	
	ResEntry* re = &resList[r];
	NSString* path = re->path;
	NSString* data = re->data;
	XMLNode* root = nil;

	if (data)
	{
		NSData* ndata = [data dataUsingEncoding:NSUTF8StringEncoding];
		XMLDocument* doc = [XMLDocument create];
		[doc parseData:ndata];
		root = doc->root;
	}
		
	switch (re->type)
	{
		case IMAGE:
			ASSERT(root->attributes);
			int format = [[root->attributes objectForKey:@"format"] intValue];
			if (format == kTexture2DPixelFormat_PVRTC2 || format == kTexture2DPixelFormat_PVRTC4)
			{
				res = [self loadPVRTCTextureImage:path Info:root];				
			}
			else
			{
				res = [self loadTextureImage:path Info:root];				
			}
			break;
			
		case SOUND:
			res = [self loadSound:path Info:root];
			break;

		case FONT:
			res = [self loadVariableFont:path Info:root];
			break;			
			
		case STRINGS:
			res = [self loadStrings:path Info:root];
			break;

		case BINARY:
			res = [self loadBinary:path Info:root];
			break;
			
		case ELEMENT:
			res = [self loadElement:path Info:root];			
			break;
			
	}

	[resources setObject:res At:r];
	return res;
}

-(id)loadSound:(NSString*)path Info:(XMLNode*)i
{
	ASSERT(path != nil);
	
	NSString* fullpath = [ResourceMgr fullPathFromRelativePath:path];
	ASSERT(fullpath);
	OALSound* sound = [[OALSound alloc] initWithPath:fullpath];
	
	return [sound autorelease];	
}

-(id)loadTextureImage:(NSString*)path Info:(XMLNode*)i
{
	ASSERT(path != nil);
	ASSERT(i->attributes);
	
	bool antialias = ([[i->attributes objectForKey:@"filter"] intValue] == 1);
	int pixelFormat = [[i->attributes objectForKey:@"format"] intValue];
	
	NSString *fullpath = [ResourceMgr fullPathFromRelativePath:path];	

	if (antialias)
	{
		[Texture2D setAntiAliasTexParameters];		
	}
	else
	{
		[Texture2D setAliasTexParameters];
	}

	[Texture2D setDefaultAlphaPixelFormat:pixelFormat];	
	Texture2D* texture = [[Texture2D alloc] initWithImage:[UIImage imageWithContentsOfFile:fullpath]];
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_Default];
	
	[self setQuads:texture Info:i];	

	return [texture autorelease];	
}

-(id)loadPVRTCTextureImage:(NSString*)path Info:(XMLNode*)i
{
	ASSERT(path != nil);
	ASSERT(i->attributes);
	
	bool antialias = ([[i->attributes objectForKey:@"filter"] intValue] == 1);
	int pixelFormat = [[i->attributes objectForKey:@"format"] intValue];		
	int alpha = [[i->attributes objectForKey:@"alpha"] intValue];
	int size = [[i->attributes objectForKey:@"size"] intValue];
	
	int level = 0;	
	int bpp = (pixelFormat == kTexture2DPixelFormat_PVRTC2) ? 2 : 4;	
	
	NSString *fullpath = [ResourceMgr fullPathFromRelativePath:path];	
	NSData* nsdata = [[[NSData alloc] initWithContentsOfFile:fullpath] autorelease];

	if (antialias)
	{
		[Texture2D setAntiAliasTexParameters];		
	}
	else
	{
		[Texture2D setAliasTexParameters];
	}	

	Texture2D* texture = [[Texture2D alloc] initWithPVRTCData:[nsdata bytes] level:level bpp:bpp
											hasAlpha:(alpha == 1) length:size];
	[self setQuads:texture Info:i];
	
	return [texture autorelease];
}

-(void)setQuads:(Texture2D*)t Info:(XMLNode*)i
{
	XMLNode* quads = [i findChildWithTagName:@"quads" Recursively:FALSE];
	
	t->preCutSize = vectUndefined;
	
	if (!quads)
	{
		return;
	}
	
	ASSERT(quads->data);
	
	NSString* rdata = quads->data;	
	NSArray* qdata = [rdata componentsSeparatedByString:@","];	
	int count = [qdata count] / 4;
	
	[t setQuadsCapacity:count];
	
	for (int i = 0; i < count; i++)
	{
		int si = i * 4;
		Rectangle rect = MakeRectangle([[qdata objectAtIndex:si] intValue], [[qdata objectAtIndex:si + 1] intValue], 
									   [[qdata objectAtIndex:si + 2] intValue], [[qdata objectAtIndex:si + 3] intValue]);		
		[t setQuad:&rect At:i];
	}
	
	XMLNode* offsets = [i findChildWithTagName:@"offsets" Recursively:FALSE];	
	
	if (!offsets)
	{
		return;
	}
	
	ASSERT(offsets->data);
	
	NSString* odata = offsets->data;	
	NSArray* qodata = [odata componentsSeparatedByString:@","];	
	int ocount = [qodata count] / 2;
	
	for (int i = 0; i < ocount; i++)
	{
		int si = i * 2;
		t->quadOffsets[i].x = [[qodata objectAtIndex:si] intValue];
		t->quadOffsets[i].y = [[qodata objectAtIndex:si + 1] intValue];
	}
	
	XMLNode* preCutWidth = [i findChildWithTagName:@"preCutWidth" Recursively:FALSE];		
	XMLNode* preCutHeight = [i findChildWithTagName:@"preCutHeight" Recursively:FALSE];		

	if (preCutWidth && preCutHeight)
	{
		t->preCutSize = vect([preCutWidth->data intValue], [preCutHeight->data intValue]);
	}	
}

-(id)loadVariableFont:(NSString*)path Info:(XMLNode*)i
{
	ASSERT(path != nil);
	ASSERT(i->attributes);
	ASSERT(i->childs);
		
	int co = [[i->attributes objectForKey:@"charoff"] intValue];
	int lo = [[i->attributes objectForKey:@"lineoff"] intValue];
	int space = [[i->attributes objectForKey:@"space"] intValue]; 

	XMLNode* chars = [i findChildWithTagName:@"chars" Recursively:FALSE];
	XMLNode* kerning = [i findChildWithTagName:@"kerning" Recursively:FALSE];
	
	ASSERT(chars->data);
	
	NSString* charsString = chars->data;
	NSString* kerningString = (kerning) ? kerning->data : nil;
	
	NSMutableDictionary* kerningDictionary = nil;
	
	if (kerningString && [kerningString length] > 0)
	{
		NSArray* a = [kerningString componentsSeparatedByString:@","];
		kerningDictionary = [[NSMutableDictionary allocAndAutorelease] initWithCapacity:[a count] / 2];

		for (int i = 0; i < [a count]; i += 2)
		{
			[kerningDictionary setObject:[a objectAtIndex:i+1] forKey:[a objectAtIndex:i]];
		}
	}
	
	Font* font = [[Font alloc] initWithVariableSizeChars:charsString charMapFile:[self loadTextureImage:path Info:i] Kerning:kerningDictionary];
	[font setCharOffset:co LineOffset:lo SpaceWidth:space];
	
	return [font autorelease];
}

-(id)loadBinary:(NSString*)path Info:(XMLNode*)i
{
	ASSERT(path != nil);
	
	NSString* fullpath = [ResourceMgr fullPathFromRelativePath:path];
	ASSERT(fullpath);
	NSData* data = [NSData dataWithContentsOfFile:fullpath];
	
	return data;	
}

-(id)loadStrings:(NSString*)path Info:(XMLNode*)i
{
	ASSERT(path != nil);
	
	NSString* fullpath = [ResourceMgr fullPathFromRelativePath:path];
	ASSERT(fullpath);
	NSData* data = [NSData dataWithContentsOfFile:fullpath];
	XMLDocument* doc = [XMLDocument create];
	[doc parseData:data];
	XMLNode* root = doc->root;
	Strings* strings = [[Strings alloc] initWithXML:root];
	
	return [strings autorelease];		
}

-(id)loadElement:(NSString*)path Info:(XMLNode*)i
{
	ASSERT(path != nil);
	
	NSString* fullpath = [ResourceMgr fullPathFromRelativePath:path];
	ASSERT(fullpath);
	NSData* data = [NSData dataWithContentsOfFile:fullpath];
	XMLDocument* doc = [XMLDocument create];
	[doc parseData:data];
	XMLNode* root = doc->root;
	BaseElement* element = [ef generateElement:root];
	
	return element;	
}

-(void)update
{
	id obj = [loadQueue objectAtIndex:loaded];
	int r = [obj intValue];

	if ([self loadResource:r])
	{		
		loaded++;
		// notify delegate
		if (resourcesDelegate)
		{
			[resourcesDelegate resourceLoaded:r];
		}
		if (loaded == loadCount)
		{
			// notify delegate
			if (resourcesDelegate)
			{
				[resourcesDelegate allResourcesLoaded];
			}
			[self stopTimer];
		}
	}
	else
	{
		//TODO: handle resource load error
		ASSERT(FALSE);
	}
}

-(int)getPercentLoaded
{
	if (loadCount == 0) 
	{
		return 100;
	}
	else
	{
		return ((100 * loaded) / loadCount);
	}
}

-(bool)isBusy
{
	return (updateTimer != nil);
}

-(bool)hasResource:(int)resID
{
	ASSERT(resID >= 0);
	if ([resources count] <= resID)
	{
		return FALSE;
	}
	
	return ([self getResource:resID] != nil);
}

-(id)getResource:(int)resID
{
	ASSERT(resID >= 0 && resID < [resources count]);	
	return [resources objectAtIndex:resID];
}

-(NSString*)getString:(int)strID
{
	int resID = strID >> 16;
	int str = strID & 0xFFFF;
	Strings* strings = [self getResource:resID];
	ASSERT(strings);
	return [strings getString:str];
}

-(void)freeResource:(int)resID
{
	ASSERT(resID >= 0 && resID < [resources count]);
	id res = [self getResource:resID];
	int rc = [res retainCount];
	if (res)
	{
		if (rc > 1)
		{
			ResEntry* re = &resList[resID];
			ASSERT_MSG(FALSE, FORMAT_STRING(@"Resource ID: %d (%@) not freed because retainCount = %d", resID, re->path, rc)); 
		}
		[resources unsetObjectAtIndex:resID];		
	}
}

-(void)freePack:(int*)p
{
	int* pack = p;
	
	int size = 0;
	for (; pack[size] != UNDEFINED; size++);

	for (int i = size - 1; i >= 0 ; i--)
	{
		[self freeResource:pack[i]];
	}		
}

-(void)loadPack:(int*)p
{
	int* pack = p;
	
	for (int i = 0; pack[i] != UNDEFINED; i++)
	{
		if (![self hasResource:pack[i]])
		{
			[self addResourceToLoadQueue:pack[i]];
		}
		else
		{
			ASSERT_MSG(FALSE, FORMAT_STRING(@"Resource ID %d is trying to load twice", pack[i]));
		}			
	}
}

-(int)getResourceIDFromPath:(NSString*)p
{
	ASSERT(resList);
	
	int i = 0;
	while(TRUE)
	{
		if ([p isEqualToString:resList[i].path])
		{
			return i;
		}
		i++;
	}
	
	return UNDEFINED;
}

	

-(void)dealloc
{
	[loadQueue release];
	[resources release];
	[ef release];
	[super dealloc];
}

@end
