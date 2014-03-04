//
//  FBMAPI.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 12/29/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface FBMAPI : NSObject

@property (readonly) ACAccountStore *accountStore;

@property (readonly) ACAccount *facebookAccount;

@property (readonly) NSWindow *window;

#pragma mark - Authenticate

-(void)requestAccessToFBAccount:(void (^)(BOOL success))completionBlock;

#pragma mark - Requests

@end