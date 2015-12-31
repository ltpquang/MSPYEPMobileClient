//
//  PQUser.h
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/11/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFUser;

@interface PQUser : NSObject
@property NSString *userId;
@property NSString *name;
@property NSString *codeName;
@property NSString *picture;
@property NSString *connectCode;
@property BOOL isConnected;
@property PFUser *pfUser;

- (id)initWithPFUser:(PFUser *)user andPicture:(NSString *)picture andConnectCode:(NSString *)connectCode;
@end
