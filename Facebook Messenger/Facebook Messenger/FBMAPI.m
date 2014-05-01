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

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)xmlError
{
    NSString *description = NSLocalizedString(@"Could not connect to XMPP server",
                                              @"FBMAPI XMPP Authentication error description");
    
    NSError *error = [NSError errorWithDomain:FBMErrorDomain
                                         code:FBMAPIXMPPAuthenticationErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: description}];
    
    [self.delegate api:self didFinishAuthenticationWithError:error];
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self.delegate api:self didFinishAuthenticationWithError:nil];
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
        
        
        
    }];
    
    return task;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        // error
        if (error) {
            completionBlock(error);
            return;
        }
        
        // get json response
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        
        // parse response...
        NSArray *inbox = response[@"data"];
        
        NSMutableArray *inbox = [[NSMutableArray alloc] init];
        
        // json error response
        if (!inbox) {
            
            NSDictionary *errorDictionary = response[@"error"];
            
            NSNumber *errorCode = errorDictionary[@"code"];
            
            NSError *error = [self errorForErrorCode:errorCode.integerValue];
            
            completionBlock(error);
            
            return;
        }
        
        // parse...
        [_context performBlockAndWait:^{
            
            // parse conversations
            for (NSDictionary *conversationDictionary in inbox) {
                
                // get id
                NSString *conversationIDString = conversationDictionary[@"id"];
                NSNumber *conversationID = [NSNumber numberWithInteger:conversationIDString.integerValue];
                
                // search store and find cache
                FBConversation *conversation = (FBConversation *)[self cachedEntity:@"FBConversation"
                                                                             withID:conversationID];
                
                // get updated time
                conversation.updatedTime = [NSDate dateFromFBDateString:conversationDictionary[@"updated_time"]];
                
                // get unread and unseen
                conversation.unread = conversationDictionary[@"unread"];
                
                conversation.unseen = conversationDictionary[@"unseen"];
                
                // parse 'to' relationship
                NSDictionary *toDictionary = conversationDictionary[@"to"];
                
                NSArray *toArray = toDictionary[@"data"];
                
                NSMutableSet *conversationUsers = [[NSMutableSet alloc] init];
                
                for (NSDictionary *userDictionary in toArray) {
                    
                    // get user id
                    NSString *userIDString = userDictionary[@"id"];
                    NSNumber *userID = [NSNumber numberWithInteger:userIDString.integerValue];
                    
                    FBUser *user = (FBUser *)[self cachedEntity:@"FBUser"
                                                         withID:userID];
                    
                    user.name = userDictionary[@"name"];
                    
                    [conversationUsers addObject:user];
                }
                
                // replace 'to' relationship
                [conversation setValue:conversationUsers
                                forKey:@"to"];
                
                
                // parse comments...
                NSDictionary *commentsDictionary = conversationDictionary[@"comments"];
                
                // get paging
                NSDictionary *pagingDictionary = commentsDictionary[@"paging"];
                
                conversation.pagingNext = pagingDictionary[@"next"];
                
                conversation.pagingPrevious = pagingDictionary[@"previous"];
                
                NSArray *comments = commentsDictionary[@"data"];
                
                NSMutableSet *conversationComments = [[NSMutableSet alloc] init];
                
                for (NSDictionary *commentDictionary in comments) {
                    
                    // get ID
                    
                    NSString *commentID = commentDictionary[@"id"];
                    
                    FBConversationComment *comment = (FBConversationComment *)[self cachedEntity:@"FBConversationComment" withID:commentID];
                    
                    // set values...
                    
                    comment.createdTime = [NSDate dateFromFBDateString:commentDictionary[@"created_time"]];
                    
                    comment.message = commentDictionary[@"message"];
                    
                    if (!commentDictionary[@"message"]) {
                        
                        comment.message = @"";
                    }
                    
                    // parse 'from'
                    NSDictionary *fromDictionary = commentDictionary[@"from"];
                    
                    NSString *fromUserIDString = fromDictionary[@"id"];
                    NSNumber *fromUserID = [NSNumber numberWithInteger:fromUserIDString.integerValue];
                    
                    FBUser *fromUser = (FBUser *)[self cachedEntity:@"FBUser"
                                                             withID:fromUserID];
                    
                    comment.from = fromUser;
                    
                    [conversationComments addObject:comment];
                    
                }
                
                // replace collection
                [conversation setValue:conversationComments
                                forKey:@"comments"];
                
                
            }
        
    }];
    
}

@end
