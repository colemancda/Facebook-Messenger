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

@interface FBMDirectoryWindowController ()

@end

@implementation FBMDirectoryWindowController

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
    
    // setup tableView double action
    
    [self.tableView setDoubleAction:@selector(doubleClickedTableView:)];
    
    self.tableView.target = self;
    
    self.arrayController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                           ascending:YES]];
    
    // fetch friends
    
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
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

#pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    FBUserCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                       owner:self];
    
    // get model object
    FBUser *user = self.arrayController.arrangedObjects[row];
    
    // configure cell
    
    cell.textField.stringValue = user.name;
    
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

@end
