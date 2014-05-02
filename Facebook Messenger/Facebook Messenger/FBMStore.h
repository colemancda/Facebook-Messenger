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

-(FBConversation *)newConversationWithUser:(FBUser *)user;

@end
