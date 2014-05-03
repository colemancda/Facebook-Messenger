//
//  FBUser+Jabber.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/1/14.
//  Copyright (c) 2014 CDA. All rights reserved.
//

#import "FBUser.h"

@interface FBUser (Jabber)

+(NSNumber *)userIDFromJID:(NSString *)jid;

@property (readonly) NSString *jid;

@end
