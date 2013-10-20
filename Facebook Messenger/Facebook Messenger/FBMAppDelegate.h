//
//  FBMAppDelegate.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FBMStore, FBMInboxWindowController;

extern NSString *const FBMAppID;

@interface FBMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly) FBMStore *store;

-(void)attemptToLogin:(void (^)(BOOL loggedIn))completionBlock;

#pragma mark - Window Controllers

@property (readonly) FBMInboxWindowController *inboxWC;

#pragma mark - GUI

@property (weak) IBOutlet NSBox *failureBox;

@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

#pragma mark - Actions

- (IBAction)login:(id)sender;


@end
