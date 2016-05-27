//
//  SWSubscriptionViewController.h
//  StingWax
//
//  Created by Sudhir Chovatiya on 3/3/16.
//  Copyright © 2016 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWBaseViewController.h"
#import <StoreKit/StoreKit.h>

@interface SWSubscriptionViewController : SWBaseViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    __weak IBOutlet UIButton *btnDismissView;
    __weak IBOutlet UIButton *btnSubscription;
    __weak IBOutlet UIButton *btnBronz;
    __weak IBOutlet UIButton *btnSilver;
    __weak IBOutlet UIButton *btngold;
    
    
    SKProductsRequest *productsRequest;
    NSArray *validProducts;
    UIActivityIndicatorView *activityIndicatorView;
}

@property(assign) BOOL isSubscriptionViewShowing;

-(IBAction)btnDismissViewWasTapped:(id)sender;
-(IBAction)btnSubscriptionWasTapped:(id)sender;
-(IBAction)btnBronzWasTapped:(id)sender;
-(IBAction)btnSilverWasTapped:(id)sender;
-(IBAction)btngoldWasTapped:(id)sender;


- (void)fetchAvailableProducts;
- (void)purchaseMyProduct:(SKProduct*)product;


@end
