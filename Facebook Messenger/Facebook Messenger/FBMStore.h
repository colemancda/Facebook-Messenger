//
//  FBMStore.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface FBMStore : NSObject

@property (readonly) ACAccountStore *accountStore;

@property (readonly) ACAccount *facebookAccount;

@property (readonly) NSString *appID;

@property (readonly) NSWindow *window;

@property (readonly) NSManagedObjectContext *context;

-(void)requestAccessToUserAccountsUsingAppID:(NSString *)appID
                             completionBlock:(void (^)(BOOL success))completionBlock;

#pragma mark - Requests

-(void)requestInboxWithCompletionBlock:(void (^)(NSError *error))completionBlock;


@end
