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
    
    [self login:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag
{
    if (self.store.facebookAccount) {
        
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

#pragma mark - Actions

- (IBAction)login:(id)sender {
    
    [self.store requestAccessToFBAccount:^(NSError *error) {
       
        if (error) {
            
            // GUI
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [_failureBox setHidden:NO];
                
                [_progressIndicator setHidden:YES];
                
                [_progressIndicator stopAnimation:self];
                
                [NSApp presentError:error];
                
            }];
            
            return;
        }
        
        NSLog(@"Using '%@' account", _store.facebookAccount.username);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            // close this window and show InboxWC
            
            if (!_inboxWC) {
                
                _inboxWC = [[FBMInboxWindowController alloc] init];
            }
            
            [_inboxWC.window makeKeyAndOrderFront:self];
            
            [self.window close];
            
        }];
        
    }];
    
}


@end
