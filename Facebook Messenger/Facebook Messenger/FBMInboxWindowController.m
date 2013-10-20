//
//  FBMInboxWindowController.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "FBMInboxWindowController.h"
#import "FBMAppDelegate.h"
#import "FBMStore.h"
#import "FBConversation.h"
#import "FBUser.h"
#import "FBMConversationWindowController.h"

@interface FBMInboxWindowController ()

@end

@implementation FBMInboxWindowController

-(id)init
{
    self = [self initWithWindowNibName:NSStringFromClass(self.class)
                                 owner:self];
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    // set tableview action
    [self.tableView setDoubleAction:@selector(clickedRow:)];
    self.tableView.target = self;
    
    // load from cache
    [self refreshConversationsFromCache];
}

#pragma mark - Refresh

-(void)refreshConversationsFromCache
{
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    [appDelegate.store.context performBlockAndWait:^{
       
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FBConversation"];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedTime"
                                                                         ascending:NO];
        
        fetch.sortDescriptors = @[sortDescriptor];
        
        NSError *fetchError;
        
        NSArray *result = [appDelegate.store.context executeFetchRequest:fetch
                                                                   error:&fetchError];
        
        if (!result) {
            
            [NSException raise:@"Error Executing Core Data NSFetchRequest"
                        format:@"%@", fetchError.localizedDescription];
            
            return;
        }
        
        _conversations = [[NSMutableArray alloc] initWithArray:result];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           
            [self.tableView reloadData];
            
        }];
    }];
}

-(void)refreshConversationsFromNet
{
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    [appDelegate.store requestInboxWithCompletionBlock:^(NSError *error) {
       
        if (error) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [NSApp presentError:error];
            }];
            
            return;
        }
        
        [self refreshConversationsFromCache];
        
    }];
}

#pragma mark - NSTableView DataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _conversations.count;
}

#pragma mark - NSTableView Delegate

-(NSView *)tableView:(NSTableView *)tableView
  viewForTableColumn:(NSTableColumn *)tableColumn
                 row:(NSInteger)row
{
    NSString *identifier = tableColumn.identifier;
    
    NSTableCellView *cellView = [self.tableView makeViewWithIdentifier:identifier
                                                                 owner:self];
    
    // get model object
    FBConversation *conversation = _conversations[row];
    
    if ([identifier isEqualToString:@"updatedTime"]) {
        
        if (!_dateFormatter) {
            
            _dateFormatter = [[NSDateFormatter alloc] init];
            _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        }
        
        // set date text
        cellView.textField.stringValue = [_dateFormatter stringFromDate:conversation.updatedTime];
        
    }
    
    if ([identifier isEqualToString:@"to"]) {
        
        // build string
        
        NSArray *toArray = conversation.to.allObjects;
        
        NSString *toString = @"";
        for (FBUser *user in toArray) {
            
            toString = [toString stringByAppendingString:user.name];
            
            if (user != toArray.lastObject) {
                
                toString = [toString stringByAppendingString:@", "];
            }
        }
        
        // set text
        cellView.textField.stringValue = toString;
    }
    
    // check whether the conversation has unread messages
    if (conversation.unread.boolValue ||
        conversation.unseen.boolValue) {
        
        [cellView setBackgroundStyle:NSBackgroundStyleDark];
        
    }
    
    
    return cellView;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    
    
}

#pragma mark - Actions

-(void)clickedRow:(id)sender
{
    // get model object
    FBConversation *conversation = _conversations[self.tableView.clickedRow];
    
    if (!_conversationWCs) {
        _conversationWCs = [[NSMutableDictionary alloc] init];
    }
    
    // search for existing WC for this conversation
    NSNumber *conversationID = conversation.id;
    
    FBMConversationWindowController *conversationWC = _conversationWCs[conversationID];
    
    if (!conversationWC) {
        
        [_conversationWCs setObject:[[FBMConversationWindowController alloc] init]
                             forKey:conversationID];
    }
    
    [conversationWC.window makeKeyAndOrderFront:self];
}


@end
