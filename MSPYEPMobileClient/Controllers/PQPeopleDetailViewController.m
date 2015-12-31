//
//  PQPeopleDetailViewController.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/14/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQPeopleDetailViewController.h"
#import "PQUser.h"

@interface PQPeopleDetailViewController ()
@property (strong, nonatomic) PQUser *user;
@end

@implementation PQPeopleDetailViewController


#pragma mark - View controller delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _user.codeName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configUsingUser:(PQUser *)user {
    _user = user;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
