//
//  FacebookStore.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 4/13/13.
//  Copyright (c) 2013 ColemanCDA. All rights reserved.
//

#import "FacebookStore.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"

// app ID
const NSString *kFacebookAppID = @"317725598329762";

// asking ACAccountStore for Account
const NSInteger kErrorCodeFacebookNoAccountSetup = 401;
const NSInteger kErrorCodeFacebookAccountAccessDenied = 402;

@implementation FacebookStore

+ (FacebookStore *)sharedStore
{
    static FacebookStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}



@end
