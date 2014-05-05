//
//  FBMDirectoryWindowController.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import "FBMDirectoryWindowController.h"
#import "FBUserCellView.h"
#import "FBUser.h"
#import "FBUser+Jabber.h"
#import "FBMAppDelegate.h"
#import "FBMInboxWindowController.h"
#import "FBPhoto.h"
#import "FBMPurchasesStore.h"

static void *KVOContext = &KVOContext;

@interface FBMDirectoryWindowController ()

@property (nonatomic) NSImage *placeholderImage;

@end

@implementation FBMDirectoryWindowController

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
        
        self.placeholderImage = [NSImage imageNamed:@"NSApplicationIcon"];
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    // setup tableView double action
    
    [self.tableView setDoubleAction:@selector(doubleClickedTableView:)];
    
    self.tableView.target = self;
    
    // array controller
    
    self.arrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                           ascending:YES]];
    
    // exclude authenticated user
    
    self.arrayController.fetchPredicate = [NSPredicate predicateWithFormat:@"id != %@", appDelegate.store.user.id];
    
    // KVO
    
    [appDelegate.store addObserver:self
                        forKeyPath:@"xmppConnected"
                           options:NSKeyValueObservingOptionNew
                           context:KVOContext];
    
    // Notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userPresenceUpdated:)
                                                 name:FBMAPIUserPresenceUpdatedNotification
                                               object:appDelegate.store];
    
    // fetch friends
    
    [appDelegate.store fetchFriendList:^(NSError *error, NSArray *friends) {
       
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           
            if (error) {
                
                [NSApp presentError:error
                     modalForWindow:self.window
                           delegate:nil
                 didPresentSelector:nil
                        contextInfo:nil];
                
                return;
            }
        }];
        
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOContext) {
        
        if ([keyPath isEqualToString:@"xmppConnected"]) {
            
            [self.tableView reloadData];
            
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    FBUserCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                       owner:self];
    
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    // get model object
    FBUser *user = self.arrayController.arrangedObjects[row];
    
    // configure cell
    
    cell.textField.stringValue = user.name;
    
    // status image
    
    NSImage *image;
    
    if (!appDelegate.store.xmppConnected) {
        
        image = [NSImage imageNamed:@"NSStatusNone"];
    }
    
    else {
        
        if (user.userPresence.integerValue == FBUserOnlinePresence) {
            
            image = [NSImage imageNamed:@"NSStatusAvailable"];
        }
        if (user.userPresence.integerValue == FBUserUnavailiblePresence) {
            
            image = [NSImage imageNamed:@"NSStatusUnavailable"];
        }
    }
    
    cell.statusImageView.image = image;
    
    // Profile image
    
    cell.imageView.image = self.placeholderImage;
    
    if ([appDelegate.purchasesStore purchasedProductWithProductID:FBMPicturesProductID]) {
        
        if (user.profilePicture.image) {
            
            cell.imageView.image = user.profilePicture.image;
        }
        
        else {
            
            // fetch from server
            
            [appDelegate.store fetchPhotoForUserWithUserID:user.id completionBlock:^(NSError *error, NSData *data) {
               
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                   
                    if (error) {
                        
                        return;
                    }
                    
                    cell.imageView.image = user.profilePicture.image;
                    
                }];
                
            }];
        }
    }
    
    return cell;
}

#pragma mark - Actions

-(void)doubleClickedTableView:(id)sender
{
    if (self.tableView.selectedRow == -1) {
        
        return;
    }
    
    // get model object
    FBUser *user = self.arrayController.arrangedObjects[self.tableView.selectedRow];
    
    [self.inboxWC newConversationWithUser:user];
}

#pragma mark - First Responder

-(void)keyDown:(NSEvent *)theEvent
{
    if (theEvent.keyCode == 36) {
        
        [self doubleClickedTableView:self];
        
        return;
    }
    
    [super keyDown:theEvent];
}

#pragma mark - Notifications

-(void)userPresenceUpdated:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.tableView reloadData];
        
    }];
}

-(void)disconnected:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.tableView reloadData];
        
    }];
}

@end
