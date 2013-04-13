//
//  AppDelegate.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 3/28/13.
//  Copyright (c) 2013 ColemanCDA. All rights reserved.
//

#import "AppDelegate.h"
#import "LoadingViewController.h"
#import "LoginViewController.h"

NSString *const kErrorDomain = @"com.ColemanCDA.FacebookMessenger.ErrorDomain";

@implementation AppDelegate

@synthesize rootViewController = _rootViewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // launch loading window
    self.rootViewController = [[LoginViewController alloc] init];
    
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark - Properties

-(NSViewController *)rootViewController
{
    // return value
    return _rootViewController;
}

-(void)setRootViewController:(NSViewController *)rootViewController
{
    // set the value
    _rootViewController = rootViewController;
    
    // show the rootVC in the box    
    _viewControllerBox.contentView = _rootViewController.view;
}


@end
