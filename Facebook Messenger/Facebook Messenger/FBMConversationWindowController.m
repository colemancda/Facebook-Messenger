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
#import "FBMAppDelegate.h"
#import "FBUser+Jabber.h"
#import "FBConversation+Info.h"
#import "FBPhoto.h"
#import "FBMPurchasesStore.h"
#import "FBMConversationCommentView.h"
#import "FBMConversationGroupView.h"
#import "FBMPurchasesStore.h"
#import "FBMStore.h"
#import "INAppStoreWindow.h"

static void *KVOContext = &KVOContext;

NSString *const ConversationRecipientsKeyPath = @"conversation.to";

@interface FBMConversationWindowController ()

@property (nonatomic) NSArray *conversationDataSourceArray;

@property (nonatomic) NSImage *placeholderImage;

@property (nonatomic) FBUser *toUser;

@end

@implementation FBMConversationWindowController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObserver:self
              forKeyPath:ConversationRecipientsKeyPath];
    
    [self removeObserver:self
              forKeyPath:@"arrayController.arrangedObjects"];
    
    [self removeObserver:self
              forKeyPath:@"toUser"];
    
    [self removeObserver:self
              forKeyPath:@"toUser.profilePicture.data"];
    
    [self removeObserver:self
              forKeyPath:@"toUser.userPresence"];
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
        
        // date formatter
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        
        // placeholder image
        
        self.placeholderImage = [NSImage imageNamed:@"NSApplicationIcon"];
        
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // setup title bar
    
    INAppStoreWindow *window = (INAppStoreWindow *)self.window;
    
    window.titleBarView = self.titlebarView;
    
    window.titleBarHeight = 72;
    
    window.verticalTrafficLightButtons = YES;
    
    window.verticallyCenterTitle = YES;
    
    window.centerFullScreenButton = YES;
    
    window.centerTrafficLightButtons = YES;
    
    window.fullScreenButtonRightMargin = 10;
    
    // scroll to bottom
    
    [self scrollToBottomOfTableView];
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
           forKeyPath:ConversationRecipientsKeyPath
              options:NSKeyValueObservingOptionNew
              context:KVOContext];
    
    [self addObserver:self
           forKeyPath:@"arrayController.arrangedObjects"
              options:NSKeyValueObservingOptionNew
              context:KVOContext];
    
    [self addObserver:self
           forKeyPath:@"toUser"
              options:NSKeyValueObservingOptionNew
              context:KVOContext];
    
    [self addObserver:self
           forKeyPath:@"toUser.profilePicture.data"
              options:NSKeyValueObservingOptionNew
              context:KVOContext];
    
    [self addObserver:self
           forKeyPath:@"toUser.userPresence"
              options:NSKeyValueObservingOptionNew
              context:KVOContext];
    
    self.arrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES]];
    
    self.arrayController.fetchPredicate = [NSPredicate predicateWithFormat:@"conversation == %@", self.conversation];

}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOContext) {
        
        FBMAppDelegate *appDelegate = [NSApp delegate];
        
        if ([keyPath isEqualToString:@"toUser.userPresence"]) {
            
            NSImage *image;
            
            if (self.toUser.userPresence.integerValue == FBUserOnlinePresence) {
                
                image = [NSImage imageNamed:@"NSStatusAvailable"];
            }
            if (self.toUser.userPresence.integerValue == FBUserUnavailiblePresence) {
                
                image = [NSImage imageNamed:@"NSStatusUnavailable"];
            }
            
            self.titleBarStatusImageView.image = image;
        }
        
        // toUser
        
        if ([keyPath isEqualToString:@"toUser"]) {
            
            NSString *autoSaveName = [NSString stringWithFormat:@"com.ColemanCDA.FacebookMessenger.ConversationWC.%@", self.toUser.name];
            
            if (![self.windowFrameAutosaveName isEqualToString:autoSaveName]) {
                
                self.windowFrameAutosaveName = autoSaveName;
            }
            
        }
        
        // profile pic
        
        if ([keyPath isEqualToString:@"toUser.profilePicture.data"]) {
            
            if ([appDelegate.purchasesStore purchasedProductWithProductID:FBMPicturesProductID]) {
                
                // check for profile pic
                
                if (!self.toUser.profilePicture.image) {
                    
                    // set placeholder image
                    
                    self.titleBarProfileImageView.image = self.placeholderImage;
                    
                    [appDelegate.store fetchPhotoForUserWithUserID:self.toUser.id completionBlock:^(NSError *error, NSData *data) {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            if (error) {
                                
                                [NSApp presentError:error
                                     modalForWindow:self.window
                                           delegate:nil
                                 didPresentSelector:nil
                                        contextInfo:nil];
                                
                                return;
                            }
                            
                            self.titleBarProfileImageView.image = self.toUser.profilePicture.image;
                            
                        }];
                    }];
                    
                }
                
                else {
                    
                    self.titleBarProfileImageView.image = self.toUser.profilePicture.image;
                }
            }
        }
        
        // conversation name
        
        if ([keyPath isEqualToString:ConversationRecipientsKeyPath]) {
            
            if (self.conversation) {
                
                // determine user
                
                if (self.conversation.to.count > 1) {
                    
                    for (FBUser *user in self.conversation.to) {
                        
                        if (user != appDelegate.store.user) {
                            
                            self.toUser = user;
                            
                            break;
                        }
                    }
                }
                else {
                    
                    self.toUser = self.conversation.to.allObjects.firstObject;
                }
            }
        }
        
        // array controller
        
        if ([keyPath isEqualToString:@"arrayController.arrangedObjects"]) {
            
            // repopulate data source array
            
            NSMutableArray *dataSourceArray = [[NSMutableArray alloc] init];
            
            NSArray *arrangedObjects = self.arrayController.arrangedObjects;
            
            for (FBConversationComment *comment in arrangedObjects) {
                
                // first object
                
                if (comment == arrangedObjects.firstObject) {
                    
                    [dataSourceArray addObject:comment.from];
                    
                    [dataSourceArray addObject:comment];
                    
                    continue;
                }
                
                FBConversationComment *previousComment;
                
                NSInteger index = [arrangedObjects indexOfObject:comment];
                
                previousComment = arrangedObjects[index - 1];
                
                // determine whether the previous comment belongs to the same user as the current comment
                
                if (comment.from == previousComment.from) {
                    
                    [dataSourceArray addObject:comment];
                }
                
                // different user
                else {
                    
                    [dataSourceArray addObject:comment.from];
                    
                    [dataSourceArray addObject:comment];
                }
            }
            
            // set array
            
            self.conversationDataSourceArray = [NSArray arrayWithArray:dataSourceArray];
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
    
    [appDelegate.store sendMessage:sender.stringValue
                     toUserWithJID:self.toUser.jid];
    
}

- (IBAction)showUserProfile:(NSToolbarItem *)sender {
    
    // get user
    
    NSURL *facebookURL = [NSURL URLWithString:@"http://facebook.com"];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.toUser.id] relativeToURL:facebookURL]];
    
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
    id entity = self.conversationDataSourceArray[row];
    
    // Group header
    if ([entity isKindOfClass:[FBUser class]]) {
        
        FBMConversationGroupView *cellView = [tableView makeViewWithIdentifier:@"FBMConversationGroupView"
                                                                         owner:self];
        
        // model object
        
        FBUser *user = entity;
        
        // user name
        
        cellView.textField.stringValue = user.name;
        
        // date...
        
        // get next item in array
        
        FBConversationComment *comment = self.conversationDataSourceArray[row + 1];
        
        cellView.dateField.stringValue = [_dateFormatter stringFromDate:comment.createdTime];
        
        return cellView;
    }
    
    // Message
    
    FBMConversationCommentView *messageCellView = [tableView makeViewWithIdentifier:@"FBMConversationCommentView"
                                                                   owner:self];
    
    FBConversationComment *comment = entity;
    
    
    messageCellView.multilineTextField.stringValue = comment.message;
    
    return messageCellView;
}

-(CGFloat)tableView:(NSTableView *)tableView
        heightOfRow:(NSInteger)row
{
    // get model object
    id entity = self.conversationDataSourceArray[row];
    
    // group header
    
    if ([entity isKindOfClass:[FBUser class]]) {
        
        return 30;
    }
    
    // message
    
    FBConversationComment *comment = entity;
    
    NSTableColumn *column = tableView.tableColumns.firstObject;
    
    CGFloat maxWidth = column.width - 6; // 20 on each side
    
    NSDictionary *attributes = @{NSFontAttributeName: [NSFont fontWithName:@"Helvetica"
                                                                      size:13]};
    
    NSSize size = [comment.message sizeWithAttributes:attributes];
    
    // add extra padding if last row
    
    CGFloat lastRowPadding = 0;
    
    if (row == tableView.numberOfRows - 1) {
        
        lastRowPadding = 10;
    }
    
    return (ceil(size.width / maxWidth) * 18) + lastRowPadding + 6; // number of lines * height of one line + horizontal padding
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
    // check to see if the sent message belongs to this conversation
    
    NSString *jid = notification.userInfo[FBMAPIJIDKey];
    
    NSNumber *messageUserID = [FBUser userIDFromJID:jid];
    
    if (![messageUserID isEqualToNumber:self.toUser.id]) {
        
        return;
    }
    
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
    // check to see if its our user
    
    NSString *jid = notification.userInfo[FBMAPIJIDKey];
    
    NSNumber *userID = [FBUser userIDFromJID:jid];
    
    if ([self.toUser.id isEqualToNumber:userID]) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            FBMAppDelegate *appDelegate = [NSApp delegate];
            
            [appDelegate.store markConversationAsRead:self.conversation];
            
            [self scrollToBottomOfTableView];
            
        }];
    }
}

@end
