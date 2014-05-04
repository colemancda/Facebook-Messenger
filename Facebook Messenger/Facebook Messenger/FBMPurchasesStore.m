//
//  FBMPurchasesStore.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import "FBMPurchasesStore.h"

NSString *const FBMPhotoProductID = @"com.ColemanCDA.FacebookMessenger.photos";

@interface FBMPurchasesStore ()

@property (nonatomic) BOOL photosPurchased;

@property NSArray *availibleProducts;

@property SKProductsRequest *productsRequest;

@end

@implementation FBMPurchasesStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // TEMP
        
        NSArray *productIDs = @[FBMPhotoProductID];
        
        self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIDs]];
        
        self.productsRequest.delegate = self;
        
    }
    return self;
}

#pragma mark - Requests

-(void)verifyProducts
{
    NSLog(@"Verifying products...");
    
    [self.productsRequest start];
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
    NSLog(@"Product verification failed. (%@)", error);
    
    // notify
    
    
}

@end
