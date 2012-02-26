//
//  MovieMgr.h
//  fantasydate
//
//  Created by reaxion on 27.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef MOVIE_SUPPORT_ENABLED

@class MPMoviePlayerController;

@protocol MovieMgrDelegate
-(void)moviePlaybackFinished:(NSString*)url;
@end

// simple singleton movie player (wrapper around MPMoviePlayerController)
@interface MovieMgr : NSObject 
{
	MPMoviePlayerController* moviePlayer;	
	id<MovieMgrDelegate> delegate;
	bool controlsHidden;
}

@property (assign) id<MovieMgrDelegate> delegate; 

-(void)playURL:(NSString*)url;
-(void)stop;
-(void)setControlsHidden;

// callback methods for videoplayer
-(void)moviePreloadDidFinish:(NSNotification*)notification;
-(void)moviePlayBackDidFinish:(NSNotification*)notification;
-(void)movieScalingModeDidChange:(NSNotification*)notification;

@end

#else

@interface MovieMgr : NSObject 
{
}

@end

#endif // MOVIE_SUPPORT_ENABLED