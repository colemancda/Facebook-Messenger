//
//  FBMStore.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "FBMStore.h"

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
        
        _facebookAccount = accounts[0];
        
        completionBlock(YES);
        
    }];
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
        
        [_context performBlockAndWait:^{
            
            // parse conversations
            for (NSDictionary *conversationDictionary in inbox) {
                
                NSManagedObject *conversation = [NSEntityDescription insertNewObjectForEntityForName:@"FBConversation" inManagedObjectContext:_context];
                
                // set id
                [conversation setValue:conversationDictionary[@"id"]
                                forKey:@"id"];
                
                // get updated time
                NSDate *updatedTime = [NSDate dateFromFBDateString:conversationDictionary[@"updated_time"]];
                
                [conversation setValue:updatedTime
                                forKey:@"updatedTime"];
                
                // parse comments
                NSArray *comments = conversationDictionary[@"comments"];
                
                for (NSDictionary *commentDictionary in comments) {
                    
                    NSManagedObject *comment = [NSEntityDescription insertNewObjectForEntityForName:@"FBConversationComment" inManagedObjectContext:_context];
                    
                    NSLog(@"%@", comment);
                    
                }
                
            }
            
        }];
        
        completionBlock(nil);
        
    }];
    
}

@end
