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
#import "FBMPurchasesStore.h"
#import "MASPreferencesWindowController.h"
#import "FBMPurchasesViewController.h"

@interface FBMAppDelegate ()

@property (nonatomic) MASPreferencesWindowController *preferencesWC;

@end

@implementation FBMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    _store = [[FBMStore alloc] initWithAppID:@"700580906649633"];
    
    // purchases
    
    _purchasesStore = [[FBMPurchasesStore alloc] init];
    
    // register for notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishAuthentication:)
                                                 name:FBMAPIFinishedAuthenticationNotification
                                               object:_store];
    
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
    
    NSLog(@"Requesting access to FB account...");
    
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
        
        NSLog(@"Connecting using '%@' account", _store.facebookAccount.username);
        
        [self.store connectToXMPPServer];
        
    }];
    
}

-(void)openPreferences:(id)sender
{
    if (!self.preferencesWC) {
        
        NSString *title = NSLocalizedString(@"Preferences", @"Preferences Pane Title");
        
        NSArray *viewControllers = @[];
        
        if ([SKPaymentQueue canMakePayments]) {
            
            FBMPurchasesViewController *purchasesVC = [[FBMPurchasesViewController alloc] init];
            
            viewControllers = [viewControllers arrayByAddingObject:purchasesVC];
        }
        
        self.preferencesWC = [[MASPreferencesWindowController alloc] initWithViewControllers:viewControllers
                                                                                       title:title];
    }
    
    [self.preferencesWC.window makeKeyAndOrderFront:self];
}

#pragma mark - First Responder

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(newDocument:)) {
        
        return (BOOL)self.store.user;
    }
    
    return YES;
}

-(void)newDocument:(id)sender
{
    [self.inboxWC newDocument:sender];
}

#pragma mark - Notifications

-(void)didFinishAuthentication:(NSNotification *)notification
{
    NSError *error = notification.userInfo[FBMAPIErrorKey];
    
    NSBlockOperation *errorBlock = [NSBlockOperation blockOperationWithBlock:^{
        
        [_failureBox setHidden:NO];
        
        [_progressIndicator setHidden:YES];
        
        [_progressIndicator stopAnimation:self];
        
        [NSApp presentError:error];
        
    }];
    
    if (error) {
        
        [[NSOperationQueue mainQueue] addOperation:errorBlock];
        
        return;
    }
    
    NSLog(@"Successfully connected to XMPP server");
    
    // fetch inbox from server
    
    [self.store fetchInboxWithCompletionBlock:^(NSError *error, NSArray *inbox) {
        
        if (error) {
            
            [[NSOperationQueue mainQueue] addOperation:errorBlock];
            
            return;
        }
        
        // fetch friends list
        
        [self.store fetchFriendList:^(NSError *error, NSArray *friends) {
            
            if (error) {
                
                [[NSOperationQueue mainQueue] addOperation:errorBlock];
                
                return;
            }
            
            // fetch user profile
            
            [self.store fetchUserWithCompletionBlock:^(NSError *error, NSDictionary *userProfile) {
                
                if (error) {
                    
                    [[NSOperationQueue mainQueue] addOperation:errorBlock];
                    
                    return;
                }
               
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    // close this window and show InboxWC
                    
                    if (!_inboxWC) {
                        
                        _inboxWC = [[FBMInboxWindowController alloc] init];
                    }
                    
                    [_inboxWC.window makeKeyAndOrderFront:self];
                    
                    [self.window close];
                    
                }];
                
            }];
            
        }];
        
    }];
}

@end
