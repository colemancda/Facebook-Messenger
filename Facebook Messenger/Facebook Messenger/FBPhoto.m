//
//  FBPhoto.m
//  Facebook Messenger
//
//  Created by Alsey Coleman Miller on 5/3/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

#import "FBPhoto.h"
#import "FBUser.h"


@implementation FBPhoto

@dynamic data;
@dynamic user;

@synthesize image = _image;

-(NSImage *)image
{
    if (!_image && self.data) {
        
        _image = [[NSImage alloc] initWithData:self.data];
    }
    
    return _image;
}

@end
