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
    
    /** FB Account not enabled */
    FBMAPIAccountNotEnabledErrorCode,
    
    /** Error authenticating with XMPP server */
    FBMAPIXMPPAuthenticationErrorCode
    
};

extern NSString *const FBMAPIFinishedAuthenticationNotification;

extern NSString *const FBMAPISentMessageNotification;

extern NSString *const FBMAPIRecievedMessageNotification;

extern NSString *const FBMAPIErrorKey;

extern NSString *const FBMAPIMessageKey;

extern NSString *const FBMAPIJIDKey;

@interface FBMAPI : NSObject <XMPPStreamDelegate>
{
    dispatch_queue_t _xmppStreamDelegateQueue;
}

@property (readonly, nonatomic) ACAccountStore *accountStore;

@property (readonly, nonatomic) NSString *appID;

@property (readonly, nonatomic) ACAccount *facebookAccount;

@property (readonly, nonatomic) XMPPStream *xmppStream;

@property (readonly, nonatomic) NSURLSession *urlSession;

#pragma mark - Initialize

-(instancetype)initWithAppID:(NSString *)appID;

#pragma mark - Authenticate

-(void)requestAccessToFBAccount:(void (^)(NSError *error))completionBlock;

-(void)connectToXMPPServer;

-(void)logout;

#pragma mark - Requests

-(NSURLSessionDataTask *)fetchInboxWithCompletionBlock:(void (^)(NSError *error, NSArray *inbox))completionBlock;

-(void)sendMessage:(NSString *)message
     toUserWithJID:(NSString *)jid;

#pragma mark - Internal

// Used by subclasses

-(void)didSendMessage:(NSString *)message
        toUserWithJID:(NSString *)jid;

-(void)didRecieveMessage:(NSString *)message
         fromUserWithJID:(NSString *)jid;

@end
