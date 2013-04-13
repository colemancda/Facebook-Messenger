//
//  FacebookStore.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 4/13/13.
//  Copyright (c) 2013 ColemanCDA. All rights reserved.
//

#import "FacebookStore.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"

// app ID
const NSString *kFacebookAppID = @"317725598329762";

// asking ACAccountStore for Account
const NSInteger kErrorCodeFacebookNoAccountSetup = 401;
const NSInteger kErrorCodeFacebookAccountAccessDenied = 402;

@implementation FacebookStore

+ (FacebookStore *)sharedStore
{
    static FacebookStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        _accountStore = [[ACAccountStore alloc] init];
        
    }
    return self;
}

#pragma mark - Properties

-(BOOL)isFacebookAccountSetup
{
    NSSharingService *facebookSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
    
    return [facebookSharingService canPerformWithItems:nil];
    
}

#pragma mark - Request Access to Accounts

-(void)fetchFacebookAccountsWithCompletion:(void (^)(NSArray *, NSError *))completionBlock
{
    // if no completion block was provided, end method
    if (!completionBlock) {
        return;
    }
    
    NSLog(@"Fetching Facebook accounts...");
    
    // if at least one account is not setup, then exit
    if (!self.isFacebookAccountSetup) {
        
        NSString *errorDescription = NSLocalizedString(@"Error fetching Facebook accounts. No Facebook account was setup in Settings", @"Error fetching Facebook accounts. No Facebook account was setup in Settings");
        
        NSError *error = [NSError errorWithDomain:kErrorDomain
                                             code:kErrorCodeFacebookNoAccountSetup
                                         userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
        
        completionBlock(nil, error);
        return;
    }
    
    // get the account type
    ACAccountType *facebookAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // request access to accounts
    NSDictionary *requestAccountAccessOptions = @{ACFacebookAppIdKey: kFacebookAppID};
    
    [_accountStore requestAccessToAccountsWithType:facebookAccountType
                                           options:requestAccountAccessOptions
                                        completion:^(BOOL granted, NSError *error)
     {
         // if access is denied
         if (!granted) {
             
             NSString *errorDescription = NSLocalizedString(@"Access to your Facebook accounts was denied", @"Access to your Facebook accounts was denied");
             
             NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
             
             NSError *grantedError = [NSError errorWithDomain:kErrorDomain
                                                         code:kErrorCodeFacebookAccountAccessDenied
                                                     userInfo:userInfo];
             
             completionBlock(nil, grantedError);
         }
         
         
     }];
}

@end
