//
//  PQEventDetailViewController.h
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/3/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DBCameraViewController.h>
#import <MBProgressHUD.h>

@class PQEvent;

@interface PQEventDetailViewController : UIViewController <DBCameraViewControllerDelegate, MBProgressHUDDelegate>
- (void)configUsingEvent:(PQEvent *)event
andCurrentUserJoinStatus:(BOOL) isJoined;
@end
