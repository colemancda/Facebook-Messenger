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
    
    // GUI
    
    [_failureBox setHidden:YES];
    
    [_progressIndicator setHidden:NO];
    
    [self attemptToLogin:^(BOOL loggedIn) {
       
        // load inbox
        [_store requestInboxWithCompletionBlock:^(NSError *error) {
           
            if (error) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                   
                    [NSApp presentError:error];
                    
                }];
                
                return;
            }
            
            NSLog(@"Got Inbox");
            
        }];
    }];
}

-(void)attemptToLogin:(void (^)(BOOL))completionBlock
{
    // GUI
    
    [_failureBox setHidden:YES];
    
    [_progressIndicator setHidden:NO];
    
    [_progressIndicator startAnimation:self];
    
    // always request access to accounts
    
    NSLog(@"Requesting access to FB accounts...");
    
    [_store requestAccessToUserAccountsUsingAppID:FBMAppID completionBlock:^(BOOL success) {
        
        if (!success) {
            
            NSLog(@"Access to account denied");
            
            // GUI
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               
                [_failureBox setHidden:NO];
                
                [_progressIndicator setHidden:YES];
                
                [_progressIndicator startAnimation:self];
                
            }];
            
            completionBlock(NO);
            
            return;
        }
        
        NSLog(@"Using '%@' account", _store.facebookAccount.username);
        
        completionBlock(YES);
        
    }];
}

#pragma mark - Actions

- (IBAction)login:(id)sender {
    
    
}
@end
