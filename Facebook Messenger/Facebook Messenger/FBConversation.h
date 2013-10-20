//
//  FBConversation.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FBConversationComment, FBUser;

@interface FBConversation : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSNumber * unseen;
@property (nonatomic, retain) NSString * pagingNext;
@property (nonatomic, retain) NSString * pagingPrevious;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *to;
@end

@interface FBConversation (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(FBConversationComment *)value;
- (void)removeCommentsObject:(FBConversationComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addToObject:(FBUser *)value;
- (void)removeToObject:(FBUser *)value;
- (void)addTo:(NSSet *)values;
- (void)removeTo:(NSSet *)values;

@end
