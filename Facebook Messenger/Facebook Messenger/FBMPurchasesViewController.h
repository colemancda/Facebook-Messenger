//
//  FBMPurchasesViewController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface FBMPurchasesViewController : NSViewController <MASPreferencesViewController, NSTableViewDelegate, NSTableViewDataSource>

#pragma mark - IB Outlets

@property (strong) IBOutlet NSArrayController *arrayController;


@end
