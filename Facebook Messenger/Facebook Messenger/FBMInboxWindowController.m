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
#import "FBConversationComment.h"
#import "FBUser.h"
#import "FBMConversationWindowController.h"
#import "FBMDirectoryWindowController.h"
#import "FBConversation+Info.h"

NSString *const FBMUserNotificationConversationIdentifier = @"FBMUserNotificationConversationIdentifier";

@interface FBMInboxWindowController ()

@end

@implementation FBMInboxWindowController

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
        
        _conversationWCs = [[NSMutableDictionary alloc] init];
        
        _deliveredUserNotifications = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    // add observer
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedMessage:)
                                                 name:FBMAPIRecievedMessageNotification
                                               object:appDelegate.store];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sentMessage:)
                                                 name:FBMAPISentMessageNotification
                                               object:appDelegate.store];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userPresenceUpdated:)
                                                 name:FBMAPIUserPresenceUpdatedNotification
                                               object:appDelegate.store];
    
    // user notifications
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    // set tableview action
    
    [self.tableView setDoubleAction:@selector(clickedRow:)];
    
    self.tableView.target = self;
    
    // setup tableview sort descriptor
    
    for (NSTableColumn *tableColumn in self.tableView.tableColumns) {
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier
                                                                         ascending:YES];
        [tableColumn setSortDescriptorPrototype:sortDescriptor];
    }
    
    // sort descriptor
    
    self.arrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedTime"
                                                                           ascending:NO]];
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
    
    if ([identifier isEqualToString:@"toString"]) {
        
        // set text
        cellView.textField.stringValue = conversation.toString;
    }
    
    if ([identifier isEqualToString:@"userPresence"]) {
        
        // get user presence
        
        FBUserPresence userPresence = conversation.userPresence;
        
        NSImage *image;
        
        if (userPresence == FBUserOnlinePresence) {
            
            image = [NSImage imageNamed:@"NSStatusAvailable"];
        }
        if (userPresence == FBUserUnavailiblePresence) {
            
            image = [NSImage imageNamed:@"NSStatusUnavailable"];
        }
        
        // set online status
        cellView.imageView.image = image;
    }
    
    // check whether the conversation has unread messages
    if (conversation.unread.boolValue ||
        conversation.unseen.boolValue) {
        
        cellView.textField.textColor = [NSColor blueColor];
        
    }
    else {
        
        cellView.textField.textColor = [NSColor blackColor];
    }
    
    
    return cellView;
}

#pragma mark - First Responder

-(void)newDocument:(id)sender
{
    if (!_directoryWC) {
        
        _directoryWC = [[FBMDirectoryWindowController alloc] init];
        
        _directoryWC.inboxWC = self;
    }
    
    [_directoryWC.window makeKeyAndOrderFront:self];
    
}

#pragma mark - Actions

-(void)clickedRow:(id)sender
{
    if (self.tableView.clickedRow == -1) {
        
        return;
    }
    
    // get model object
    FBConversation *conversation = self.arrayController.arrangedObjects[self.tableView.clickedRow];
    
    // search for existing WC for this conversation
    
    FBUser *user = conversation.to.allObjects.firstObject;
    
    NSString *wcKey = [NSString stringWithFormat:@"%@", user.id];
    
    FBMConversationWindowController *conversationWC = _conversationWCs[wcKey];
    
    if (!conversationWC) {
        
        conversationWC = [[FBMConversationWindowController alloc] init];
        
        [_conversationWCs setObject:conversationWC
                             forKey:wcKey];
        
        // set model object
        
        conversationWC.conversation = conversation;
        
    }
    
    // update GUI
    
    [conversationWC.window makeKeyAndOrderFront:self];
}

-(void)newConversationWithUser:(FBUser *)user
{
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    // search for existing WC for this conversation
    
    NSString *wcKey = [NSString stringWithFormat:@"%@", user.id];
    
    FBMConversationWindowController *conversationWC = _conversationWCs[wcKey];
    
    if (!conversationWC) {
        
        conversationWC = [[FBMConversationWindowController alloc] init];
        
        [_conversationWCs setObject:conversationWC
                             forKey:wcKey];
        
        // create new conversation
        
        [appDelegate.store findOrCreateConversationWithUser:user completionBlock:^(FBConversation *conversation) {
            
            // set model object
            
            conversationWC.conversation = conversation;
            
            // update GUI
            
            [conversationWC.window makeKeyAndOrderFront:self];
            
        }];
        
        return;
        
    }
    
    // update GUI
    
    [conversationWC.window makeKeyAndOrderFront:self];
    
}

#pragma mark - Notifications

-(void)recievedMessage:(NSNotification *)notification
{
    // get notification info
    
    NSString *jid = notification.userInfo[FBMAPIJIDKey];
    
    NSString *messageBody = notification.userInfo[FBMAPIMessageKey];
    
    // get user ID
    
    NSString *userID = [jid stringByReplacingOccurrencesOfString:@"@chat.facebook.com"
                                              withString:@""];
    
    userID = [userID stringByReplacingOccurrencesOfString:@"-"
                                                   withString:@""];
    
    // look for WC with userID
    
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    [appDelegate.store findConversationWithUserWithID:[NSNumber numberWithInteger:userID.integerValue] completionBlock:^(FBConversation *conversation) {
        
        // recieved message was not part of downloaded inbox
        
        if (!conversation) {
            
            // download inbox
            
            [appDelegate.store fetchInboxWithCompletionBlock:^(NSError *error, NSArray *inbox) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    if (error) {
                        
                        return;
                    }
                    
                    [self.arrayController fetch:self];
                    
                    // show notification
                    
                    [self presentNotificationForMessage:messageBody
                                         inConversation:conversation];
                    
                }];
                
            }];
            
            return;
        }
        
        [self.arrayController fetch:self];
        
        // search for existing WC for this conversation
        
        FBUser *user = conversation.to.allObjects.firstObject;
        
        NSString *wcKey = [NSString stringWithFormat:@"%@", user.id];
        
        FBMConversationWindowController *conversationWC = _conversationWCs[wcKey];
        
        // user is viewing conversation
        
        if (conversationWC.window.isKeyWindow && [NSApp isActive]) {
             
             return;
         }
         
         // show notification
         
         [self presentNotificationForMessage:messageBody
                              inConversation:conversation];
        
    }];
}

-(void)sentMessage:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.arrayController fetch:self];
        
    }];
    
}

-(void)userPresenceUpdated:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.arrayController fetch:self];
        
    }];
}

#pragma mark - GUI

-(void)presentNotificationForMessage:(NSString *)newMessage
                      inConversation:(FBConversation *)conversation
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSUserNotification *userNotification = [[NSUserNotification alloc] init];
        
        userNotification.title = conversation.toString;
        
        userNotification.informativeText = newMessage;
        
        FBUser *user = conversation.to.allObjects.firstObject;
        
        userNotification.userInfo = @{FBMUserNotificationConversationIdentifier: [NSString stringWithFormat:@"%@", user.id]};
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];
        
        [_deliveredUserNotifications addObject:userNotification];
    }];
}

#pragma mark - NSUserNotificationCenterDelegate

-(void)userNotificationCenter:(NSUserNotificationCenter *)center
      didActivateNotification:(NSUserNotification *)notification
{
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    NSString *wcKey = notification.userInfo[FBMUserNotificationConversationIdentifier];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        // remove all notifications related to user...
        
        for (NSUserNotification *userNotification in _deliveredUserNotifications) {
            
            NSString *userID = userNotification.userInfo[FBMUserNotificationConversationIdentifier];
            
            if ([userID isEqualToString:wcKey]) {
                
                [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:userNotification];
            }
            
        }
        
        // reload tableView
        
        [self.arrayController fetch:self];
       
        // find WC
        
        FBMConversationWindowController *conversationWC = _conversationWCs[wcKey];
        
        if (conversationWC) {
            
            // update GUI
            
            [conversationWC.window makeKeyAndOrderFront:self];
            
            return;
        }
        
        
        // find conversation
        
        [appDelegate.store findUserWithID:[NSNumber numberWithInteger:wcKey.integerValue] completionBlock:^(FBUser *user) {
            
            [appDelegate.store findOrCreateConversationWithUser:user completionBlock:^(FBConversation *conversation) {
               
                FBMConversationWindowController *conversationWC = [[FBMConversationWindowController alloc] init];
                
                conversationWC.conversation = conversation;
                
                [_conversationWCs setObject:conversationWC
                                     forKey:wcKey];
                
                // update GUI
                
                [conversationWC.window makeKeyAndOrderFront:self];
                
            }];
            
        }];
        
    }];
}


@end
