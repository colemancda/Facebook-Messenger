//
//  FBConversationComment.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 10/20/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FBConversation, FBUser;

@interface FBConversationComment : NSManagedObject

@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) FBConversation *conversation;
@property (nonatomic, retain) FBUser *from;

@end
