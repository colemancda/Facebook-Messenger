//
//  FBMStore.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBMAPI.h"

@interface FBMStore : FBMAPI

@property (readonly) NSManagedObjectContext *context;

#pragma mark - Requests

-(void)requestInboxWithCompletionBlock:(void (^)(NSError *error))completionBlock;


@end
