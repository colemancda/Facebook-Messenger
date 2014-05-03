//
//  FBConversation+Info.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import "FBConversation.h"
#import "FBMAPI.h"

@interface FBConversation (Info)

@property (readonly) NSString *toString;

@property (readonly) FBUserPresence userPresence;

@end
