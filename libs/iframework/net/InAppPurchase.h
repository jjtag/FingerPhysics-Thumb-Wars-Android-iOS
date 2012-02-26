//
//  InAppPurchase.h
//  frameworkTest
//
//  Created by Efim Voinov on 29.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef IN_APP_PURCHASE_ENABLED
@protocol InAppPurchaseProtocol
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
-(void)recordTransaction:(SKPaymentTransaction*)transaction;
-(void)provideContent:(NSString*)identifier;
-(void)failedTransaction:(SKPaymentTransaction*)transaction;
@end

// In App Purchase wrapper
// this functionality requires StoreKit.framework

@interface InAppPurchase : NSObject <SKPaymentTransactionObserver> 
{			
	id<InAppPurchaseProtocol> delegate;
}

@property (assign) id<InAppPurchaseProtocol> delegate;

-(bool)checkInAppPurchaseEnabled;
-(void)requestDataForProducts:(DynamicArray*)list;
-(void)purchaseItem:(NSString*)identifier;
@end

#else

@interface InAppPurchase
{
}
@end

#endif // IN_APP_PURCHASE_ENABLED

/*
 -(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
 { 
	 NSArray* myProduct = response.products;
 
	 // populate UI
	 [request autorelease];
 }
*/