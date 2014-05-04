//
//  FBMPurchasesStore.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;

extern NSString *const FBMPurchasesStoreProductsRequestFailed;

extern NSString *const FBMPurchasesStoreErrorKey;

// Product IDs

extern NSString *const FBMPicturesProductID;

@interface FBMPurchasesStore : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSMutableDictionary *_purchasedProducts;
    
}

#pragma mark - Requests

-(void)verifyProducts;

-(void)purchaseProduct:(SKProduct *)product;

-(void)restorePurchases;

#pragma mark - Cache

-(BOOL)purchasedProductWithProductID:(NSString *)productID;

#pragma mark - In-App Purchases

@property (readonly, nonatomic) NSArray *availibleProducts;

@end
