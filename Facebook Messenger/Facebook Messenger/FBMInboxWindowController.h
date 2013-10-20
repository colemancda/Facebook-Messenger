//
//  FBMInboxWindowController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FBMInboxWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>
{
    NSMutableArray *_conversations;
    
    NSDateFormatter *_dateFormatter;
    
    NSMutableDictionary *_conversationWCs;
    
    NSDate *_lastNetRefresh;
}

@property (weak) IBOutlet NSTableView *tableView;

-(void)refreshConversationsFromNetWithErrorAlert:(BOOL)errorAlert;

-(void)refreshConversationsFromCache;

#pragma mark - First Responder

-(IBAction)newDocument:(id)sender;

-(IBAction)delete:(id)sender;

#pragma mark - Actions

-(IBAction)clickedRow:(id)sender;

@end
