//
//  FBMPurchasesViewController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
@import StoreKit;

@interface FBMPurchasesViewController : NSViewController <MASPreferencesViewController, NSTableViewDelegate, NSTableViewDataSource, SKPaymentTransactionObserver>

#pragma mark - IB Outlets

@property (strong) IBOutlet NSArrayController *arrayController;

@property (weak) IBOutlet NSTableView *tableView;

#pragma mark - Actions

-(void)doubleClickedTableView:(id)sender;

-(IBAction)restorePurchases:(id)sender;

-(IBAction)refreshProducts:(id)sender;

#pragma mark - Notifications

-(void)verifyFailed:(NSNotification *)notification;

@end
