//
//  PQPeopleTableViewCell.h
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/12/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PQUser;

@interface PQPeopleTableViewCell : UITableViewCell
- (void)configUsingUser:(PQUser *)user;
@end
