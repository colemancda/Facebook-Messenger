//
//  FBMAPI.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 12/29/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "FBMAPI.h"

NSString *const FBMErrorDomain = @"com.ColemanCDA.Facebook-Messenger.ErrorDomain";

@interface FBMAPI ()

@property (nonatomic) ACAccountStore *accountStore;

@property (nonatomic) NSString *appID;

@property ACAccount *facebookAccount;

@property XMPPStream *xmppStream;

@end

@implementation FBMAPI

- (instancetype)initWithAppID:(NSString *)appID
{
    self = [super init];
    if (self) {
        
        self.appID = appID;
        
        self.accountStore = [[ACAccountStore alloc] init];
        
    }
    return self;
}

- (instancetype)init
{
    return [self initWithAppID:nil];
}

#pragma mark - Authenticate

-(void)requestAccessToFBAccount:(void (^)(NSError *))completionBlock
{
    NSArray *fbPermissions = @[@"read_mailbox",
                               @"friends_online_presence",
                               @"user_about_me",
                               @"user_online_presence",
                               @"xmpp_login"];
    
    NSDictionary *accessOptions = @{ACFacebookAppIdKey: self.appID,
                                    ACFacebookPermissionsKey : fbPermissions};
    
    
    ACAccountType *fbAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // request access to accounts
    
    [_accountStore requestAccessToAccountsWithType:fbAccountType options:accessOptions completion:^(BOOL granted, NSError *error) {
        
        // access denied
        if (!granted) {
            
            completionBlock(error);
            return;
        }
        
        NSArray *accounts = [_accountStore accountsWithAccountType:fbAccountType];
        
        // account exists but is not enabled
        if (!accounts.count) {
            
            NSString *description = NSLocalizedString(@"The FB account is not enabled", @"Account not enabled error description");
            
            NSString *suggestion = NSLocalizedString(@"Enable your FB account in System Preferences", @"Account not enabled error suggestion");
            
            NSError *error = [NSError errorWithDomain:FBMErrorDomain
                                                 code:FBMAPIAccountNotEnabledErrorCode
                                             userInfo:@{NSLocalizedDescriptionKey: description,
                                                        NSLocalizedRecoverySuggestionErrorKey: suggestion}];
            
            completionBlock(error);
            
            return;
        }
        
        // can only have one FB account in OS X
        
        ACAccount *facebookAccount = accounts[0];
        
        // renew credentials
        [_accountStore renewCredentialsForAccount:facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
            
            if (renewResult != ACAccountCredentialRenewResultRenewed) {
                
                completionBlock(error);
                
                return;
            }
            
            // store account
            _facebookAccount = facebookAccount;
            
            completionBlock(nil);
            
        }];
    }];
}

-(void)connectToXMPPServer
{
    self.xmppStream = [[XMPPStream alloc] initWithFacebookAppId:self.appID];
    
    _xmppStreamDelegateQueue = dispatch_queue_create("com.ColemanCDA.Facebook-Messenger.XMPPStreamDelegateQueue", DISPATCH_QUEUE_CONCURRENT);
    
    [self.xmppStream addDelegate:self delegateQueue:_xmppStreamDelegateQueue];
    
    NSError *error;
    
    // authenticate
    
    if (![self.xmppStream authenticateWithFacebookAccessToken:self.facebookAccount.credential.oauthToken
                                                       error:&error]) {
        
        [self.delegate api:self didFinishAuthenticationWithError:error];
        
        return;
    }
    
    // connect
    
    if (![self.xmppStream connectWithTimeout:5
                                       error:&error]) {
        
        [self.delegate api:self didFinishAuthenticationWithError:error];
        
        return;
    }
    
    // delegate will return
    
}

-(void)logout
{
    self.accountStore = [[ACAccountStore alloc] init];
    
    self.facebookAccount = nil;
    
    self.xmppStream = nil;
}

#pragma mark - XMPPStreamDelegate

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)xmlError
{
    NSError *error = [NSError errorWithDomain:FBMErrorDomain
                                         code:
                                     userInfo:];
    
    [self.delegate api:self didFinishAuthenticationWithError:error];
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self.delegate api:self didFinishAuthenticationWithError:nil];
}


@end
