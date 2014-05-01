//
//  FBMAPI.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 12/29/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "FBMAPI.h"

NSString *const FBMErrorDomain = @"com.ColemanCDA.Facebook-Messenger.ErrorDomain";

@implementation FBMAPI (Errors)

-(NSError *)errorForErrorCode:(NSInteger)errorCode
{
    
    
    // unkown error
    
    NSString *unkownErrorDescription = NSLocalizedString(@"An unkown error occurred",
                                                         @"Unkown Error Message");
    
    NSError *unkownError = [NSError errorWithDomain:FBMErrorDomain
                                               code:errorCode
                                           userInfo:@{NSLocalizedDescriptionKey: unkownErrorDescription}];
    
    return unkownError;
}

@end

@interface FBMAPI ()

@property (nonatomic) ACAccountStore *accountStore;

@property (nonatomic) NSString *appID;

@property (nonatomic) ACAccount *facebookAccount;

@property (nonatomic) XMPPStream *xmppStream;

@property (nonatomic) NSURLSession *urlSession;

@end

@implementation FBMAPI

- (instancetype)initWithAppID:(NSString *)appID
{
    self = [super init];
    if (self) {
        
        self.appID = appID;
        
        self.accountStore = [[ACAccountStore alloc] init];
        
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
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
            
            NSString *description = NSLocalizedString(@"The Facebook account is not enabled", @"Account not enabled error description");
            
            NSString *suggestion = NSLocalizedString(@"Enable your Facebook account in System Preferences.", @"Account not enabled error suggestion");
            
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

-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSError *error;
    
    // SSL
    
    if (![self.xmppStream isSecure]) {
        
        if (![self.xmppStream secureConnection:&error]) {
            
            [self.delegate api:self didFinishAuthenticationWithError:error];
            
            return;
        }
    }
    else {
        
        // authenticate
        
        if (![self.xmppStream authenticateWithFacebookAccessToken:self.facebookAccount.credential.oauthToken
                                                            error:&error]) {
            
            [self.delegate api:self didFinishAuthenticationWithError:error];
            
            return;
        }
    }
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self.delegate api:self didFinishAuthenticationWithError:nil];
}

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)xmlError
{
    NSString *description = NSLocalizedString(@"Could not connect to XMPP server",
                                              @"FBMAPI XMPP Authentication error description");
    
    NSError *error = [NSError errorWithDomain:FBMErrorDomain
                                         code:FBMAPIXMPPAuthenticationErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: description}];
    
    [self.delegate api:self didFinishAuthenticationWithError:error];
}

-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    // notify self
    [self didSendMessage:message.body toUserWithJID:[message attributeStringValueForName:@"to"]];
    
    // notify delegate
    [self.delegate api:self didSendMessage:message.body toUserWithJID:[message attributeStringValueForName:@"to"] error:nil];
}

-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    // notify delegate
    [self.delegate api:self didSendMessage:message.body toUserWithJID:[message attributeStringValueForName:@"to"] error:error];
}

#pragma mark - Requests

-(NSURLSessionDataTask *)fetchInboxWithCompletionBlock:(void (^)(NSError *, NSArray *))completionBlock
{
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/inbox"];
    
    NSDictionary *parameters = @{@"access_token": self.facebookAccount.credential.oauthToken};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:parameters];
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request.preparedURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            
            completionBlock(error, nil);
            
            return;
        }
        
        // get json response
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:nil];
        
        // parse response...
        NSArray *inbox = responseDictionary[@"data"];
        
        // json error response
        if (!inbox) {
            
            NSDictionary *errorDictionary = responseDictionary[@"error"];
            
            NSNumber *errorCode = errorDictionary[@"code"];
            
            NSError *error = [self errorForErrorCode:errorCode.integerValue];
            
            completionBlock(error, nil);
            
            return;
        }
        
        // success
        
        completionBlock(nil, inbox);
        
    }];
    
    [task resume];
    
    return task;
}

-(void)sendMessage:(NSString *)messageString
     toUserWithJID:(NSString *)jid
{
    XMPPElement *body = [XMPPElement elementWithName:@"body"
                                         stringValue:messageString];
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat"
                                                     to:[XMPPJID jidWithString:jid]];
    
    [message addChild:body];
    
    [self.xmppStream sendElement:message];
}

#pragma mark - Internal

// Used by subclasses

-(void)didSendMessage:(NSString *)message
        toUserWithJID:(NSString *)jid
{
    
    
}

-(void)didRecieveMessage:(NSString *)message
         fromUserWithJID:(NSString *)jid
{
    
    
}

@end
