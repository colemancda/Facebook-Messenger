//
//  FBMAppDelegate.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

@import Social;
@import Accounts;
#import "FBMAppDelegate.h"
#import "FBMStore.h"
#import "FBMInboxWindowController.h"
#import "FBMAPI.h"

@implementation FBMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    _store = [[FBMStore alloc] initWithAppID:@"221240951333308"];
    
    // GUI
    
    [_failureBox setHidden:YES];
    
    [_progressIndicator setHidden:NO];
    
    [_progressIndicator startAnimation:self];
    
    [self attemptToLogin:^(BOOL loggedIn) {
        
       
    }];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag
{
    if (self.store.api.facebookAccount) {
        
        // reopen inbox window
        [_inboxWC.window makeKeyAndOrderFront:self];
        
        return YES;
    }
    
    if ( flag ) {
        [self.window orderFront:self];
    }
    else {
        [self.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}

-(void)attemptToLogin:(void (^)(BOOL))completionBlock
{
    // always request access to accounts
    
    NSLog(@"Requesting access to FB accounts...");
    
    [_store.api requestAccessToFBAccount:^(BOOL success) {
        
        if (!success) {
            
            NSLog(@"Access to account denied");
            
            // GUI
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               
                [_failureBox setHidden:NO];
                
                [_progressIndicator setHidden:YES];
                
                [_progressIndicator stopAnimation:self];
                
            }];
            
            completionBlock(NO);
            
            return;
        }
        
        NSLog(@"Using '%@' account", _store.api.facebookAccount.username);
        
        // download inbx before showing window
        
        FBMAppDelegate *appDelegate = [NSApp delegate];
        
        /*
        
        [appDelegate.store requestInboxWithCompletionBlock:^(NSError *error) {
            
            if (error) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [NSApp presentError:error];
                    
                }];
                
                return;
            }
            
            NSLog(@"Got Inbox");
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               
                // close this window and show InboxWC
                
                if (!_inboxWC) {
                    
                    _inboxWC = [[FBMInboxWindowController alloc] init];
                }
                
                [_inboxWC.window makeKeyAndOrderFront:self];
                
                [self.window close];
                
                completionBlock(YES);
                
            }];
            
        }];
         
         */
    }];
}

#pragma mark - Actions

- (IBAction)login:(id)sender {
    
    [self attemptToLogin:^(BOOL loggedIn) {
       
        
        
    }];
    
}


@end
