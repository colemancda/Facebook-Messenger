//
//  FBMConversationWindowController.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "FBMConversationWindowController.h"
#import "FBConversation.h"
#import "FBConversationComment.h"
#import "FBUser.h"
#import "FBMessageCellView.h"

@interface FBMConversationWindowController ()

@end

@implementation FBMConversationWindowController

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
    
}

#pragma mark - Refresh

-(void)refreshConversationFromCache
{
    // sort array
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdTime"
                                                           ascending:YES];
    
    _conversationComments = [NSMutableArray arrayWithArray:[_conversation.comments sortedArrayUsingDescriptors:@[sort]]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.tableView reloadData];
        
        [self scrollToBottomOfTableView];
        
    }];
}

-(void)refreshConversationFromNetWithErrorAlert:(BOOL)errorAlert
{
    
    
}

#pragma mark - GUI

-(void)updateWindowTitle
{
    // build string
    
    NSArray *toArray = self.conversation.to.allObjects;
    
    NSString *toString = @"";
    for (FBUser *user in toArray) {
        
        toString = [toString stringByAppendingString:user.name];
        
        if (user != toArray.lastObject) {
            
            toString = [toString stringByAppendingString:@", "];
        }
    }
    
    self.window.title = toString;
}

-(void)scrollToBottomOfTableView
{
    [self.tableView scrollRowToVisible:self.tableView.numberOfRows - 1];
}

#pragma mark - NSWindowDelegate

-(void)windowDidBecomeKey:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self updateWindowTitle];
        
        [self refreshConversationFromCache];
        
    }];
}

#pragma mark - NSTableView Datasource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _conversationComments.count;
}

#pragma mark - NSTable Delegate

-(NSView *)tableView:(NSTableView *)tableView
  viewForTableColumn:(NSTableColumn *)tableColumn
                 row:(NSInteger)row
{
    FBMessageCellView *messageCellView = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                                     owner:self];
    
    // get model object
    FBConversationComment *comment = _conversationComments[row];
    
    // set text fields
    messageCellView.textField.stringValue = comment.message;
    
    messageCellView.nameField.stringValue = comment.from.name;
    
    // set date...
    if (!_dateFormatter) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        
    }
    
    messageCellView.dateField.stringValue = [_dateFormatter stringFromDate:comment.createdTime];
    
    return messageCellView;
}

-(CGFloat)tableView:(NSTableView *)tableView
        heightOfRow:(NSInteger)row
{
    
    return 80;
}


@end
