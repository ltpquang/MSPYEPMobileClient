//
//  PQEvent.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/1/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQEvent.h"
#import <Parse.h>
#import "PQConstantKey.h"

@implementation PQEvent
- (id)initWithPFObject:(PFObject *)object {
    if (self = [super init]) {
        _eventId            = [object objectId];
        _name               = object[kName];
        _codeName           = object[kCodeName];
        _eventDescription   = object[kDescription];
        _location           = object[kLocation];
        _address            = object[kAddress];
        _organizer          = object[kOrganizer];
        _organizerLogo      = object[kOrganizerLogo];
        _website            = object[kWebsite];
        _image              = object[kImage];
        _pfObject           = object;
    }
    return self;
}

- (void)updateConnectCode:(NSString *)connectCode {
    _connectCode = connectCode;
}

- (void)updateConnectCodeOfCurrentUserWithBlock:(void(^)(NSError *error))completeCall {
    PFQuery *query = [PFQuery queryWithClassName:@"JoiningInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"event" equalTo:_pfObject];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error) {
        if (!error) {
            _connectCode = object[@"connectCode"];
        }
        completeCall(error);
    }];
}
@end
