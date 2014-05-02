//
//  FBMessageCellView.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FBMessageCellView : NSTableCellView

#pragma mark - IB Outlets

@property IBOutlet NSTextField *nameField;

@property IBOutlet NSTextField *dateField;

@end
