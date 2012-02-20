//
//  FPUser.m
//  champions
//
//  Created by ikoryakin on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FPUser.h"
#import "FrameworkTypes.h"
#import "NSDataAdditions.h"
#import "GameScene.h"

@implementation FPUser

@synthesize userId, feintId, udId, name, countryId, stateId, region, email;
@synthesize online, registered, clearBlob;
@synthesize levelsProgress;
@synthesize tutorialLevel;
@synthesize lastPlayedMap;
@synthesize explodedBlocks, connectedMagnets, brokenBlocks, collectedStars, bumperStrikes, blocksStacked, 
levelsWoninARow, menusVisited, ownHighscoreBeatenCount, ownBestTimeBeatenCount;

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.userId forKey:@"userId"];
	[coder encodeObject:self.feintId forKey:@"feintId"];
    [coder encodeObject:self.name forKey:@"name"];
	[coder encodeObject:self.email forKey:@"email"];
	[coder encodeInteger:self.countryId forKey:@"countryId"];
	[coder encodeInteger:self.stateId forKey:@"stateId"];
    [coder encodeObject:self.region forKey:@"region"];
//	[coder encodeBool:self.online forKey:@"online"];
	[coder encodeBool:self.registered forKey:@"registered"];
	[coder encodeBool:self.clearBlob forKey:@"clearBlob"];
	[coder encodeInteger:self.tutorialLevel forKey:@"tutorialLevel"];
	[coder encodeObject:self.lastPlayedMap forKey:@"lastPlayedMap"];
	
	[coder encodeInteger:self.explodedBlocks forKey:@"explodedBlocks"];
	[coder encodeInteger:self.connectedMagnets forKey:@"connectedMagnets"];
	[coder encodeInteger:self.brokenBlocks forKey:@"brokenBlocks"];
	[coder encodeInteger:self.collectedStars forKey:@"collectedStars"];
	[coder encodeInteger:self.bumperStrikes forKey:@"bumperStrikes"];
	[coder encodeInteger:self.blocksStacked forKey:@"blocksStacked"];
	[coder encodeInteger:self.levelsWoninARow forKey:@"levelsWoninARow"];
	[coder encodeInteger:self.menusVisited forKey:@"menusVisited"];
	[coder encodeInteger:self.ownHighscoreBeatenCount forKey:@"ownHighscoreBeatenCount"];
	[coder encodeInteger:self.ownBestTimeBeatenCount forKey:@"ownBestTimeBeatenCount"];
	
	NSDictionary* progress = [self.levelsProgress copy];
	[coder encodeObject:progress forKey:@"levelsProgress"];		
	[progress release];
}


-(id)initWithCoder:(NSCoder *)coder
{
	if(self = [super init])
	{
		self.userId = [coder decodeObjectForKey:@"userId"];
		self.feintId = [coder decodeObjectForKey:@"feintId"];
		self.udId = [[UIDevice currentDevice] uniqueIdentifier];
		self.name = [coder decodeObjectForKey:@"name"];
		self.email = [coder decodeObjectForKey:@"email"];
		self.countryId = [coder decodeIntegerForKey:@"countryId"];
		self.stateId = [coder decodeIntegerForKey:@"stateId"];
		self.region = [coder decodeObjectForKey:@"region"];
		self.registered = [coder decodeBoolForKey:@"registered"];
		self.clearBlob = [coder decodeBoolForKey:@"clearBlob"];
		self.tutorialLevel = [coder decodeIntegerForKey:@"tutorialLevel"];
		self.lastPlayedMap = [coder decodeObjectForKey:@"lastPlayedMap"];
		
		self.explodedBlocks = [coder decodeIntegerForKey:@"explodedBlocks"];
		self.connectedMagnets = [coder decodeIntegerForKey:@"connectedMagnets"];
		self.brokenBlocks = [coder decodeIntegerForKey:@"brokenBlocks"];
		self.collectedStars = [coder decodeIntegerForKey:@"collectedStars"];
		self.bumperStrikes = [coder decodeIntegerForKey:@"bumperStrikes"];
		self.blocksStacked = [coder decodeIntegerForKey:@"blocksStacked"];
		self.levelsWoninARow = [coder decodeIntegerForKey:@"levelsWoninARow"];
		self.menusVisited = [coder decodeIntegerForKey:@"menusVisited"];
		self.ownHighscoreBeatenCount = [coder decodeIntegerForKey:@"ownHighscoreBeatenCount"];
		self.ownBestTimeBeatenCount = [coder decodeIntegerForKey:@"ownBestTimeBeatenCount"];		
		
	//		self.online = [coder decodeBoolForKey:@"online"];
		self.online = FALSE;
		NSDictionary* progress = [coder decodeObjectForKey:@"levelsProgress"];
		self.levelsProgress = [NSMutableDictionary dictionaryWithDictionary:progress];
	}
	return self;
}

-(id)init
{
	if(self = [super init])
	{
		levelsProgress = [[NSMutableDictionary alloc] init];
		lastPlayedMap = nil;
	}
	return self;
}

-(void)dealloc
{
	if(udId)
		[udId release];
	[levelsProgress release];
	[super dealloc];
}

-(void)setDefaults
{
	userId = nil;
	feintId = nil;
	self.udId = [[UIDevice currentDevice] uniqueIdentifier];
	self.name = [NSString stringWithString:@"Unknown"];
	countryId = 0;
	stateId = 0;
	region = nil;
	email = nil;
	registered = FALSE;
	clearBlob = FALSE;
	tutorialLevel = 0;
	self.lastPlayedMap = [NSString stringWithString:@"1-tutorial-01.bim"];
	
	explodedBlocks = 0;
	connectedMagnets = 0;
	brokenBlocks = 0;
	collectedStars = 0;
	bumperStrikes = 0;
	blocksStacked = 0;
	levelsWoninARow = 0;
	menusVisited = 0;
	ownHighscoreBeatenCount = 0;
	ownBestTimeBeatenCount = 0;
}

-(void)updateGameProgress:(FPUser*)user
{
	if(!userId && user.userId)
		userId = user.userId;
	if(countryId == 0)
		countryId = user.countryId;
	if(stateId == 0)
		stateId = user.stateId;
	if(region == 0)
		region = user.region;
	//user is cached;
	
//TODO: Sync game progress
	if(user.tutorialLevel == UNDEFINED || tutorialLevel == UNDEFINED)
	{
		tutorialLevel = UNDEFINED;
	}
	else
	{
		tutorialLevel = MAX(tutorialLevel, user.tutorialLevel);
	}
	
	explodedBlocks = MAX(user.explodedBlocks, explodedBlocks);
	connectedMagnets = MAX(user.connectedMagnets, connectedMagnets);
	brokenBlocks = MAX(user.brokenBlocks, brokenBlocks);
	collectedStars = MAX(user.collectedStars, collectedStars);
	bumperStrikes = MAX(user.bumperStrikes, bumperStrikes);
	blocksStacked = MAX(user.blocksStacked, blocksStacked);
	levelsWoninARow = MAX(user.levelsWoninARow, levelsWoninARow);
	menusVisited = MAX(user.menusVisited, menusVisited);
	ownHighscoreBeatenCount = MAX(user.ownHighscoreBeatenCount, ownHighscoreBeatenCount);
	ownBestTimeBeatenCount = MAX(user.ownBestTimeBeatenCount, ownBestTimeBeatenCount);
	
	self.lastPlayedMap = [NSString stringWithString:user.lastPlayedMap];
	
//	NSLog(@"updating user progress");
	
	NSEnumerator *enumerator = [user.levelsProgress keyEnumerator];	
	NSString* key;
	while ((key = [enumerator nextObject]))
	{
//		NSLog(@"key = %@", key);
		FPScores* scores = [levelsProgress objectForKey:key];
		FPScores* cachedScores = [user.levelsProgress objectForKey:key];
		if( !scores || (scores && cachedScores && scores->scores < cachedScores->scores) )
		{
			[levelsProgress setObject:cachedScores forKey:key];
		}
	}
}

+(NSDictionary*)parseString:(NSString*)string namesInBase64:(BOOL)b
{
	NSArray *parsedLines = [string componentsSeparatedByString:@"\r\n"];
	NSMutableArray *keys = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *values = [[[NSMutableArray alloc] init] autorelease];
	for(NSString* str in parsedLines)
	{
		NSRange range = [str rangeOfString:@"="];
		if(range.length > 0)
		{
			NSString* key = [str substringToIndex:range.location];
			NSString* value = [str substringFromIndex:range.location+1];
			if(keys && values)
			{
				if(b && [key hasPrefix:@"name"])
				{
					NSData *fileData = [NSData dataWithBase64EncodedString:value];
					value = [[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding] autorelease];
//					NSLog(@"%@ %@", key, value);
				}				
				[keys addObject:key];
				[values addObject:value];
			}			
		}
	}
	NSDictionary* dict = [[[NSDictionary alloc] initWithObjects:values forKeys:keys] autorelease];
	return dict;
}

+(ASIFormDataRequest*)createTemplateRequestWithAction:(NSString*)action
{
	NSURL *url = [NSURL URLWithString:@"http://gamarama.reaxion.com/gamarama2/Do"];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setPostFormat:ASIURLPostFormat];
	[request setPostDivider:[NSString stringWithString:@"\n"]];
	[request addPostValue:@"CallExtension2" forKey:@"action"];
	[request addPostValue:@"138" forKey:@"gameId"];
	[request addPostValue:action forKey:@"extAction"];
		
	return request;
}

+(NSString*)calcHashValue:(NSString*)str
{
	int hashValue = 0;	
	for (int i = 0; i < [str length]; ++i)
	{
		hashValue = ( hashValue << 5 ) + hashValue + [str characterAtIndex:i];
	}
	if ( hashValue < 0 ) hashValue = -hashValue;
	return FORMAT_STRING(@"%i", hashValue);
}

-(void)updateUserRegistration:(BOOL)synchronously
{
	NSString *type, *accId;
	if(feintId)
	{
		accId = feintId;
		type = @"openFeintId";
	}
	else
	{
		accId = [[UIDevice currentDevice] uniqueIdentifier];
		type = @"udid";
	}	
//	NSLog(@"user %@ type %@", accId, type );
	NSData* data = [name dataUsingEncoding:NSUTF8StringEncoding];
	NSString* encodedName = [data base64Encoding];
	ASIFormDataRequest *request = [FPUser createTemplateRequestWithAction:@"addUser"];
	[request addRequestHeader:@"content-encoding" value:@"utf-8"];
	[request setPostValue:accId forKey:@"id"];	
	[request setPostValue:type forKey:@"type"];	
	[request setPostValue:encodedName forKey:@"name"];	
	[request setPostValue:FORMAT_STRING(@"%i", countryId) forKey:@"countryId"];
	[request setPostValue:FORMAT_STRING(@"%i", stateId) forKey:@"stateId"];
	[request setPostValue:email forKey:@"email"];
	[request setDelegate:self];
	
	[self retain];	
	
	if (synchronously)
		[request startSynchronous];
	else
		[request startAsynchronous];
		
//	NSString* content = FORMAT_STRING(@"action=CallExtension2\ngameId=138\nextAction=addUser\nid=%@\ntype=%@\nname=%@\ncountryId=%i\nstateId=%i\nemail=%@\n", accId, type, encodedName, countryId, stateId, @"");
//	NSLog(@"%@", content);
//	NSURL *url = [NSURL URLWithString:@"http://model.reaxion.com/gamarama2/Do"];
//	NSMutableURLRequest* urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
//	[urlRequest setHTTPMethod:@"POST"];
//	[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]]; 
//	
//	NSURLConnection* connection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
	
//	[self scores];
}

-(FPScores*)getScoresForMap:(NSString*)mapName
{
	FPScores* scores = nil;
	if(levelsProgress)
	{
		scores = [levelsProgress objectForKey:mapName];
	}
	return scores;
}

-(void)setScores:(FPScores*)scores forMap:(NSString*)mapName
{
	ASSERT(levelsProgress);
	[levelsProgress setValue:scores forKey:mapName];
}

-(void)addScore:(int)score bumperMultiplier:(float)m starBonuses:(int)s totalBonuses:(int)ts time:(int)time forMap:(NSString*)mapName
{
	FPScores* scores = [self getScoresForMap:mapName];
	if(!scores)
	{
		scores = [[[FPScores alloc] init] autorelease];
	}

	if (scores->time != 0 && scores->time <= time)
	{
		[GameScene handleBeatenOwnTime];	
	}
	
	if(scores->scores <= score)
	{
		if (scores->scores != 0)
		{
			[GameScene handleBeatenOwnScore];
		}
		scores->scores = score;
		scores->bumper = m;
		scores->time = time;
		scores->bonuses = s;
	}

	if(scores->medal < 4)
	{
		scores->medal = MAX(scores->medal, 1);
		if(ts == s)
		{
			if(scores->medal == 2)
				scores->medal += 1;
			else
				scores->medal += 2;
		}
		else
		{
			if(scores->medal == 3) scores->medal = 2;
		}

		scores->medal = MIN(4, scores->medal);
	}
//	NSLog(@"medal %i", scores->medal);
	[self setScores:scores forMap:mapName];
	[self saveGameProgress];
	
	if(!userId) return;
	
#ifndef FREE	
	ASIFormDataRequest *request = [FPUser createTemplateRequestWithAction:@"points"];	
	[request setPostValue:@"points" forKey:@"extAction"];
	[request setPostValue:userId forKey:@"userId"];	
	[request setPostValue:mapName forKey:@"name"];		
	[request setPostValue:FORMAT_STRING(@"%.2f", m) forKey:@"bumperMultiplier"];
	[request setPostValue:FORMAT_STRING(@"%d", s) forKey:@"starBonuses"];
	[request setPostValue:FORMAT_STRING(@"%d", time) forKey:@"time"];
	[request setPostValue:FORMAT_STRING(@"%d", score) forKey:@"score"];
	
	NSString* hashStr = FORMAT_STRING(@"bumperMultiplier=%.2f&name=%@&score=%d&starBonuses=%d&time=%d&userId=%@",
				  m, mapName, score, s, time, userId);
	NSString* hash = [FPUser calcHashValue:hashStr];
	
	[request setPostValue:hash forKey:@"sig"];
	[request setDelegate:self];
	
	[self retain];	
	
	[request startAsynchronous];
#endif
}

-(void)topAll:(id)delegate
{
	ASIFormDataRequest *request = [FPUser createTemplateRequestWithAction:@"topall"];	
	[request setPostValue:userId forKey:@"userId"];
	[request setPostValue:@"TRUE" forKey:@"team"];
	[request setPostValue:FORMAT_STRING(@"%i", 20) forKey:@"limit"];
	if(!delegate)delegate = self;
	[request setDelegate:delegate];
	
	[self retain];	

	[request startAsynchronous];
}

-(void)topStates:(id)delegate
{
	ASIFormDataRequest* request = [FPUser createTemplateRequestWithAction:@"topStates"];
	[request setPostValue:FORMAT_STRING(@"%i", stateId) forKey:@"stateId"];
	[request setPostValue:FORMAT_STRING(@"%i", 10) forKey:@"limit"];
	if(!delegate)delegate = self;
	[request setDelegate:delegate];
	
	[self retain];		

	[request startAsynchronous];
}

-(void)states:(id)delegate
{
	ASIFormDataRequest* request = [FPUser createTemplateRequestWithAction:@"states"];
	if(!delegate)delegate = self;
	[request setDelegate:delegate];
	
	[self retain];		

	[request startAsynchronous];
}

-(void)scores
{
	ASIFormDataRequest* request = [FPUser createTemplateRequestWithAction:@"scores"];
	[request setPostValue:userId forKey:@"userId"];
	[request setDelegate:self];
	
	[self retain];		
	
	[request startAsynchronous];
}

-(void)countries:(id)delegate
{
	ASIFormDataRequest* request = [FPUser createTemplateRequestWithAction:@"countries"];
	if(!delegate)delegate = self;
	[request setDelegate:delegate];
	
	[self retain];		

	[request startAsynchronous];
}

-(void)clearData
{
	ASIFormDataRequest* request =[FPUser createTemplateRequestWithAction:@"clearStats"];
	[request setPostValue:userId forKey:@"userId"];
	[request setDelegate:self];
	
	[self retain];		
	
	[request startAsynchronous];

	NSError* error;
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"topAll"];
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"countries"];
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"states"];
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"scores"];
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

-(void)print
{
	NSLog(@"userId %@", userId);
	NSLog(@"feintId %@", feintId);
	NSLog(@"UDID %@", udId);
	NSLog(@"name %@", name);
	NSLog(@"countryId %i", countryId);
	NSLog(@"stateId %i", stateId);
	NSLog(@"email %@", email);
	NSLog(@"lastMap %@", lastPlayedMap);
	NSEnumerator *enumerator = [levelsProgress keyEnumerator];	
	NSString* key;
	while ((key = [enumerator nextObject]))
	{
		FPScores* scores = [levelsProgress objectForKey:key];
		NSLog(@"key = %@ medal %i, scores = %i, time = %i", key, scores->medal, scores->scores, scores->time);
	}
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	if([request isMemberOfClass:[ASIFormDataRequest class]])
	{
		ASIFormDataRequest* r = (ASIFormDataRequest*)request;
		NSString* responseString = [request responseString];
		NSString* action = [r getPostValueForKey:@"extAction"];
//		NSLog(@"%@ %@", action, responseString);
		//names are in base64 for all actions, except scores
		BOOL nameInBase64 = ![action isEqualToString:@"scores"];
		NSDictionary* dict = [FPUser parseString:responseString namesInBase64:nameInBase64];
		NSString* status = [dict objectForKey:@"Status"];
		if ([status isEqualToString:@"Ok"])
		{
			if([action isEqualToString:@"addUser"])
			{
				NSString* uId = [dict objectForKey:@"userId"];
				if(uId)
					userId = [uId copy];
				NSLog(@"name %@", [r getPostValueForKey:@"name"]);
			}
			
			//save score tables to filesystem
			NSString* countStr = nil;
			countStr = [dict objectForKey:@"count"];
			if(countStr && action)
			{
				NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		
				NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:action];
				[dict writeToFile:path atomically:TRUE];
			}
		}
	}
	[self autorelease];	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSLog(@"req failed");
	[self autorelease];	
}

//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//	NSString* responseString = [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding] autorelease];
////	NSLog(@"response %@", responseString);
//	NSDictionary* dict = [FPUser parseString:responseString namesInBase64:TRUE];
//	NSString* user = [dict objectForKey:@"userId"];	
//	if(user)
//	{
//		userId = [user copy];
//		NSLog(@"userId = %@", user);
//	}
//}

-(void)saveGameProgress
{
//	NSLog(@"save game progress");
	if(udId)[udId release];
	udId = [[[UIDevice currentDevice] uniqueIdentifier] copy];
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 		

#ifdef FREE
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"settings_free.blob"];
#else
	NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"settings.blob"];
#endif	
	NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
	[data writeToFile:path atomically:TRUE];
}

-(int)getNumberOfExpertLevels
{
	int expertCount = 0;
	NSEnumerator *enumerator = [levelsProgress keyEnumerator];	
	NSString* key;
	while ((key = [enumerator nextObject]))
	{
		FPScores* cachedScores = [levelsProgress objectForKey:key];
		if(cachedScores->medal == 4)
		{
			expertCount++;
		}
	}	
	
	return expertCount;
}

@end
