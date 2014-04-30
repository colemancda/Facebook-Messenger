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

@protocol FBMAPIDelegate;

@interface FBMAPI : NSObject <XMPPStreamDelegate>
{
    dispatch_queue_t _xmppStreamDelegateQueue;
}

@property (readonly, nonatomic) ACAccountStore *accountStore;

@property (readonly, nonatomic) NSString *appID;

@property (readonly) ACAccount *facebookAccount;

@property (readonly) XMPPStream *xmppStream;

@property id<FBMAPIDelegate> delegate;

#pragma mark - Initialize

-(instancetype)initWithAppID:(NSString *)appID;

#pragma mark - Authenticate

-(void)requestAccessToFBAccount:(void (^)(NSError *error))completionBlock;

-(void)connectToXMPPServer;

-(void)logout;

@end

@protocol FBMAPIDelegate <NSObject>

-(void)api:(FBMAPI *)api didFinishAuthenticationWithError:(NSError *)error;

-(void)api:(FBMAPI *)api didRecieveMessage:(NSDictionary *)message;

@end
