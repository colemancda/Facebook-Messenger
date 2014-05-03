//
//  FBMPurchasesStore.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import "FBMPurchasesStore.h"

NSString *const FBMPhotosProductID = @"com.ColemanCDA.Facebook-Messenger.photos";

@interface FBMPurchasesStore ()

@property (nonatomic) BOOL photosPurchased;

@property NSArray *availibleProducts;

@end

@implementation FBMPurchasesStore

#pragma mark - Requests

-(void)verifyProducts
{
    NSArray *productIDs = @[FBMPhotosProductID];
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIDs]];
    
    [productsRequest start];
}

#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.availibleProducts = response.products;
    
}

#pragma mark - SKRequestDelegate

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@ failed (%@)", request, error);
}

@end
