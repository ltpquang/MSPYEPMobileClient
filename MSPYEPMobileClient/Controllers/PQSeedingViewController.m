//
//  PQSeedingViewController.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/14/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQSeedingViewController.h"
#import <Parse.h>

@interface PQSeedingViewController ()

@end

@implementation PQSeedingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)button_TUI:(id)sender {
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"codeName" equalTo:@"hackathon"];
    [eventQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error) {
        
        PFQuery *usersQuery = [PFQuery queryWithClassName:@"_User"];
        [usersQuery whereKey:@"codeName" notEqualTo:@"ltpquang"];
        [usersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            for (int i = 0; i < 15; ++i) {
                NSString *fileName = [@(i+1) stringValue];
                UIImage * image = [UIImage imageNamed:fileName];
                //NSBitmapImageRep *imgRep = [[image representations] objectAtIndex: 0];
                NSData *data = UIImageJPEGRepresentation(image, 1.0);
                //PFUser *user = (PFUser *)objects[i];
                PFFile *file = [PFFile fileWithName:[NSString stringWithFormat:@"%@_%@.jpeg", [(PFUser *)objects[i] objectId], [object objectId]] data:data];
                
                [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    PFObject *joiningInfo = [PFObject objectWithClassName:@"JoiningInfo"];
                    joiningInfo[@"user"] = (PFUser *)objects[i];
                    joiningInfo[@"event"] = object;
                    joiningInfo[@"picture"] = file;
                    [joiningInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        NSLog(@"Completed %i", i);
                    }];
                }
                                  progressBlock:^(int percentDone) {
                                      
                                      NSLog(@"%i - %i", i, percentDone);
                                  }];
            }
            
        }];
        
    }];
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
