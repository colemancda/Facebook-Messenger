//
//  FBMDirectoryWindowController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FBMInboxWindowController;

@interface FBMDirectoryWindowController : NSWindowController <NSTableViewDelegate>

#pragma mark - IB Outlets

@property (weak) IBOutlet NSTableView *tableView;

@property (strong) IBOutlet NSArrayController *arrayController;

#pragma mark - Properties

@property (nonatomic) FBMInboxWindowController *inboxWC;

#pragma mark - Actions

-(void)doubleClickedTableView:(id)sender;

#pragma mark - Notifications

-(void)userPresenceUpdated:(NSNotification *)notification;

@end
