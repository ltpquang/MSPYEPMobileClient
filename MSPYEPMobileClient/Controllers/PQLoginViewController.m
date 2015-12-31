//
//  PQLoginViewController.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 4/30/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQLoginViewController.h"
#import <Parse.h>
//#import <Facebook-iOS-SDK/FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface PQLoginViewController ()

@end

@implementation PQLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButton_TUI:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"One more step"
                                                    message:@"Please input your hash name"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Register", nil];
    [alert setDelegate:self];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
    
    
}

#pragma mark - Alert view delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        NSString *codeName = [[alertView textFieldAtIndex:0] text];
        //code to connect current user with other user
        
        [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"email"]
                                                        block:^(PFUser *user, NSError *error) {
                                                            if (!user) {
                                                                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                                                                NSLog(@"%@", error);
                                                                //[_activityIndicator stopAnimating];
                                                                
                                                            } else if (user.isNew) {
                                                                NSLog(@"User signed up and logged in through Facebook!");
                                                                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
                                                                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                                    if (!error) {
                                                                        NSString *facebookId = [result objectForKey:@"id"];
                                                                        NSString *facebookEmail = [result objectForKey:@"email"];
                                                                        NSString *facebookName = [result objectForKey:@"name"];
                                                                        
                                                                        [[PFUser currentUser] setObject:facebookId forKey:@"facebookId"];
                                                                        [[PFUser currentUser] setObject:facebookEmail forKey:@"email"];
                                                                        [[PFUser currentUser] setObject:facebookName forKey:@"name"];
                                                                        [[PFUser currentUser] setObject:codeName forKey:@"codeName"];
                                                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error){
                                                                            
                                                                        }];
                                                                        
                                                                        [self dismissViewControllerAnimated:YES completion:^{
                                                                            //[_activityIndicator stopAnimating];
                                                                        }];
                                                                    }
                                                                }];
                                                            } else {
                                                                NSLog(@"User logged in through Facebook!");
                                                                
                                                                [self dismissViewControllerAnimated:YES completion:^{
                                                                    //[_activityIndicator stopAnimating];
                                                                }];
                                                            }
                                                        }];
    }
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
