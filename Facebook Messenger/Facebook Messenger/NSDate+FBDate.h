//
//  NSDate+FBDate.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 12/29/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FBDate)

+(NSDate *)dateFromFBDateString:(NSString *)string;

-(NSString *)FBDateString;

@end
