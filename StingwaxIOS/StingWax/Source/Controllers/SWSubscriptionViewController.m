//
//  SWSubscriptionViewController.m
//  StingWax
//
//  Created by Sudhir Chovatiya on 3/3/16.
//  Copyright © 2016 __CompanyName__. All rights reserved.
//

#import "SWSubscriptionViewController.h"
#import "SWHelper.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Keys.h"
#import "SVProgressHUD.h"
#import "SWAPI.h"
#import "SWAppState.h"

#define kBronzeProductID                            @"com.stingwax.bronzeplan"
#define kSilverProductID                            @"com.stingwax.silver"
#define kGoldProductID                              @"com.stingwax.goldplan"

static bool hasAddObserver=NO;

@implementation SWSubscriptionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![SWHelper doWeHaveInternetConnection]) {
        [UIAlertView showWithMessage:INTERNET_ON_LAUNCH handler:nil];
    }
    self.isSubscriptionViewShowing = FALSE;
    
//    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    activityIndicatorView.center = self.view.center;
//    [activityIndicatorView hidesWhenStopped];
//    [self.view addSubview:activityIndicatorView];
//    [activityIndicatorView startAnimating];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UITabBar appearance] setTranslucent:TRUE];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor clearColor]];
    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    [[UITabBar appearance] setTintColor:[UIColor clearColor]];
    [[UITabBar appearance] setBarStyle:UIBarStyleDefault];
    
    [self.navigationController.navigationBar setHidden:TRUE];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isSubscriptionViewShowing = TRUE;
    [self fetchAvailableProducts];
    
    
    
//    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
//    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
//    
//    NSString *str = [NSJSONSerialization JSONObjectWithData:receipt options:kNilOptions error:nil];
//    // Create the JSON object that describes the request
//    NSError *error;
//    NSDictionary *requestContents = @{
//                                      @"receipt-data": [receipt base64EncodedStringWithOptions:0]
//                                      };
//    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
//                                                          options:0
//                                                            error:&error];
//    
//    if (!requestData) { /* ... Handle error ... */ }
//    
//    // Create a POST request with the receipt data.
//    NSURL *storeURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
//    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
//    [storeRequest setHTTPMethod:@"POST"];
//    [storeRequest setHTTPBody:requestData];
//    
//    // Make a connection to the iTunes Store on a background queue.
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                               if (connectionError) {
//                                   /* ... Handle error ... */
//                               } else {
//                                   NSError *error;
//                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                                   if (!jsonResponse) { /* ... Handle error ...*/ }
//                                   /* ... Send a response back to the device ... */
//                               }
//                           }];
    
}



-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isSubscriptionViewShowing = FALSE;
    //Hide purchase button initially
     [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setHidden:FALSE];
}


-(IBAction)btnDismissViewWasTapped:(id)sender {
    
    if ([self isModal]) {
        [self dismissViewControllerAnimated:TRUE completion:^{
            
        }];
    }
    else if (self.tabBarController.selectedIndex == 1) {
        [self.tabBarController setSelectedIndex:0];
    }
    else {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

- (BOOL)isModal {
    if([self presentingViewController])
        return YES;
    if([[self presentingViewController] presentedViewController] == self)
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    
    return NO;
}


-(IBAction)btnSubscriptionWasTapped:(id)sender {
   
}

-(IBAction)btnBronzWasTapped:(id)sender {

    for (SKProduct *validProduct in validProducts) {
        if ([validProduct.productIdentifier isEqualToString:kBronzeProductID]) {
            NSLog(@"************ PURCHASE ************");
            NSLog(@"%@",[NSString stringWithFormat: @"Product Title: %@",validProduct.localizedTitle]);
            NSLog(@"%@",[NSString stringWithFormat: @"Product Desc: %@",validProduct.localizedDescription]);
            NSLog(@"%@",[NSString stringWithFormat: @"Product Price: %@",validProduct.price]);
            NSLog(@"************************");
//            [self purchaseMyProduct:validProduct];
        }
    }
}

-(IBAction)btnSilverWasTapped:(id)sender {
    for (SKProduct *validProduct in validProducts) {
        if ([validProduct.productIdentifier isEqualToString:kSilverProductID]) {
            NSLog(@"************ PURCHASE ************");
            NSLog(@"%@",[NSString stringWithFormat: @"Product Title: %@",validProduct.localizedTitle]);
            NSLog(@"%@",[NSString stringWithFormat: @"Product Desc: %@",validProduct.localizedDescription]);
            NSLog(@"%@",[NSString stringWithFormat: @"Product Price: %@",validProduct.price]);
            NSLog(@"************************");
//            [self purchaseMyProduct:validProduct];
        }
    }
}

-(IBAction)btngoldWasTapped:(id)sender {
    for (SKProduct *validProduct in validProducts) {
        if ([validProduct.productIdentifier isEqualToString:kGoldProductID]) {
            NSLog(@"************ PURCHASE ************");
            NSLog(@"%@",[NSString stringWithFormat: @"Product Title: %@",validProduct.localizedTitle]);
            NSLog(@"%@",[NSString stringWithFormat: @"Product Desc: %@",validProduct.localizedDescription]);
            NSLog(@"%@",[NSString stringWithFormat: @"Product Price: %@",validProduct.price]);
            NSLog(@"************************");
//            [self purchaseMyProduct:validProduct];
        }
    }
}



-(void)fetchAvailableProducts{
    NSSet *productIdentifiers = [NSSet setWithObjects:kBronzeProductID,kSilverProductID,kGoldProductID,nil];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    [SVProgressHUD showWithStatus:@"Fetching Products.." maskType:SVProgressHUDMaskTypeGradient];
}

- (void)purchaseMyProduct:(SKProduct*)product {
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"Purching Product:%@ ",product.productIdentifier);
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        if (!hasAddObserver) {
//            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            hasAddObserver=YES;
        }
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle: @"Purchases are disabled in your device"
                                                           message:nil
                                                          delegate: self
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark StoreKit Delegate

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing");
                [SVProgressHUD showWithStatus:@"Purchasing.." maskType:SVProgressHUDMaskTypeGradient];
                break;
            case SKPaymentTransactionStatePurchased:
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                NSLog(@" %@: %@",transaction.payment.productIdentifier, [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding]);
                if ([transaction.payment.productIdentifier isEqualToString:kBronzeProductID]) {
                    NSLog(@"Purchased ");

                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle: @"Bronze Plan Purchase is completed succesfully"
                                                                       message:nil
                                                                      delegate: self
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles: nil];
                    [alertView show];
//                    appState.currentUser.userId
                    
                    [self updateUserPlanWithUserId:appState.currentUser.userId subID:@"3" AndTransaction:transaction];
                }
                else if ([transaction.payment.productIdentifier isEqualToString:kSilverProductID]) {
                    NSLog(@"Purchased ");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle: @"Silver Plan Purchase is completed succesfully"
                                                                       message:nil
                                                                      delegate: self
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles: nil];
//                    [alertView show];
                    [self updateUserPlanWithUserId:appState.currentUser.userId subID:@"3" AndTransaction:transaction];
                }
                else if ([transaction.payment.productIdentifier isEqualToString:kGoldProductID]) {
                    NSLog(@"Purchased ");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle: @"Gold Plan Purchase is completed succesfully"
                                                                       message:nil
                                                                      delegate: self
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles: nil];
                    [alertView show];
                    [self updateUserPlanWithUserId:appState.currentUser.userId subID:@"3" AndTransaction:transaction];
                }
                
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Restored ");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Purchase failed ");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

#pragma mark completed Transactions call back

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
    [SVProgressHUD dismiss];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"restoreCompletedTransactionsFailedWithError");
    [SVProgressHUD dismiss];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions{
    NSLog(@"removedTransactions");
    [SVProgressHUD dismiss];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{

    NSInteger count = [response.products count];
    if (count>0) {
        validProducts = response.products;
        for (SKProduct *validProduct in response.products) {
            NSLog(@"************************");
            NSLog(@"%@",[NSString stringWithFormat: @"Product Title: %@",validProduct.localizedTitle]);
            NSLog(@"%@",[NSString stringWithFormat: @"Product Desc: %@",validProduct.localizedDescription]);
            NSLog(@"%@",[NSString stringWithFormat: @"Product Price: %@",validProduct.price]);
            NSLog(@"************************");
        }
    } else {
        UIAlertView *tmp = [[UIAlertView alloc] initWithTitle:@"Not Available"
                                                      message:@"No products to purchase"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Ok", nil];
        [tmp show];
    }    
//    [activityIndicatorView stopAnimating];
    [SVProgressHUD dismiss];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"request - didFailWithError: %@", [[error userInfo] objectForKey:@"NSLocalizedDescription"]);
    [SVProgressHUD dismiss];
}

#pragma mark - 
-(void)updateUserPlanWithUserId:(NSString *)userid subID:(NSString *)subID AndTransaction:(SKPaymentTransaction*)transaction {
    
    NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    NSError *error = nil;
    id jsonArray = [NSJSONSerialization JSONObjectWithData:receiptData options:kNilOptions error:&error];
    NSLog(@"Decoded : %@", jsonArray);
    NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    
    
    [SWLogger logEventWithObject:self selector:_cmd];
    [SVProgressHUD showWithStatus:@"Processing..." maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] getSubcriptionWithUserId:userid subscriptionID:subID completion:^(BOOL success, NSError *error) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
         if (success) {
                 [UIAlertView showWithMessage:@"Plan Purchase succesfully And you need to login again." cancelButtonTitle:nil otherButtonTitles:@[@"Okay"] handler:^(TPAlertViewHandlerParams *const params) {
                         if (params.handlerType == TPAlertViewTappedButton) {
                             if ([params.buttonTitle isEqualToString:@"Okay"]) {
                                 [SWLogger logEventWithObject:self selector:_cmd];
                                 [appState saveCurrentPlaylistAndSongInfoForUserId:appState.currentUser.userId];
                                 // Stop receiving remote control events
                                 [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
                                 // Terminate player VC.  (stops playing.. yadda yadda )
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [SVProgressHUD showWithStatus:@"Logging Out" maskType:SVProgressHUDMaskTypeGradient];
                                 });
                                 
                                 if (appState.currentPlayerViewController) {
                                     [appState.currentPlayerViewController cleanUpPlayer_AndCompletionHandler:^(bool success) {
                                         [[SWAPI sharedAPI] logOutWithCompletion:^(BOOL success, NSError *error) {
                                             appState.currentPlayerViewController = nil;
                                             if (success) {
                                                 [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [SVProgressHUD dismiss];
                                                     [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
                                                     appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                                                     appDelegate.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainRootViewController"];
                                                     [appDelegate.window makeKeyAndVisible];
                                                 });
                                             }
                                         }];
                                     }];
                                 }
                                 else {
                                     [[SWAPI sharedAPI] logOutWithCompletion:^(BOOL success, NSError *error) {
                                         appState.currentPlayerViewController=nil;
                                         if (success) {
                                             [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [SVProgressHUD dismiss];
                                                 [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
                                                 appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                                                 appDelegate.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainRootViewController"];
                                                 [appDelegate.window makeKeyAndVisible];
                                             });
                                         }
                                     }];
                                 }
                             }
                         }
                         else {
//                             [SVProgressHUD dismiss];
//                             [UIAlertView showWithMessage:@"Plan Purchase is not succesfully Please try again." cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
//                             
//                             }];
                         }
                 }];
             
         }
         else {
             [SVProgressHUD dismiss];
             [SWLogger logEvent:[NSString stringWithFormat:@"Error on Forgot Password request finish: %@", error]];
             [UIAlertView showWithMessage:error.localizedDescription handler:^(TPAlertViewHandlerParams *const params) {
             
             }];
         }
    }];
}

@end
