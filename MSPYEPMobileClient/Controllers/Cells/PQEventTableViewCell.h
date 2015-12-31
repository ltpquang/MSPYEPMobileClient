//
//  PQEventTableViewCell.h
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/1/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PQEvent;

@interface PQEventTableViewCell : UITableViewCell
- (void)configCellUsingEvent:(PQEvent *)event;
@end
