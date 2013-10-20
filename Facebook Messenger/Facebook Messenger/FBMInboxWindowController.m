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
    
    FBMAppDelegate *appDelegate = [NSApp delegate];
    
    [appDelegate.store requestInboxWithCompletionBlock:^(NSError *error) {
        
        if (error) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               
                [NSApp presentError:error];
                
            }];
            
            return;
        }
        
        NSLog(@"Got Inbox");
        
    }];
}

#pragma mark



@end
