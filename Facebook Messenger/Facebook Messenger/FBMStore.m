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

@interface FBMStore ()

@property (nonatomic) NSManagedObjectContext *context;

@end

@implementation FBMStore

- (id)init
{
    self = [super init];
    if (self) {
                
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"FBModel"
                                                   withExtension:@"momd"];
                
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
        
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        _privateContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        _privateContext.undoManager = nil;
        
        [_privateContext.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                 configuration:nil
                                                                           URL:nil
                                                                       options:nil
                                                                         error:nil];
        
        // add main queue context
        
        self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        self.context.undoManager = nil;
        
        self.context.persistentStoreCoordinator = self.context.persistentStoreCoordinator;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mergeChangesFromContextDidSaveNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:_privateContext];
        
        
    }
    return self;
}

#pragma mark - Merge Context

-(void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification
{
    [self.context performBlock:^{
       
        [self.context mergeChangesFromContextDidSaveNotification:notification];
        
    }];
}

#pragma mark - Requests



@end
