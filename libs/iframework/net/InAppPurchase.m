//
//  InAppPurchase.m
//  frameworkTest
//
//  Created by Efim Voinov on 29.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InAppPurchase.h"

@implementation InAppPurchase

#ifdef IN_APP_PURCHASE_ENABLED

@synthesize delegate;

-(id)init
{
	if (self = [super init])
	{
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];		
	}
	
	return self;
}

-(bool)checkInAppPurchaseEnabled
{
	return ([SKPaymentQueue canMakePayments]);
}

-(void)requestDataForProducts:(DynamicArray*)list
{
	NSSet* set = [[NSSet allocAndAutorelease] init];
	
	for (NSString* i in list)
	{
		[set addObject:i];
	}
	
	SKProductsRequest* request= [[SKProductsRequest alloc] initWithProductIdentifiers:set];	
	request.delegate = delegate;
	
	[request start];
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction* transaction in transactions)		
    {		
        switch (transaction.transactionState)		
        {				
            case SKPaymentTransactionStatePurchased:				
                [self completeTransaction:transaction];				
                break;
				
            case SKPaymentTransactionStateFailed:				
                [self failedTransaction:transaction];				
                break;
				
            case SKPaymentTransactionStateRestored:				
                [self restoreTransaction:transaction];				
				break;
				
            default:				
                break;				
        }		
    }	
}

-(void)completeTransaction:(SKPaymentTransaction *)transaction
{
	// Your application should implement these two methods.
    [delegate recordTransaction:transaction];
    [delegate provideContent:transaction.payment.productIdentifier];
	
	// Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [delegate recordTransaction:transaction];
    [delegate provideContent:transaction.originalTransaction.payment.productIdentifier];
	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
		[delegate failedTransaction:transaction];
    }
	
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)purchaseItem:(NSString)identifier
{
	SKPayment* payment = [SKPayment paymentWithProductIdentifier:identifier];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void)dealloc
{
	[super dealloc];
}

#endif // IN_APP_PURCHASE_ENABLED

@end
