//
//  FBMInboxWindowController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FBMInboxWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
    NSMutableArray *_conversations;
    
    NSDateFormatter *_dateFormatter;
}

@property (weak) IBOutlet NSTableView *tableView;

-(void)refreshConversationsFromNet;

-(void)refreshConversationsFromCache;

#pragma mark - First Responder

-(IBAction)newDocument:(id)sender;

-(IBAction)delete:(id)sender;

#pragma mark



@end
