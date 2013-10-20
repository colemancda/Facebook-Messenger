//
//  FBMAppDelegate.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "FBMAppDelegate.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "FBMStore.h"

NSString *const FBMAppID = @"221240951333308";

@implementation FBMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    _store = [[FBMStore alloc] init];
    
    [self attemptToLogin:^(BOOL loggedIn) {
       
        
        
    }];
}

-(void)attemptToLogin:(void (^)(BOOL))completionBlock
{
    // always request access to accounts
    
    NSLog(@"Requesting access to FB accounts...");
    
    [_store requestAccessToUserAccountsUsingAppID:FBMAppID completionBlock:^(BOOL success) {
        
        if (!success) {
            
            NSLog(@"Access to account denied");
            
            completionBlock(NO);
            
            return;
        }
        
        
        NSLog(@"Using '%@' account", _store.facebookAccount.username);
        
        completionBlock(YES);
        
    }];
}

@end
