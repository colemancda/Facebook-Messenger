//
//  FBConversation+Info.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import "FBConversation+Info.h"
#import "FBUser.h"

@implementation FBConversation (Info)

-(NSString *)toString
{
    // build string
    
    NSArray *toArray = self.to.allObjects;
    
    NSString *toString = @"";
    
    for (FBUser *user in toArray) {
        
        if (user.name) {
            
            toString = [toString stringByAppendingString:user.name];
        }
        else {
            toString = [toString stringByAppendingFormat:@"%@", user.id];
        }
        
        if (user != toArray.lastObject) {
            
            toString = [toString stringByAppendingString:@", "];
        }
    }
    
    return toString;
}

-(FBUserPresence)userPresence
{
    // get user
    
    FBUser *user = self.to.allObjects.firstObject;
    
    return (FBUserPresence)user.userPresence.integerValue;
}

@end
