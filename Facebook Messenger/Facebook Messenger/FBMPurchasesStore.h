//
//  FBMPurchasesStore.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;

@interface FBMPurchasesStore : NSObject <SKProductsRequestDelegate>

#pragma mark - Requests

-(void)verifyProducts;

#pragma mark - In-App Purchases

@property (readonly) NSArray *availibleProducts;

@property (readonly, nonatomic) BOOL photosPurchased;

@end
