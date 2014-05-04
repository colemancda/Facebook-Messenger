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

static void *KVOContext = &KVOContext;

NSString *const ConversationNameKeyPath = @"conversation.to";

@interface FBMConversationWindowController ()

@property (nonatomic) NSArray *conversationDataSourceArray;

@property (nonatomic) NSImage *placeholderImage;

@end

@implementation FBMConversationWindowController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObserver:self forKeyPath:ConversationNameKeyPath];
    
    [self removeObserver:self forKeyPath:@"arrayController.arrangedObjects"];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextObjectsDidChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:appDelegate.store.context];
    
    // KVO
    
    [self addObserver:self
           forKeyPath:ConversationNameKeyPath
              options:NSKeyValueObservingOptionNew
              context:KVOContext];
    
    [self addObserver:self
           forKeyPath:@"arrayController.arrangedObjects"
              options:NSKeyValueObservingOptionNew
              context:KVOContext];
    
    self.arrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES]];
    
    self.arrayController.fetchPredicate = [NSPredicate predicateWithFormat:@"conversation == %@", self.conversation];
    
    if ([appDelegate.purchasesStore purchasedProductWithProductID:FBMPicturesProductID]) {
        
        // check for profile pic
        
        FBUser *toUser = self.conversation.to.allObjects.firstObject;
        
        if (!toUser.profilePicture.image) {
            
            [appDelegate.store fetchPhotoForUserWithUserID:toUser.id completionBlock:^(NSError *error, NSData *data) {
               
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                   
                    if (error) {
                        
                        [NSApp presentError:error
                             modalForWindow:self.window
                                   delegate:nil
                         didPresentSelector:nil
                                contextInfo:nil];
                        
                        return;
                    }
                    
                    self.userProfileToolbarItem.image = toUser.profilePicture.image;
                    
                }];
            }];
            
        }
        
        else {
            
            self.userProfileToolbarItem.image = toUser.profilePicture.image;
        }
    }
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
        
        // conversation name
        
        if ([keyPath isEqualToString:ConversationNameKeyPath]) {
            
            if (self.conversation) {
                
                NSString *toString = self.conversation.toString;
                
                if (![self.window.title isEqualToString:toString]) {
                    
                    self.window.title = toString;
                }
                
                if (![self.windowFrameAutosaveName isEqualToString:toString]) {
                    
                    self.windowFrameAutosaveName = toString;
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
    id entity = self.conversationDataSourceArray[row];
    
    // Group header
    if ([entity isKindOfClass:[FBUser class]]) {
        
        FBMConversationGroupView *cellView = [tableView makeViewWithIdentifier:@"FBMConversationGroupView"
                                                                         owner:self];
        
        // model object
        
        FBUser *user = entity;
        
        FBMAppDelegate *appDelegate = [NSApp delegate];
        
        // configure cell
        
        cellView.imageView.image = self.placeholderImage;
        
        if ([appDelegate.purchasesStore purchasedProductWithProductID:FBMPicturesProductID]) {
            
            // check for profile pic
            
            if (!user.profilePicture.image) {
                
                [appDelegate.store fetchPhotoForUserWithUserID:user.id completionBlock:^(NSError *error, NSData *data) {
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        if (error) {
                            
                            return;
                        }
                        
                        self.userProfileToolbarItem.image = user.profilePicture.image;
                        
                    }];
                }];
                
            }
            
            else {
                
                self.userProfileToolbarItem.image = user.profilePicture.image;
            }
        }
        
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
    
    return ceil(size.width / maxWidth) * 18 + lastRowPadding + 6; // number of lines * height of one line + horizontal padding
}

-(BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
    // get model object
    id entity = self.conversationDataSourceArray[row];
    
    return [entity isKindOfClass:[FBUser class]];
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

-(void)contextObjectsDidChange:(NSNotification *)notification
{
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    if ([appDelegate.purchasesStore purchasedProductWithProductID:FBMPicturesProductID]) {
        
        // get user
        
        FBUser *toUser = self.conversation.to.allObjects.firstObject;
        
        // update user profile picture
        
        if (self.userProfileToolbarItem.image != toUser.profilePicture.image && toUser.profilePicture.image) {
            
            self.userProfileToolbarItem.image = toUser.profilePicture.image;
        }
    }
}

@end
