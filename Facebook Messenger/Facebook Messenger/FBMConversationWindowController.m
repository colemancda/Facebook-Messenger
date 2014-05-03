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
#import "FBConversation+Info.h"

static void *KVOContext = &KVOContext;

NSString *const ConversationNameKeyPath = @"conversation.to";

@interface FBMConversationWindowController ()

@end

@implementation FBMConversationWindowController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObserver:self forKeyPath:ConversationNameKeyPath];
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
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedMessage:)
                                                 name:FBMAPIRecievedMessageNotification
                                               object:appDelegate.store];
    
    // KVO
    
    [self addObserver:self
           forKeyPath:ConversationNameKeyPath
              options:NSKeyValueObservingOptionNew
              context:KVOContext];
    
    self.arrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES]];
    
    self.arrayController.fetchPredicate = [NSPredicate predicateWithFormat:@"conversation == %@", self.conversation];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self scrollToBottomOfTableView];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOContext) {
        
        if ([keyPath isEqualToString:ConversationNameKeyPath]) {
            
            if (self.conversation) {
                
                NSString *toString = self.conversation.toString;
                
                if (![self.window.title isEqualToString:toString]) {
                    
                    self.window.title = toString;
                }
                
            }
            
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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

- (IBAction)showUserProfile:(NSToolbarItem *)sender {
    
    // get user
    
    FBUser *toUser = self.conversation.to.allObjects.firstObject;
    
    NSURL *facebookURL = [NSURL URLWithString:@"http://facebook.com"];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", toUser.id] relativeToURL:facebookURL]];
    
}

#pragma mark - GUI

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
    // get model object
    FBConversationComment *comment = self.arrayController.arrangedObjects[row];
    
    FBConversationComment *previousComment;
    
    if (row != 0) {
        
        previousComment = self.arrayController.arrangedObjects[row - 1];
        
    }
    
    // determine whether the previous comment belongs to the same user as the current comment
    
    if (comment.from == previousComment.from) {
        
        NSTableCellView *messageCellView = [tableView makeViewWithIdentifier:@"NSTableCellView"
                                                                       owner:self];
        
        
        messageCellView.textField.stringValue = comment.message;
        
        return messageCellView;
    }
    
    FBMessageCellView *messageCellView = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                                     owner:self];
    
    
    
    // set text fields
    messageCellView.textField.stringValue = comment.message;
    
    messageCellView.nameField.stringValue = comment.from.name;
    
    messageCellView.dateField.stringValue = [_dateFormatter stringFromDate:comment.createdTime];
    
    return messageCellView;
}

-(CGFloat)tableView:(NSTableView *)tableView
        heightOfRow:(NSInteger)row
{
    // get model object
    FBConversationComment *comment = self.arrayController.arrangedObjects[row];
    
    FBConversationComment *previousComment;
    
    if (row != 0) {
        
       previousComment = self.arrayController.arrangedObjects[row - 1];
        
    }
    
    NSTableColumn *column = tableView.tableColumns.firstObject;
    
    CGFloat maxWidth = column.width - 40; // 20 on each side
    
    NSDictionary *attributes = @{NSFontAttributeName: [NSFont fontWithName:@"Helvetica"
                                                                      size:13]};
    
    NSSize size = [comment.message sizeWithAttributes:attributes];
    
    // add extra padding if last row
    
    CGFloat lastRowPadding = 0;
    
    if (row == tableView.numberOfRows - 1) {
        
        lastRowPadding = 10;
    }
    
    CGFloat messageHeight = ceil(size.width / maxWidth) * 18 + lastRowPadding; // number of lines * height of one line
    
    // determine whether the previous comment belongs to the same user as the current comment
    
    if (comment.from == previousComment.from) {
        
        // NSTableCellView
        
        return messageHeight + 6; // padding
    }
    
    // FBMessageCellView
    
    return messageHeight + 49; // padding and other UI elements
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
    
    column.width = self.tableView.frame.size.width - 3;
    
    // readjust row height
    
    [self.tableView reloadData];
}

-(void)windowDidBecomeKey:(NSNotification *)notification
{
    // mark as read
    
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    [appDelegate.store markConversationAsRead:self.conversation];
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
        
        [self scrollToBottomOfTableView];
        
    }];
}

-(void)recievedMessage:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
        [self scrollToBottomOfTableView];
        
    }];
    
}

@end
