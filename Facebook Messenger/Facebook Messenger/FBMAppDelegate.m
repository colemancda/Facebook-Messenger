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

NSString *const SavedFBAccountIdentifierPreferenceKey = @"SavedFBAccountIdentifier";

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
    // success block
    void (^successCompletionBlock) (void) = ^{
        
        NSLog(@"Using '%@' account", _store.facebookAccount.username);
        
        completionBlock(YES);
    };
    
    // always request access to accounts
    
    NSLog(@"Requesting access to FB accounts...");
    
    [_store requestAccessToUserAccountsUsingAppID:FBMAppID completionBlock:^(NSError *error) {
        
        if (error) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [NSApp presentError:error];
                
                completionBlock(NO);
                
            }];
            
            return;
        }
        
        // either load saved account or select one to use
        
        NSString *savedIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:SavedFBAccountIdentifierPreferenceKey];
        
        BOOL restoredAccount = NO;
        
        if (savedIdentifier) {
            
            restoredAccount = [_store selectAccountUsingIdentitfier:savedIdentifier];
        }
        
        if (restoredAccount) {
            
            successCompletionBlock();
            
            return;
        }
        
        // couldn't restore account, now lets try to select one using the GUI
        
        NSLog(@"Selecting account to use...");
        
        [_store selectAccountUsingWindow:self.window completionBlock:^(BOOL success) {
            
            if (error) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [NSApp presentError:error];
                    
                    completionBlock(NO);
                    
                }];
                
                return;
            }
            
            // save selected account
            
            [[NSUserDefaults standardUserDefaults] setObject:_store.facebookAccount.identifier
                                                      forKey:SavedFBAccountIdentifierPreferenceKey];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            successCompletionBlock();
            
        }];
        
    }];
}

@end
