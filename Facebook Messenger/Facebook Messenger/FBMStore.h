//
//  FBMStore.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FBMAPI;

@interface FBMStore : NSObject

@property (readonly) NSManagedObjectContext *context;

@property (readonly) FBMAPI *api;

#pragma mark - Cache

// entity must have id property
-(NSManagedObject *)cachedEntity:(NSString *)entityName
                          withID:(id)idObject;

#pragma mark - Requests

-(void)requestInboxWithCompletionBlock:(void (^)(NSError *error))completionBlock;


@end
