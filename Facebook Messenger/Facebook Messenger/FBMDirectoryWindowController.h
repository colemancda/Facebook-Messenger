//
//  FBMDirectoryWindowController.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/1/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FBMDirectoryWindowController : NSWindowController <NSTableViewDelegate>

#pragma mark - IB Outlets

@property (strong) IBOutlet NSArrayController *arrayController;



@end
