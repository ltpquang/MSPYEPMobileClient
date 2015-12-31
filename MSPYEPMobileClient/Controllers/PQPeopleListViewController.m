//
//  PQPeopleListViewController.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/6/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQPeopleListViewController.h"
#import "PQEvent.h"
#import "PQUser.h"
#import "PQPeopleTableViewCell.h"
#import "PQPeopleDetailViewController.h"
#import <Parse.h>

@interface PQPeopleListViewController ()
// Data Component
@property (strong, nonatomic) PQEvent *event;
@property (strong, nonatomic) NSMutableArray *users;
// UI Component
@property (strong, nonatomic) UIRefreshControl *loadingIndicator;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation PQPeopleListViewController

#pragma mark - Controller delegates
- (void)configUsingEvent:(PQEvent *)event {
    _event = event;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"Your code: %@", _event.connectCode];
    
    [self setupData];
    
    if (_event) {
        [self setupUIComponents];
        [_loadingIndicator beginRefreshing];
        [_mainTableView setContentOffset:CGPointMake(0, _mainTableView.contentOffset.y-_loadingIndicator.frame.size.height) animated:YES];
        [self refresh];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)indexOfUserWithConnectCode:(NSString *)connectCode {
    for (int i = 0; i < _users.count; ++i) {
        if ([[(PQUser *)_users[i] connectCode] isEqualToString:connectCode]) {
            return i;
        }
    }
    return -1;
}


#pragma mark - Setup data
- (void)setupData {
    //_requestingService = [[TBRequestingService alloc] init];
    _users = [[NSMutableArray alloc] init];
}

#pragma mark - Setup UI components
- (void)setupUIComponents {
    [self setupLoadingIndicator];
    [self setupConnectButton];
}

- (void)setupLoadingIndicator {
    _loadingIndicator = [[UIRefreshControl alloc] init];
    [_mainTableView addSubview:_loadingIndicator];
    [_loadingIndicator addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)setupConnectButton {
    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Connect"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(connectButton_TUI)];
    self.navigationItem.rightBarButtonItem = connectButton;
}

- (void)connectButton_TUI {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connect"
                                                    message:@"Input your friend's code to connect"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Connect", nil];
    [alert setDelegate:self];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypePhonePad];
    [alert show];
}


#pragma mark - Loading indicator
- (void)refresh {
    
    NSLog(@"refresh");
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"JoiningInfo"];
    [[[query
       whereKey:@"event" equalTo:_event.pfObject]
      whereKey:@"user" notEqualTo:[PFUser currentUser]]
     includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            [_users removeAllObjects];
            for (PFObject *object in objects) {
                PFFile *picture = object[@"picture"];
                
                [_users addObject:[[PQUser alloc] initWithPFUser:object[@"user"]
                                                      andPicture:[picture url]
                                                  andConnectCode:object[@"connectCode"]]];
            }
            
            PFQuery *connectingQuery = [PFQuery queryWithClassName:@"ConnectingInfo"];
            [[connectingQuery
               whereKey:@"event" equalTo:_event.pfObject]
             whereKey:@"receiver" equalTo:[PFUser currentUser]];
             //includeKey:@"giver"];
            
            [connectingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error2) {
                if (!error2) {
                    NSMutableArray *objectIds = [NSMutableArray new];
                    for (int i = 0; i < _users.count; ++i) {
                        [objectIds addObject:[[_users objectAtIndex:i] userId]];
                    }
                    for (PFObject *object in objects) {
                        NSString *userId = [object[@"giver"] objectId];
                        [_users[[objectIds indexOfObject:userId]] setIsConnected:YES];
                    }
                    
                    [_mainTableView reloadData];
                    [_loadingIndicator endRefreshing];
                }
            }];
            
            
        }
        else {
            
        }
    }];
}

#pragma mark - Alert view delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        NSString *code = [[alertView textFieldAtIndex:0] text];
        //code to connect current user with other user
        NSInteger selectedIndex = [self indexOfUserWithConnectCode:code];
        if (selectedIndex != -1) {
            
            //do connect
            PQUser * selectedUser = (PQUser *)_users[selectedIndex];
            if (selectedUser.isConnected) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                                message:@"Already connected"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            //hud initializing
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            _hud.delegate = self;
            _hud.labelText = @"Connecting...";
            _hud.minSize = CGSizeMake(135.f, 135.f);
            
            
            PFObject *connectingInfo = [PFObject objectWithClassName:@"ConnectingInfo"];
            connectingInfo[@"giver"] = [selectedUser pfUser];
            connectingInfo[@"receiver"] = [PFUser currentUser];
            connectingInfo[@"event"] = [_event pfObject];
            [connectingInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                selectedUser.isConnected = YES;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Voilà"
                                                                message:@"Connected"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
                [alert show];
                [_hud hide:YES];
                [_mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectedIndex inSection:0]] withRowAnimation:NO];
                [_mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            }];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                            message:@"No user with given code"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}


#pragma mark - Table View delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.bounds.size.width;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if(tableView == self.searchDisplayController.searchResultsTableView)
    //    return _searchResult.count;
    //else
    return _users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PQPeopleTableViewCell *cell = (PQPeopleTableViewCell *)[self.mainTableView dequeueReusableCellWithIdentifier:@"PeopleCell" forIndexPath:indexPath];
    
    PQUser *user = nil;
    //if(tableView == self.searchDisplayController.searchResultsTableView)
    //    partner = [_searchResult objectAtIndex:indexPath.row];
    //else
    user = [_users objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [cell configUsingUser:user];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_mainTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PQUser *user = _users[indexPath.row];
    
    if (!user.isConnected) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Not connected, can't view"
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        PQPeopleDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PeopleDetailView"];
        [vc configUsingUser:user];
        [self showViewController:vc sender:self];
    }
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
