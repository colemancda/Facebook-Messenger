//
//  FBMAppDelegate.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FBMStore;

extern NSString *const FBMAppID;

extern NSString *const SavedFBAccountIdentifierPreferenceKey;

@interface FBMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly) FBMStore *store;

-(void)attemptToLogin:(void (^)(BOOL loggedIn))completionBlock;


@end
