//
//  FBMAppDelegate.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FBMStore.h"
@class FBMStore, FBMInboxWindowController;

@interface FBMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, readonly) FBMStore *store;

#pragma mark - In-App Purchases

@property (readonly, nonatomic) BOOL photosPurchased;

#pragma mark - Window Controllers

@property (nonatomic, readonly) FBMInboxWindowController *inboxWC;

#pragma mark - GUI

@property (weak) IBOutlet NSBox *failureBox;

@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

#pragma mark - Actions

- (IBAction)login:(id)sender;


@end
