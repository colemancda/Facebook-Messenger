//
//  FBMAPI.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 12/29/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "FBMAPI.h"

NSString *const FBMAppID = @"221240951333308";

@implementation FBMAPI

- (id)init
{
    self = [super init];
    if (self) {
        
        _accountStore = [[ACAccountStore alloc] init];
        
    }
    return self;
}

#pragma mark - Authenticate

-(void)requestAccessToFBAccount:(void (^)(BOOL))completionBlock
{
    NSArray *fbPermissions = @[@"read_mailbox",
                               @"friends_online_presence",
                               @"user_about_me",
                               @"user_online_presence",
                               @"xmpp_login"];
    
    NSDictionary *accessOptions = @{ACFacebookAppIdKey: FBMAppID,
                                    ACFacebookPermissionsKey : fbPermissions};
    
    
    ACAccountType *fbAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // request access to accounts
    
    [_accountStore requestAccessToAccountsWithType:fbAccountType options:accessOptions completion:^(BOOL granted, NSError *error) {
        
        // access denied
        if (!granted) {
            
            completionBlock(NO);
            return;
        }
        
        NSArray *accounts = [_accountStore accountsWithAccountType:fbAccountType];
        
        // account exists but is not enabled
        if (!accounts.count) {
            
            completionBlock(NO);
            return;
        }
        
        // can only have one FB account in OS X
        
        ACAccount *facebookAccount = accounts[0];
        
        // renew credentials
        [_accountStore renewCredentialsForAccount:facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
            
            if (renewResult != ACAccountCredentialRenewResultRenewed) {
                
                completionBlock(NO);
                
                return;
            }
            
            // store account
            _facebookAccount = facebookAccount;
            
            completionBlock(YES);
        }];
    }];
}

#pragma mark - Request



@end
