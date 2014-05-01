//
//  FBUser+Jabber.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/1/14.
//  Copyright (c) 2014 CDA. All rights reserved.
//

#import "FBUser+Jabber.h"

@implementation FBUser (Jabber)

-(NSString *)jid
{
    return [NSString stringWithFormat:@"-%@@chat.facebook.com", self.id];
}

@end
