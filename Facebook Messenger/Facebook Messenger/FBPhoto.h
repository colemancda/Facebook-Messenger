//
//  FBPhoto.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FBUser;

@interface FBPhoto : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) FBUser *user;

@property (nonatomic, readonly) NSImage *image;

@end
