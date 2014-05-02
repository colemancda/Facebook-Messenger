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
    
    FBUser *_user; // belongs to private context
}

@property (readonly, nonatomic) NSManagedObjectContext *context;

#pragma mark - Core Data

// Returns managed objects from main queue context, completion block are called on main thread

/** Creates a new cached conversation with the specified user. */

-(void)newConversationWithUser:(FBUser *)user
               completionBlock:(void (^)(FBConversation *conversation))completionBlock;

/** Finds a user with the specified ID.
 
 @param completionBlock Returns the conversation with the user specified by the @c userID or @c nil if non was found.
 
 */

-(void)findConversationWithUserWithID:(NSNumber *)userID
                      completionBlock:(void (^)(FBConversation *conversation))completionBlock;

-(void)markConversationAsRead:(FBConversation *)conversation;

@end
