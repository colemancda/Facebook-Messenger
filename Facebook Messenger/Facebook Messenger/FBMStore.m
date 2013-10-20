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
                             completionBlock:(void (^)(NSError *))completionBlock
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
        
        if (error) {
            
            completionBlock(error);
            return;
        }
        
        completionBlock(nil);
        
    }];
}

-(BOOL)selectAccountUsingIdentitfier:(NSString *)identifier
{
    _facebookAccount = [_accountStore accountWithIdentifier:identifier];
    
    if (!_facebookAccount) {
        
        return NO;
    }
    
    return YES;
}


-(void)selectAccountUsingWindow:(NSWindow *)window
                completionBlock:(void (^)(BOOL))completionBlock
{
    // set values
    _window = window;
    _chooseAccountBlock = completionBlock;
    
    ACAccountType *fbAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // get accounts
    
    _accountsToChooseFrom = [_accountStore accountsWithAccountType:fbAccountType];
    
    if (!_accountsToChooseFrom ||
        !_accountsToChooseFrom.count) {
        
        completionBlock(NO);
        
        return;
    }
    
    // create prompt for user to chose
    
    _chooseAccountAlert = [[NSAlert alloc] init];
    
    _chooseAccountAlert.messageText = NSLocalizedString(@"Choose an account to use",
                                                        @"Choose Account Message");
    
    for (ACAccount *account in _accountsToChooseFrom) {
        
        [_chooseAccountAlert addButtonWithTitle:account.username];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        // alert selector will call the completion block...
        
        [_chooseAccountAlert beginSheetModalForWindow:_window
                                        modalDelegate:self
                                       didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                          contextInfo:nil];
    }];
}

#pragma mark - NSAlert Selector

- (void)alertDidEnd:(NSAlert *)alert
         returnCode:(NSInteger)returnCode
        contextInfo:(void *)contextInfo
{
    if (alert == _chooseAccountAlert) {
        
        NSInteger accountIndex = returnCode - 1000;
        
        _facebookAccount = _accountsToChooseFrom[accountIndex];
        
        // call completion block
        _chooseAccountBlock(YES);
        
        return;
    }
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
        
        // parse conversations
        for (NSDictionary *conversationDictionary in inbox) {
            
            [_context performBlockAndWait:^{
                
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
                
            }];
        }
        
        completionBlock(nil);
        
    }];
    
}

@end
