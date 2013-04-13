//
//  FacebookStore.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 4/13/13.
//  Copyright (c) 2013 ColemanCDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface FacebookStore : NSObject
{
    // Account Store
    ACAccountStore *_accountStore;
    
}

+ (FacebookStore *)sharedStore;

#pragma mark - Properties

@property (readonly) BOOL isFacebookAccountSetup;

#pragma mark - Request Access to Accounts

-(void)fetchFacebookAccountsWithCompletion:(void (^) (NSArray *accounts, NSError *error))completionBlock;

-(void)fetchSelectedFacebookAccountWithCompletion:(void (^) (ACAccount *account, NSError *error))completionBlock;

#pragma mark



@end
