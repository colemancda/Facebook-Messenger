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
#import "NSDate+FBDate.h"

@interface FBMStore (Cache)

// Must save context after using this

-(NSManagedObject *)findOrCreateEntity:(NSString *)entityName
                                withID:(id)identifier;

@end

@interface FBMStore ()

@property (nonatomic) NSManagedObjectContext *context;

@end

@implementation FBMStore

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithAppID:(NSString *)appID
{
    self = [super initWithAppID:appID];
    
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
        
        self.context.persistentStoreCoordinator = _privateContext.persistentStoreCoordinator;
        
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

-(NSURLSessionDataTask *)fetchInboxWithCompletionBlock:(void (^)(NSError *, NSArray *))completionBlock
{
    return [super fetchInboxWithCompletionBlock:^(NSError *error, NSArray *inbox) {
        
        // error
        if (error) {
            
            completionBlock(error, nil);
            
            return;
        }
        
        NSMutableArray *cachedInbox = [[NSMutableArray alloc] init];
        
        // parse...
        [_privateContext performBlockAndWait:^{
            
            // parse conversations
            for (NSDictionary *conversationDictionary in inbox) {
                
                // get id
                NSString *conversationIDString = conversationDictionary[@"id"];
                
                NSNumber *conversationID = [NSNumber numberWithInteger:conversationIDString.integerValue];
                
                // make sure the conversation has a to and from user
                
                NSDictionary *toDictionary = conversationDictionary[@"to"];
                
                NSArray *toArray = toDictionary[@"data"];
                
                if (toArray.count < 2) {
                    
                    // skip this conversation
                    
                    continue;
                }
                
                // search store and find cache
                
                FBConversation *conversation = (FBConversation *)[self findOrCreateEntity:@"FBConversation"
                                                                                   withID:conversationID];
                // add to completion block array
                
                [cachedInbox addObject:conversation];
                
                // get updated time
                
                conversation.updatedTime = [NSDate dateFromFBDateString:conversationDictionary[@"updated_time"]];
                
                // get unread and unseen
                
                conversation.unread = conversationDictionary[@"unread"];
                
                conversation.unseen = conversationDictionary[@"unseen"];
                
                // parse 'to' relationship
                
                NSMutableSet *conversationUsers = [[NSMutableSet alloc] init];
                
                for (NSDictionary *userDictionary in toArray) {
                    
                    // get user id
                    NSString *userIDString = userDictionary[@"id"];
                    NSNumber *userID = [NSNumber numberWithInteger:userIDString.integerValue];
                    
                    FBUser *user = (FBUser *)[self findOrCreateEntity:@"FBUser"
                                                               withID:userID];
                    
                    user.name = userDictionary[@"name"];
                    
                    [conversationUsers addObject:user];
                }
                
                // replace 'to' relationship
                [conversation setValue:conversationUsers
                                forKey:@"to"];
                
                
                // parse comments...
                NSDictionary *commentsDictionary = conversationDictionary[@"comments"];
                
                // get paging
                NSDictionary *pagingDictionary = commentsDictionary[@"paging"];
                
                conversation.pagingNext = pagingDictionary[@"next"];
                
                conversation.pagingPrevious = pagingDictionary[@"previous"];
                
                NSArray *comments = commentsDictionary[@"data"];
                
                NSMutableSet *conversationComments = [[NSMutableSet alloc] init];
                
                for (NSDictionary *commentDictionary in comments) {
                    
                    // get ID
                    
                    NSString *commentID = commentDictionary[@"id"];
                    
                    FBConversationComment *comment = (FBConversationComment *)[self findOrCreateEntity:@"FBConversationComment"
                                                                                                withID:commentID];
                    
                    // set values...
                    
                    comment.createdTime = [NSDate dateFromFBDateString:commentDictionary[@"created_time"]];
                    
                    comment.message = commentDictionary[@"message"];
                    
                    if (!commentDictionary[@"message"]) {
                        
                        comment.message = @"";
                    }
                    
                    // parse 'from'
                    NSDictionary *fromDictionary = commentDictionary[@"from"];
                    
                    NSString *fromUserIDString = fromDictionary[@"id"];
                    NSNumber *fromUserID = [NSNumber numberWithInteger:fromUserIDString.integerValue];
                    
                    FBUser *fromUser = (FBUser *)[self findOrCreateEntity:@"FBUser"
                                                                   withID:fromUserID];
                    
                    comment.from = fromUser;
                    
                    [conversationComments addObject:comment];
                    
                }
                
                // replace collection
                [conversation setValue:conversationComments
                                forKey:@"comments"];
                
                
            }
            
            // save
            
            NSError *error;
            
            if (![_privateContext save:&error]) {
                
                [NSException raise:NSInternalInconsistencyException
                            format:@"%@", error];
            }
            
        }];
        
        completionBlock(nil, cachedInbox);
        
    }];
}

@end

#pragma mark - Categories

@implementation FBMStore (Cache)

-(NSManagedObject *)findOrCreateEntity:(NSString *)entityName
                                withID:(id)identifier
{
    // get cached resource...
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    fetchRequest.fetchLimit = 1;
    
    // create predicate
    
    fetchRequest.predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"id"]
                                                                rightExpression:[NSExpression expressionForConstantValue:identifier]
                                                                       modifier:NSDirectPredicateModifier
                                                                           type:NSEqualToPredicateOperatorType
                                                                        options:NSNormalizedPredicateOption];
    
    fetchRequest.returnsObjectsAsFaults = NO;
    
    // fetch
    
    NSManagedObject *managedObject;
    
    NSError *error;
    
    NSArray *results = [_privateContext executeFetchRequest:fetchRequest
                                                      error:&error];
    
    if (error) {
        
        [NSException raise:@"Error executing NSFetchRequest"
                    format:@"%@", error.localizedDescription];
        
        return nil;
    }
    
    managedObject = results.firstObject;
    
    // create cached resource if not found
    
    if (!managedObject) {
        
        // create new entity
        
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                      inManagedObjectContext:_privateContext];
        
        // set resource ID
        
        [managedObject setValue:identifier
                    forKey:@"id"];
        
    }
    
    return managedObject;
}

@end