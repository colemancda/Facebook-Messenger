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
#import "FBMAppDelegate.h"
#import "FBUser+Jabber.h"

@interface FBMConversationWindowController ()

@end

@implementation FBMConversationWindowController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    
    // setup notifications
    
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sentMessage:)
                                                 name:FBMAPISentMessageNotification
                                               object:appDelegate.store];
    
    [self updateWindowTitle];
    
    self.arrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES]];
    
    self.arrayController.fetchPredicate = [NSPredicate predicateWithFormat:@"conversation == %@", self.conversation];
}

#pragma mark - Actions

-(void)enteredText:(NSTextField *)sender
{
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    // user to send to...
    
    FBUser *toUser = self.conversation.to.allObjects.firstObject;
    
    [appDelegate.store sendMessage:sender.stringValue
                     toUserWithJID:toUser.jid];
    
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
    if (self.tableView.numberOfRows > 2) {
        
        [self.tableView scrollRowToVisible:self.tableView.numberOfRows - 1];
    }
}

#pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView
  viewForTableColumn:(NSTableColumn *)tableColumn
                 row:(NSInteger)row
{
    FBMessageCellView *messageCellView = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                                     owner:self];
    
    // get model object
    FBConversationComment *comment = self.arrayController.arrangedObjects[row];
    
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
    
    // scroll to bottom if last row and is hidden
    
    if (row == tableView.numberOfRows - 1) {
        
        [self scrollToBottomOfTableView];
    }
    
    return messageCellView;
}

-(CGFloat)tableView:(NSTableView *)tableView
        heightOfRow:(NSInteger)row
{
    
    return 80;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return NO;
}

#pragma mark - NSWindowDelegate

-(void)windowDidResize:(NSNotification *)notification
{
    // automatically resize column
    
    NSTableColumn *column = self.tableView.tableColumns.firstObject;
    
    column.maxWidth = self.window.frame.size.width;
    
    column.width = self.window.frame.size.width;
}

#pragma mark - Notifications

-(void)sentMessage:(NSNotification *)notification
{
    NSError *error = notification.userInfo[FBMErrorDomain];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (error) {
            
            [NSApp presentError:error
                 modalForWindow:self.window
                       delegate:nil
             didPresentSelector:nil
                    contextInfo:nil];

            
            return;
        }
        
        // clear text
        
        if ([self.textField.stringValue isEqualToString:notification.userInfo[FBMAPIMessageKey]]) {
            
            self.textField.stringValue = @"";
        }
        
    }];
}

@end
