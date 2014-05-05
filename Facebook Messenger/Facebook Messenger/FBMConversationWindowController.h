//
//  FBMConversationWindowController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FBConversation, FBUser;

@interface FBMConversationWindowController : NSWindowController <NSTableViewDelegate, NSWindowDelegate>
{
    NSDate *_lastNetRefresh;
    
    NSDateFormatter *_dateFormatter;
}

#pragma mark - Represented Object

@property FBConversation *conversation;

#pragma mark - IB Outlets

@property (weak) IBOutlet NSScrollView *tableViewScrollView;

@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSTextField *textField;

@property (strong) IBOutlet NSArrayController *arrayController;

@property (weak) IBOutlet NSToolbarItem *userProfileToolbarItem;

#pragma mark - Properties

@property (nonatomic, readonly) NSArray *conversationDataSourceArray;

@property (nonatomic, readonly) FBUser *toUser;

#pragma mark - Actions

-(IBAction)enteredText:(NSTextField *)sender;

-(IBAction)showUserProfile:(NSToolbarItem *)sender;

#pragma mark - Change GUI

-(void)scrollToBottomOfTableView;

#pragma mark - Notifications

-(void)sentMessage:(NSNotification *)notification;

-(void)recievedMessage:(NSNotification *)notification;

@end
