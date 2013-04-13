//
//  LoadingViewController.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 4/13/13.
//  Copyright (c) 2013 ColemanCDA. All rights reserved.
//

#import "LoadingViewController.h"
#import "FacebookStore.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)loadView
{
    [super loadView];
    
    // set label
    self.label.stringValue = NSLocalizedString(@"Requesting access to Facebook accounts...", @"Requesting access to Facebook accounts...");
    
    // animate the progress indicator
    [self.progressIndicator startAnimation:self];
    
    // fetch accounts
    [[FacebookStore sharedStore] fetchFacebookAccountsWithCompletion:^(NSArray *accounts, NSError *error) {
        
        if (!accounts) {
            [NSApp performSelectorOnMainThread:@selector(presentError:) withObject:error waitUntilDone:YES];
            
            [NSApp terminate:self];
        }
        else {
            NSLog(@"Accounts: '%@'", accounts);
        }
        
    }];
    
}

@end
