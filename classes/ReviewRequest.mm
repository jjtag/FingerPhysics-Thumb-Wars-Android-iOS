#include "ReviewRequest.h"

#import "Localization.h"

//const NSString* KeyReviewed = @"ReviewRequestReviewedForVersion";
NSString* KeyDontAsk = @"ReviewRequestDontAsk";
NSString* KeyWinsCount = @"ReviewRequestWinsCount";

#define REMIND_AFTER_LEVELS_NUM 25

@implementation ReviewRequestDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	switch (buttonIndex)
	{
	case 0: // remind me later
	{
		[defaults setInteger:0 forKey:KeyWinsCount];
		break;
	}
	
	case 1: // rate it now
	{
		[defaults setBool:true forKey:KeyDontAsk];
		
		NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		//[defaults setValue:version forKey:KeyReviewed];
		// http://creativealgorithms.com/blog/content/review-app-links-sorted-out
		// http://bjango.com/articles/ituneslinks/

		NSString* iTunesLink = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=380480463";
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
				
		break;
	}
	
	case 2: // don't ask again
		[defaults setBool:true forKey:KeyDontAsk];
		break;
	default:
		break;
	}

	[self release];
}

@end

bool ReviewRequest::PlayerWonCheckIfShouldReview()
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	if ([defaults boolForKey:KeyDontAsk])
		return false;

	int winsCount = [defaults integerForKey:KeyWinsCount];
	winsCount++;
	[defaults setInteger:winsCount forKey:KeyWinsCount];
	/*
	NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString* reviewedVersion = [defaults stringForKey:KeyReviewed];
	if ([reviewedVersion isEqualToString:version])
		return false;
*/
	if (winsCount >= REMIND_AFTER_LEVELS_NUM)
	{
		return true;
	}
	
	return false;
}

void ReviewRequest::AskForReview()
{
	ReviewRequestDelegate* delegate = [[ReviewRequestDelegate alloc] init];
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"STR_RATE_TITLE", @"Enjoying Finger Physics: Thumb Wars?") 
					message:LocalizedString(@"STR_RATE_MESSAGE", @"If so, please rate this game with 5 stars on the App Store so we can keep the free updates coming.")
					delegate:delegate cancelButtonTitle:LocalizedString(@"STR_RATE_LATER", @"Remind me later") otherButtonTitles:LocalizedString(@"STR_RATE_YES", @"Yes, rate it!"), LocalizedString(@"STR_RATE_NO", @"Don't ask again"), nil];
	[alert show];
	[alert release];
}



