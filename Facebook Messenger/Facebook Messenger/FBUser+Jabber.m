//
//  FBUser+Jabber.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/1/14.
//  Copyright (c) 2014 CDA. All rights reserved.
//

#import "FBUser+Jabber.h"

@implementation FBUser (Jabber)

+(NSNumber *)userIDFromJID:(NSString *)jid
{
    // take apart JID
    
    NSString *userID;
    
    userID = [jid stringByReplacingOccurrencesOfString:@"@chat.facebook.com"
                                              withString:@""];
    
    userID = [userID stringByReplacingOccurrencesOfString:@"-"
                                               withString:@""];
    
    return [NSNumber numberWithInteger:userID.integerValue];
}

-(NSString *)jid
{
    return [NSString stringWithFormat:@"-%@@chat.facebook.com", self.id];
}

@end
