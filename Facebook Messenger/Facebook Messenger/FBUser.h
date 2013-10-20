//
//  FBUser.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FBConversation, FBConversationComment;

@interface FBUser : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) FBConversation *conversationsTo;
@property (nonatomic, retain) NSSet *conversationComments;
@end

@interface FBUser (CoreDataGeneratedAccessors)

- (void)addConversationCommentsObject:(FBConversationComment *)value;
- (void)removeConversationCommentsObject:(FBConversationComment *)value;
- (void)addConversationComments:(NSSet *)values;
- (void)removeConversationComments:(NSSet *)values;

@end
