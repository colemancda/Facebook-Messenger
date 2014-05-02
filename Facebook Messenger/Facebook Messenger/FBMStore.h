//
//  FBMStore.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBMAPI.h"
@class FBUser, FBConversation;

@interface FBMStore : FBMAPI
{
    NSManagedObjectContext *_privateContext;
    
    FBUser *_privateContextUser; // belongs to private context
}

@property (readonly, nonatomic) NSManagedObjectContext *context;

@property (readonly, nonatomic) FBUser *user;

#pragma mark - Core Data

// Returns managed objects from main queue context, completion block are called on main thread

-(void)findOrCreateConversationWithUser:(FBUser *)user
                        completionBlock:(void (^)(FBConversation *conversation))completionBlock;

-(void)findConversationWithUserWithID:(NSNumber *)userID
                      completionBlock:(void (^)(FBConversation *conversation))completionBlock;

-(void)findUserWithID:(NSNumber *)userID completionBlock:(void (^)(FBUser *user))completionBlock;

-(void)markConversationAsRead:(FBConversation *)conversation;

@end
