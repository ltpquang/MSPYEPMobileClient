//
//  MSPYEPMobileClientTests.m
//  MSPYEPMobileClientTests
//
//  Created by Le Thai Phuc Quang on 4/29/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Parse.h>

@interface MSPYEPMobileClientTests : XCTestCase

@end

@implementation MSPYEPMobileClientTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)uploadJoiningInfo {
    XCTAssert(YES, @"P");
}

- (void)testExample {
    // This is an example of a functional test case.
    [Parse setApplicationId:@"jhi4AwCRuUBS8JR1WrBQQKvX5ovzNWBSWGuHa7cW"
                  clientKey:@"PfFFsbbgSHVLIVKbwIW2TEQGOTcAjtRTDw2FX1rf"];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"codeName" equalTo:@"hackathon"];
    [eventQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error) {
        
        PFQuery *usersQuery = [PFQuery queryWithClassName:@"User"];
        [usersQuery whereKey:@"codeName" notEqualTo:@"ltpquang"];
        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            for (int i = 0; i < 15; ++i) {
                NSString *fileName = [@(i+1) stringValue];
                NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:fileName], 1.0);
                PFFile *file = [PFFile fileWithName:[NSString stringWithFormat:@"%@_%@.jpeg", (PFUser *)objects[i], [object objectId]] data:data];
                
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
                                      
                                      NSLog(@"%i", percentDone);
                                  }];
            }
            
        }];
        
    }];
    
    XCTAssert(YES, @"Pass");
}


@end
