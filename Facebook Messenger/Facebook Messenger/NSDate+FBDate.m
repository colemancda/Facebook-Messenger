//
//  NSDate+FBDate.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 12/29/13.
//  Copyright (c) 2013 CDA. All rights reserved.
//

#import "NSDate+FBDate.h"

@implementation NSDate (FBDate)

+(NSDateFormatter *)facebookDateFormatter
{
    static NSDateFormatter *facebookDateFormatter;
    if (!facebookDateFormatter) {
        
        facebookDateFormatter = [[NSDateFormatter alloc] init];
        [facebookDateFormatter setTimeStyle:NSDateFormatterFullStyle];
        [facebookDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [facebookDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
        
    }
    
    return facebookDateFormatter;
}

#pragma mark

+(NSDate *)dateFromFBDateString:(NSString *)string
{
    return [[NSDate facebookDateFormatter] dateFromString:string];
}

-(NSString *)FBDateString
{
    return [[NSDate facebookDateFormatter] stringFromDate:self];
}

@end
