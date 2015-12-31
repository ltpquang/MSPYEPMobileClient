//
//  PQEvent.h
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/1/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFObject;

@interface PQEvent : NSObject
@property NSString *eventId;
@property NSString *name;
@property NSString *codeName;
@property NSString *eventDescription;
@property NSString *location;
@property NSString *address;
@property NSString *organizer;
@property NSString *organizerLogo;
@property NSString *website;
@property NSString *image;
@property NSString *connectCode;
@property PFObject *pfObject;

- (id)initWithPFObject:(PFObject *)object;
- (void)updateConnectCodeOfCurrentUserWithBlock:(void(^)(NSError *error))completeCall;
- (void)updateConnectCode:(NSString *)connectCode;
@end
