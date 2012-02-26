//
//  Loader.h
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoaderDelegate <NSObject>
-(void)loaderFinishedWith:(NSMutableData*)data from:(NSString*)url withSuccess:(BOOL)success;
@end

// simple HTTP loader with cache support
@interface Loader : NSObject 
{
	NSMutableData* receivedData;
	NSString* loaderUrl;
	id<LoaderDelegate> loaderDelegate;
	
	bool useCache;
}

@property(assign) id<LoaderDelegate> loaderDelegate;

-(void)load:(NSString*)url;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection*)connection;

-(void)turnOnCache;
-(void)deleteCache;

@end
