//
//  PQEventListViewController.h
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 4/30/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQEventJoiningType.h"

@class PQEvent;

@interface PQEventListViewController : UIViewController
@property (strong, nonatomic) PQEvent *toPassEvent;
@end
