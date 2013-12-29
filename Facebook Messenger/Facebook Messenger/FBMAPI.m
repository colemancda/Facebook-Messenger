//
//  FBMAPI.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 12/29/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "FBMAPI.h"

NSString *const FBMAppID = @"221240951333308";

@implementation FBMAPI

- (id)init
{
    self = [super init];
    if (self) {
        
        _accountStore = [[ACAccountStore alloc] init];
        
    }
    return self;
}

#pragma mark - Authenticate

-(void)loginWithCompletion:(void (^)(BOOL *))completionBlock
{
    NSArray *fbPermissions = @[@"read_mailbox",
                               @"friends_online_presence",
                               @"user_about_me",
                               @"user_online_presence",
                               @"xmpp_login"];
    
    NSDictionary *accessOptions = @{ACFacebookAppIdKey: FBMAppID,
                                    ACFacebookPermissionsKey : fbPermissions};
    
    
    ACAccountType *fbAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // request access to accounts
    
    [_accountStore requestAccessToAccountsWithType:fbAccountType options:accessOptions completion:^(BOOL granted, NSError *error) {
        
        // access denied
        if (!granted) {
            
            completionBlock(NO);
            return;
        }
        
        NSArray *accounts = [_accountStore accountsWithAccountType:fbAccountType];
        
        // account exists but is not enabled
        if (!accounts.count) {
            
            completionBlock(NO);
            return;
        }
        
        // can only have one FB account in OS X
        
        ACAccount *facebookAccount = accounts[0];
        
        // renew credentials
        [_accountStore renewCredentialsForAccount:facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
            
            if (renewResult != ACAccountCredentialRenewResultRenewed) {
                
                completionBlock(NO);
                
                return;
            }
            
            // store account
            _facebookAccount = facebookAccount;
            
            completionBlock(YES);
        }];
    }];
    
}

#pragma mark - Request

-(SLRequest *)requestInboxWithCompletionBlock:(void (^)(NSError *, NSArray *))completionBlock
{
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/inbox"];
    
    NSDictionary *parameters = @{@"access_token": self.facebookAccount.credential.oauthToken};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:parameters];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        // error
        if (error) {
            completionBlock(error);
            return;
        }
        
        // get json response
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
        
        // parse response...
        NSArray *inbox = response[@"data"];
        
        // json error response
        if (!inbox) {
            
            NSDictionary *errorDictionary = response[@"error"];
            
            NSNumber *errorCode = errorDictionary[@"code"];
            
            NSError *error = [self errorForErrorCode:errorCode.integerValue];
            
            completionBlock(error);
            
            return;
        }
        
        // check for invalid JSON...
        
        // parse conversations
        for (NSDictionary *conversationDictionary in inbox) {
            
            // get id
            NSString *conversationIDString = conversationDictionary[@"id"];
            
            if (!conversationIDString) {
                
                completionBlock([self errorForErrorCode:0]);
                
                return;
            }
            
            // get updated time
            NSDate *updated = [NSDate dateFromFBDateString:conversationDictionary[@"updated_time"]];
            
            // get unread and unseen
            NSNumber *unread = conversationDictionary[@"unread"];
            
            NSNumber *unseen = conversationDictionary[@"unseen"];
            
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
            
            
            // if any value is invalid
            
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
        
        completionBlock(nil);
        
    }];
    
    return request;
}

@end
