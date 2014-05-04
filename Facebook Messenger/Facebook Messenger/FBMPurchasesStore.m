//
//  FBMPurchasesStore.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import "FBMPurchasesStore.h"

NSString *const FBMPurchasesStoreProductsRequestFailedNotification = @"FBMPurchasesStoreProductsRequestFailedNotification";

NSString *const FBMPurchasesStoreErrorKey = @"FBMPurchasesStoreErrorKey";

// product ids

NSString *const FBMPicturesProductID = @"com.ColemanCDA.FacebookMessenger.pictures";

@interface FBMPurchasesStore ()

@property (nonatomic) NSArray *availibleProducts;

@end

@implementation FBMPurchasesStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // delegate
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
}

#pragma mark - Requests

-(void)verifyProducts
{
    // products request
    
    NSArray *productIDs = @[FBMPicturesProductID];
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIDs]];
    
    productsRequest.delegate = self;
    
    NSLog(@"Verifying products...");
    
    [productsRequest start];
}

-(void)purchaseProduct:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void)restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - Cache

-(BOOL)purchasedProductWithProductID:(NSString *)productID
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:productID];
}

#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        self.availibleProducts = response.products;
    }];
    
    NSLog(@"Products successfully verified %@", response.products);
}

#pragma mark - SKRequestDelegate

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if ([request isKindOfClass:[SKProductsRequest class]]) {
        
        NSLog(@"Product verification failed. (%@)", error);
        
        // notify
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FBMPurchasesStoreProductsRequestFailedNotification
                                                            object:self
                                                          userInfo:@{FBMPurchasesStoreErrorKey: error}];
        
        return;
    }
    
    NSLog(@"%@ Failed with error. (%@)", request, error);
}

#pragma mark - SKPaymentTransactionObserver

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
    
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    
}

@end
