//
//  FBMConversationWindowController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FBConversation;

@interface FBMConversationWindowController : NSWindowController <NSTableViewDelegate>
{
    NSDate *_lastNetRefresh;
    
    NSDateFormatter *_dateFormatter;
}

#pragma mark - Represented Object

@property FBConversation *conversation;

#pragma mark - IB Outlets

@property (weak) IBOutlet NSTableView *tableView;

@property (strong) IBOutlet NSArrayController *arrayController;

#pragma mark - Actions

-(IBAction)enteredText:(NSTextField *)sender;

#pragma mark - Change GUI

-(void)updateWindowTitle;

-(void)scrollToBottomOfTableView;


@end
