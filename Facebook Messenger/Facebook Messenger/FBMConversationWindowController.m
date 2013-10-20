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
    
    // KVC
    [self addObserver:self
           forKeyPath:@"conversation"
              options:NSKeyValueObservingOptionOld
              context:nil];
    
}

-(void)dealloc
{
    [self removeObserver:self
              forKeyPath:@"conversation"];
    
}

#pragma mark - KVC

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:@"conversation"]) {
        
        // update GUI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           
            [self updateWindowTitle];
            
            
            
        }];
        
    }
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

#pragma mark - NSWindowDelegate

-(void)windowDidBecomeKey:(NSNotification *)notification
{
    // set title of window to names of consersation members
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self updateWindowTitle];
        
        
        
    }];
}


@end
