//
//  FBMDirectoryWindowController.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import "FBMDirectoryWindowController.h"
#import "FBUserCellView.h"

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
}

#pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    FBUserCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                       owner:self];
    
    
    
}

@end
