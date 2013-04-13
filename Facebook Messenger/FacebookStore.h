//
//  FacebookStore.h
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 4/13/13.
//  Copyright (c) 2013 ColemanCDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface FacebookStore : NSObject
{
    
    
}

+ (FacebookStore *)sharedStore;

#pragma mark

@property ACAccount *account;

@end
