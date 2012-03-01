#ifndef st_ReviewRequest_h_
#define st_ReviewRequest_h_

@interface ReviewRequestDelegate : NSObject < UIAlertViewDelegate >
{
}

@end

namespace ReviewRequest
{
	bool PlayerWonCheckIfShouldReview();
	void AskForReview();
};


#endif
