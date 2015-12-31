//
//  PQEventDetailViewController.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/3/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQEventDetailViewController.h"
#import "PQEvent.h"
#import "PQPeopleListViewController.h"
#import <DBCameraContainerViewController.h>
#import <DBCameraView.h>
#import <Parse.h>
#import <UIImageView+AFNetworking.h>

@interface PQEventDetailViewController ()
// Data
@property BOOL isCurrentUserJoined;
@property (strong, nonatomic) PQEvent *event;

// UI elements
@property MBProgressHUD *hud;

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *locatioLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation PQEventDetailViewController

#pragma mark - Controller delegates
- (void)configUsingEvent:(PQEvent *)event
andCurrentUserJoinStatus:(BOOL) isJoined {
    _event = event;
    _isCurrentUserJoined = isJoined;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self populateData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup UI
- (void)setupUI {
    [self setupJoinButton];
    [self setupCloseButton];
}

- (void)setupJoinButton {
    /*
    PFQuery *query = [PFQuery queryWithClassName:@"JoiningInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"event" equalTo:[_event pfObject]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count == 0) {
            UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] initWithTitle:@"Join"
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(joinButton_TUI:)];
            
            self.navigationItem.rightBarButtonItem = joinButton;
        }
    }];
     */
    if (!_isCurrentUserJoined) {
        UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] initWithTitle:@"Join"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(joinButton_TUI:)];
        
        self.navigationItem.rightBarButtonItem = joinButton;
    }
}

- (void)setupCloseButton {
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                              style:UIBarButtonItemStyleDone
                                                             target:self
                                                             action:@selector(closeButton_TUI:)];
    
    self.navigationItem.leftBarButtonItem = closeButton;
}

#pragma mark - Populate data
- (void)populateData {
    self.title = _event.name;
    
    [_mainImageView setImageWithURL:[NSURL URLWithString:_event.image]];
    _eventLabel.text = _event.name;
    _locatioLabel.text = _event.location;
    _addressLabel.text = _event.address;
    _descriptionLabel.text = _event.description;
    
}

#pragma mark - Table view

- (CGFloat)computeHeightForString:(NSString *)string {
    CGRect bound = [string boundingRectWithSize:CGSizeMake(292, MAXFLOAT)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName:_locatioLabel.font}
                                                               context:nil];
    return bound.size.height + 40;
}

- (CGFloat)computeNameHeight {
    CGRect bound = [_event.name boundingRectWithSize:CGSizeMake(292, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:_eventLabel.font}
                                        context:nil];
    return bound.size.height + 40;
}


#pragma mark - Setup camera
- (void)loadCamera
{
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setForceQuadCrop:YES];
    
    DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self cameraSettingsBlock:^(DBCameraView *cameraView, id container) {
        //
        [cameraView.photoLibraryButton setHidden:YES];
        [cameraView.cameraButton setHidden:YES];
        [cameraView.flashButton setHidden:YES];
    }];
    [container setCameraViewController:cameraController];
    [container setFullScreenMode];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) dismissCamera:(id)cameraViewController{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    //_hud = [[MBProgressHUD alloc] initWithView:self.view];
    //[self.view addSubview:_hud];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    _hud.delegate = self;
    _hud.labelText = @"Connecting...";
    _hud.minSize = CGSizeMake(135.f, 135.f);
    
    //[self uploadPictureAndAddNewJoiningRecordUsingImage:image];
    [self performSelectorInBackground:@selector(uploadPictureAndAddNewJoiningRecordUsingImage:) withObject:image];
}

- (void)uploadPictureAndAddNewJoiningRecordUsingImage:(UIImage *)image {
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    PFFile *file = [PFFile fileWithName:[NSString stringWithFormat:@"%@_%@.jpeg", [[PFUser currentUser] objectId], [_event eventId]] data:data];
    
    _hud.mode = MBProgressHUDModeAnnularDeterminate;
    _hud.labelText = @"Uploading...";
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = @"Having fun...";
        
        PFObject *joiningInfo = [PFObject objectWithClassName:@"JoiningInfo"];
        joiningInfo[@"user"] = [PFUser currentUser];
        joiningInfo[@"event"] = _event.pfObject;
        joiningInfo[@"picture"] = file;
        [joiningInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [joiningInfo fetchInBackgroundWithBlock:^(PFObject *object,  NSError *error) {
                [_event updateConnectCode:joiningInfo[@"connectCode"]];
                
                
                _hud.mode = MBProgressHUDModeCustomView;
                _hud.labelText = @"Completed";
                [_hud hide:YES afterDelay:1];
                NSLog(@"Completed");
                
                
                
                PQPeopleListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PeopleListView"];
                [vc configUsingEvent:_event];
                UINavigationController *presentingNavController = (UINavigationController *)[(UINavigationController *)self.navigationController presentingViewController];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                }];
                [presentingNavController showViewController:vc sender:presentingNavController];
            
            }];
            
            
        }];
    }
                      progressBlock:^(int percentDone) {
                          _hud.progress = (float)percentDone / 100;
                          if (percentDone == 100) {
                              _hud.mode = MBProgressHUDModeIndeterminate;
                              _hud.labelText = @"Having fun...";
                          }
                          NSLog(@"%i", percentDone);
                      }];
}

#pragma mark - Button handlers
- (IBAction)joinButton_TUI:(id)sender {
    [self loadCamera];
}

- (IBAction)closeButton_TUI:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (IBAction)captureButton_TUI:(id)sender {
}

- (IBAction)dismissButton_TUI:(id)sender {
}


#pragma mark - HUD delegates
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [_hud removeFromSuperview];
    _hud = nil;
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
