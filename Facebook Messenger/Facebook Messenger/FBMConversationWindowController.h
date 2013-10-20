//
//  FBMConversationWindowController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FBConversation;

@interface FBMConversationWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

{
    NSMutableArray *_conversationComments;
    
    NSDate *_lastNetRefresh;
}

@property FBConversation *conversation;

@property (weak) IBOutlet NSTableView *tableView;

-(void)refreshConversationFromNetWithErrorAlert:(BOOL)errorAlert;

-(void)refreshConversationFromCache;

#pragma mark - First Responder

-(IBAction)newDocument:(id)sender;

-(IBAction)delete:(id)sender;

#pragma mark - Actions

-(IBAction)clickedRow:(id)sender;

#pragma mark - Change GUI

-(void)updateWindowTitle;


@end
