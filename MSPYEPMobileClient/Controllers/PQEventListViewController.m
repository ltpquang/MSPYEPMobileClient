//
//  PQEventListViewController.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 4/30/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQEventListViewController.h"
#import "PQEventTableViewController.h"
#import "PQLoginViewController.h"
#import "PQEvent.h"
#import "PQEventDetailViewController.h"
#import <Parse.h>

@interface PQEventListViewController ()
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic) BOOL setupDone;
@property (weak, nonatomic) IBOutlet UIView *containingView;
@end

@implementation PQEventListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkLogin];
    if ([PFUser currentUser] && !_setupDone) {
        [self firstTimeSetupViewControllers];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewWillLayoutSubviews {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login check
- (void)checkLogin {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"%@", currentUser.objectId);
    } else {
        //load login
        PQLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self presentViewController:loginVC animated:YES completion:^{
            //
        }];
    }
}

- (void)firstTimeSetupViewControllers {
    _viewControllers = @[
                         [[self.storyboard instantiateViewControllerWithIdentifier:@"EventTableViewController"] withJoiningType:PQEventJoiningTypeAll],
                         [[self.storyboard instantiateViewControllerWithIdentifier:@"EventTableViewController"] withJoiningType:PQEventJoiningTypeJoined]
                         ];
    [self presentTableViewVC:[_viewControllers objectAtIndex:0]];
    _setupDone = YES;
}



- (void)transitionFromViewController:(UIViewController *)fromViewController
                    toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = fromViewController.view.bounds;                           //  1
    [self addChildViewController:toViewController];                                     //
    [fromViewController willMoveToParentViewController:nil];                            //
    
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:0.4
                               options:UIViewAnimationOptionTransitionNone
                            animations:nil
                            completion:^(BOOL finished) {
                                [toViewController didMoveToParentViewController:self];  //  2
                                [fromViewController removeFromParentViewController];    //  3
                                _currentViewController = (UIViewController *)toViewController;
                            }];
}

- (void)presentTableViewVC:(UIViewController *)tableViewVC {
    if (_currentViewController) {
        [self removeCurrentTableViewVC];
    }
    
    [self addChildViewController:tableViewVC];
    
    [tableViewVC.view setFrame:[self frameForTableViewVC]];
    //[self.view addSubview:tableViewVC.view];
    [_containingView addSubview:tableViewVC.view];
    _currentViewController = tableViewVC;
    
    [tableViewVC didMoveToParentViewController:self];
}

- (void)removeCurrentTableViewVC {
    [_currentViewController willMoveToParentViewController:nil];
    [_currentViewController.view removeFromSuperview];
    [_currentViewController removeFromParentViewController];
}

- (CGRect)frameForTableViewVC {
    //return self.view.bounds;
    return _containingView.bounds;
}

- (IBAction)segmentedControl_ValueChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self transitionFromViewController:_currentViewController toViewController:[_viewControllers objectAtIndex:0]];
            break;
        case 1:
            [self transitionFromViewController:_currentViewController toViewController:[_viewControllers objectAtIndex:1]];
            break;
        default:
            break;
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.if ([segue.identifier isEqualToString:@"GoToEventDetailSegue"]) {
//    if ([segue.identifier isEqualToString:@"GoToEventDetailSegue"]) {
//        PQEventDetailViewController *vc = (PQEventDetailViewController *)[[segue.destinationViewController childViewControllers] objectAtIndex:0];
//        [vc configUsingEvent:_toPassEvent andCurrentUserJoinStatus:YES];
//    }

}


@end
