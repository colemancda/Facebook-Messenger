//
//  FBMStore.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "FBMStore.h"
#import "FBUser.h"
#import "FBConversation.h"
#import "FBConversationComment.h"

static NSString *ErrorDomain = @"com.ColemanCDA.Facebook-Messenger.ErrorDomain";

@implementation NSDate (FacebookDate)

+(NSDateFormatter *)facebookDateFormatter
{
    static NSDateFormatter *facebookDateFormatter;
    if (!facebookDateFormatter) {
        
        facebookDateFormatter = [[NSDateFormatter alloc] init];
        [facebookDateFormatter setTimeStyle:NSDateFormatterFullStyle];
        [facebookDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [facebookDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
        
    }
    
    return facebookDateFormatter;
}

+(NSDate *)dateFromFBDateString:(NSString *)string
{
    return [[NSDate facebookDateFormatter] dateFromString:string];
}

-(NSString *)FBDateString
{
    return [[NSDate facebookDateFormatter] stringFromDate:self];
}

@end

@implementation FBMStore (Errors)

-(NSError *)errorForErrorCode:(NSInteger)errorCode
{
    
    
    // unkown error
    
    NSString *unkownErrorDescription = NSLocalizedString(@"An unkown error occurred",
                                                         @"Unkown Error Message");
    
    NSError *unkownError = [NSError errorWithDomain:ErrorDomain
                                               code:errorCode
                                           userInfo:@{NSLocalizedDescriptionKey: unkownErrorDescription}];
    
    return unkownError;
}

@end

@implementation FBMStore

- (id)init
{
    self = [super init];
    if (self) {
        
        _accountStore = [[ACAccountStore alloc] init];
        
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"FBModel"
                                                   withExtension:@"momd"];
                
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
        
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        _context.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        _context.undoManager = nil;
        
    }
    return self;
}

-(void)requestAccessToUserAccountsUsingAppID:(NSString *)appID
                             completionBlock:(void (^)(BOOL))completionBlock
{
    _appID = appID;
    
    NSArray *fbPermissions = @[@"read_mailbox",
                               @"friends_online_presence",
                               @"user_about_me",
                               @"user_online_presence",
                               @"xmpp_login"];
    
    NSDictionary *accessOptions = @{ACFacebookAppIdKey: _appID,
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

#pragma mark - Cache

-(NSManagedObject *)cachedEntity:(NSString *)entityName
                          withID:(id)idObject
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    fetch.predicate = [NSPredicate predicateWithFormat:@"id == %@", idObject];
    
    NSError *fetchError;
    NSArray *result = [_context executeFetchRequest:fetch
                                              error:&fetchError];
    
    if (!result) {
        
        [NSException raise:@"Error Executing Core Data NSFetchRequest"
                    format:@"%@", fetchError.localizedDescription];
        
        return nil;
    }
    
    NSManagedObject *entity;
    
    // not found, create new one
    if (!result.count) {
        
        entity = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                               inManagedObjectContext:_context];
        
        [entity setValue:idObject
                  forKey:@"id"];
        
    }
    
    // found cached object
    else {
        
        entity = result[0];
    }
    
    return entity;
}

#pragma mark - Requests

-(void)requestInboxWithCompletionBlock:(void (^)(NSError *))completionBlock
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
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        
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
                
                // get paging
                NSDictionary *pagingDictionary = conversationDictionary[@"paging"];
                
                conversation.pagingNext = pagingDictionary[@"next"];
                
                conversation.pagingPrevious = pagingDictionary[@"previous"];
                
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
                
                NSArray *comments = commentsDictionary[@"data"];
                
                NSMutableSet *conversationComments = [[NSMutableSet alloc] init];
                
                for (NSDictionary *commentDictionary in comments) {
                    
                    // get ID
                    
                    NSString *commentID = commentDictionary[@"id"];
                    
                    FBConversationComment *comment = (FBConversationComment *)[self cachedEntity:@"FBConversationComment" withID:commentID];
                    
                    // set values...
                    
                    comment.createdTime = [NSDate dateFromFBDateString:commentDictionary[@"created_time"]];
                    
                    comment.message = commentDictionary[@"message"];
                    
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
    
}

@end
