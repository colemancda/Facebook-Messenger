//
//  FBMAppDelegate.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FBMStore.h"
@class FBMStore, FBMPurchasesStore, FBMInboxWindowController;

@interface FBMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, readonly) FBMStore *store;

@property (nonatomic, readonly) FBMPurchasesStore *purchasesStore;

#pragma mark - Window Controllers

@property (nonatomic, readonly) FBMInboxWindowController *inboxWC;

#pragma mark - GUI

@property (weak) IBOutlet NSBox *failureBox;

@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

#pragma mark - Actions

- (IBAction)login:(id)sender;


@end
