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
#import "XMPP.h"

extern NSString *const FBMErrorDomain;

typedef NS_ENUM(NSInteger, FBMAPIErrorCode) {
    
    FBMAPIAccountNotEnabledErrorCode
    
};

@interface FBMAPI : NSObject

@property (readonly) ACAccountStore *accountStore;

@property (readonly) ACAccount *facebookAccount;

@property (readonly) NSString *appID;

@property (readonly) NSString *token;

@property XMPPStream *xmppStream;

#pragma mark - Initialize

-(id)initWithAppID:(NSString *)appID;

#pragma mark - Authenticate

-(void)requestAccessToFBAccount:(void (^)(NSError *error))completionBlock;

-(void)connectToXMPPServer:(void (^)(BOOL success))completionBlock;

#pragma mark - Requests



@end
