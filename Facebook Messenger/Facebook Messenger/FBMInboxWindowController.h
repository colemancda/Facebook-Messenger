//
//  FBMInboxWindowController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FBUser, FBConversation, FBMDirectoryWindowController;

@interface FBMInboxWindowController : NSWindowController <NSTableViewDelegate>
{
    NSDateFormatter *_dateFormatter;
    
    NSMutableDictionary *_conversationWCs;
}

#pragma mark - IB Outlets

@property (weak) IBOutlet NSTableView *tableView;

@property (strong) IBOutlet NSArrayController *arrayController;

#pragma mark - Properties

@property (nonatomic, readonly) FBMDirectoryWindowController *directoryWC;

#pragma mark - First Responder

-(IBAction)newDocument:(id)sender;

#pragma mark - Actions

-(IBAction)clickedRow:(id)sender;

-(void)newConversationWithUser:(FBUser *)user;

#pragma mark - GUI

-(void)presentNotificationForNewMessage:(NSString *)newMessage
                         inConversation:(FBConversation *)conversation;

#pragma mark - Notifications

-(void)recievedMessage:(NSNotification *)notification;

@end
