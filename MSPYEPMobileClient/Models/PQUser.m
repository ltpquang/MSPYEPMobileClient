//
//  PQUser.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/11/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQUser.h"
#import <Parse.h>

@implementation PQUser
- (id)initWithPFUser:(PFUser *)user
          andPicture:(NSString *)picture
      andConnectCode:(NSString *)connectCode {
    if (self = [super init]) {
        _userId = [user objectId];
        _name = user[@"name"];
        _codeName = user[@"codeName"];
        _picture = picture;
        _connectCode = connectCode;
        _pfUser = user;
    }
    return self;
}

@end
