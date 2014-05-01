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
    
    // sort descriptor
    self.arrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedTime"
                                                                           ascending:NO]];
    
    // fetch from server
    
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    [appDelegate.store fetchInboxWithCompletionBlock:^(NSError *error, NSArray *inbox) {
       
        if (error) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               
                [NSApp presentError:error];
                
            }];
            
            return;
        }
        
    }];
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
    FBConversation *conversation = self.arrayController.arrangedObjects[row];
    
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

#pragma mark - First Responder

-(void)newDocument:(id)sender
{
    
    
}

#pragma mark - Actions

-(void)clickedRow:(id)sender
{
    if (self.tableView.clickedRow == -1) {
        
        return;
    }
    
    // get model object
    FBConversation *conversation = self.arrayController.arrangedObjects[self.tableView.clickedRow];
    
    if (!_conversationWCs) {
        _conversationWCs = [[NSMutableDictionary alloc] init];
    }
    
    // search for existing WC for this conversation
    NSNumber *conversationID = conversation.id;
    
    FBMConversationWindowController *conversationWC = _conversationWCs[conversationID];
    
    if (!conversationWC) {
        
        conversationWC = [[FBMConversationWindowController alloc] init];
        
        [_conversationWCs setObject:conversationWC
                             forKey:conversationID];
        
        // set model object
        
        conversationWC.conversation = conversation;
        
    }
    
    // update GUI
    
    [conversationWC.window makeKeyAndOrderFront:self];
}


@end
