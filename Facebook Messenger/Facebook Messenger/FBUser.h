//
//  FBUser.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FBConversation, FBConversationComment, FBPhoto;

@interface FBUser : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * userPresence;
@property (nonatomic, retain) NSSet *conversationComments;
@property (nonatomic, retain) FBConversation *conversationsTo;
@property (nonatomic, retain) FBPhoto *profilePicture;
@end

@interface FBUser (CoreDataGeneratedAccessors)

- (void)addConversationCommentsObject:(FBConversationComment *)value;
- (void)removeConversationCommentsObject:(FBConversationComment *)value;
- (void)addConversationComments:(NSSet *)values;
- (void)removeConversationComments:(NSSet *)values;

@end
