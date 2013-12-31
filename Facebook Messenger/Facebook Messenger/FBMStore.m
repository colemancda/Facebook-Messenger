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
#import "FBMAPI.h"

@implementation FBMStore

- (id)init
{
    self = [super init];
    if (self) {
                
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"FBModel"
                                                   withExtension:@"momd"];
                
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
        
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        _context.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        _context.undoManager = nil;
        
        // initialize API
        
        _api = [[FBMAPI alloc] init];
        
    }
    return self;
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



@end
