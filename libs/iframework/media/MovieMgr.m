//
//  MovieMgr.m
//  fantasydate
//
//  Created by reaxion on 27.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MovieMgr.h"
#import "Debug.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MovieMgr

#ifdef MOVIE_SUPPORT_ENABLED

@synthesize delegate;

-(id)init
{
	if (self = [super init])
	{		
		controlsHidden = FALSE;
		
		// Register to receive a notification that the movie is now in memory and ready to play
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(moviePreloadDidFinish:) 
													 name:MPMoviePlayerContentPreloadDidFinishNotification 
												   object:nil];
		
		// Register to receive a notification when the movie has finished playing. 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(moviePlayBackDidFinish:) 
													 name:MPMoviePlayerPlaybackDidFinishNotification 
												   object:nil];
		
		// Register to receive a notification when the movie scaling mode has changed. 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(movieScalingModeDidChange:) 
													 name:MPMoviePlayerScalingModeDidChangeNotification 
												   object:nil];
	}
	
	return self;
}

-(void)playURL:(NSString*)url
{
	[moviePlayer release];

	NSURL* surl = nil;
	if ([url hasPrefix:@"http"])
	{
		surl = [NSURL URLWithString:url];
	}
	else
	{
		surl = [NSURL fileURLWithPath:url];
	}
	moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:surl];
	ASSERT(moviePlayer);
	if (controlsHidden)
	{
		[moviePlayer setMovieControlMode:MPMovieControlModeHidden];			
	}
	[moviePlayer play];
	
    NSArray* windows = [[UIApplication sharedApplication] windows];
    // There should be more than one window, because the movie plays in its own window
    if (controlsHidden && [windows count] > 1)
    {
        // The movie's window is the one that is active
        UIWindow* moviePlayerWindow = [[UIApplication sharedApplication] keyWindow];
        // Now we create an invisible control with the same size as the window
        UIControl* overlay = [[[UIControl alloc] initWithFrame:moviePlayerWindow.frame]autorelease];
		
        // We want to get notified whenever the overlay control is touched
        [overlay addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchDown];
		
        // Add the overlay to the window's subviews
        [moviePlayerWindow addSubview:overlay];
    }
	
}

-(void)stop
{
	[moviePlayer stop];
}

-(void)setControlsHidden
{
	controlsHidden = TRUE;
}

//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	/* 	 
	 MPMoviePlayerController* moviePlayerObj = [notification object];
	 */
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{	
	[delegate moviePlaybackFinished:[moviePlayer.contentURL absoluteString]]; 
}

//  Notification called when the movie scaling mode has changed.
- (void) movieScalingModeDidChange:(NSNotification*)notification
{

}

-(void)dealloc
{		
	// remove all movie notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerContentPreloadDidFinishNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerScalingModeDidChangeNotification
                                                  object:nil];
	[moviePlayer release]; 
	[super dealloc];
}

#endif // MOVIE_SUPPORT_ENABLED

@end

