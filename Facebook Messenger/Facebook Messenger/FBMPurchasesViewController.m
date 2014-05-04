//
//  FBMPurchasesViewController.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import "FBMPurchasesViewController.h"
#import "FBMAppDelegate.h"
#import "FBMPurchasesStore.h"

@interface FBMPurchasesViewController ()
{
    FBMPurchasesStore *_purchasesStore;
    
    NSNumberFormatter *_numberFormatter;
}

@end

@implementation FBMPurchasesViewController

- (id)init
{
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
        // convenience pointer
        
        FBMAppDelegate *appDelegate = [NSApp delegate];
        
        _purchasesStore = appDelegate.purchasesStore;
        
        // number formatter
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        
        _numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // setup tableView double action
    
    [self.tableView setDoubleAction:@selector(doubleClickedTableView:)];
    
    self.tableView.target = self;
    
    // notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(verifyFailed:)
                                                 name:FBMPurchasesStoreProductsRequestFailedNotification
                                               object:_purchasesStore];
    
    // load products
    
    [_purchasesStore verifyProducts];
}

#pragma mark - MASPreferencesViewController

-(NSString *)identifier
{
    return [self className];
}

-(NSImage *)toolbarItemImage
{
    return [[NSWorkspace sharedWorkspace] iconForFile:@"/Applications/App Store.app"];
}

-(NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Purchases", @"FBMPurchasesViewController toolbarItemLabel");
}

-(void)viewWillAppear
{
    
    
    
}

#pragma mark - NSTableViewDataSource

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    SKProduct *product = self.arrayController.arrangedObjects[row];
    
    if ([tableColumn.identifier isEqualToString:@"price"]) {
        
        _numberFormatter.locale = product.priceLocale;
        
        return [_numberFormatter stringFromNumber:product.price];
    }
    
    if ([tableColumn.identifier isEqualToString:@"purchased"]) {
        
        return @([_purchasesStore purchasedProductWithProductID:FBMPicturesProductID]);
    }
    
    
    return [product valueForKey:tableColumn.identifier];
}

#pragma mark - Actions

-(void)doubleClickedTableView:(id)sender
{
    if (self.tableView.selectedRow == -1) {
        
        return;
    }
    
    SKProduct *product = self.arrayController.arrangedObjects[self.tableView.selectedRow];
    
    [_purchasesStore purchaseProduct:product];
}

-(void)restorePurchases:(id)sender
{
    [_purchasesStore restorePurchases];
}

-(void)refreshProducts:(id)sender
{
    [_purchasesStore verifyProducts];
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

-(void)verifyFailed:(NSNotification *)notification
{
    NSError *error = notification.userInfo[FBMPurchasesStoreErrorKey];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
        [NSApp presentError:error];
        
    }];
}

#pragma mark - SKPaymentTransactionObserver

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
        [self.tableView reloadData];
        
    }];
}

-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.tableView reloadData];
        
    }];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [NSApp presentError:error];
        
    }];
}

@end
