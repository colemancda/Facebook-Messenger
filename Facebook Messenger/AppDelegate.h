//
//  AppDelegate.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 3/28/13.
//  Copyright (c) 2013 ColemanCDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const kErrorDomain;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
    NSBox *_viewControllerBox;
}

@property NSViewController *rootViewController;

@property (strong) IBOutlet NSBox *viewControllerBox;

@end
