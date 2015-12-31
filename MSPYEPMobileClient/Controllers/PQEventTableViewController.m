//
//  PQEventTableViewController.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 4/30/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQEventTableViewController.h"
#import <Parse.h>
#import "PQEvent.h"
#import "PQEventTableViewCell.h"
#import "PQEventDetailViewController.h"
#import "PQEventListViewController.h"
#import "PQPeopleListViewController.h"

@interface PQEventTableViewController ()

// Data
@property (nonatomic) PQEventJoiningType joiningType;
@property (strong, nonatomic) NSMutableArray *events;
//@property (strong, nonatomic) PQEvent *toPassEvent;

// UI Component
@property (strong, nonatomic) UIRefreshControl *loadingIndicator;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) MBProgressHUD *hud;
@end


#pragma mark - Controller delegates
@implementation PQEventTableViewController

- (id)withJoiningType:(PQEventJoiningType) joiningType {
    _joiningType = joiningType;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupData];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser && (_events == nil || _events.count == 0)) {
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

- (void)viewDidAppear:(BOOL)animated {
    
    
}

#pragma mark - Setup data
- (void)setupData {
    //_requestingService = [[TBRequestingService alloc] init];
    _events = [[NSMutableArray alloc] init];
}

#pragma mark - Setup UI components
- (void)setupUIComponents {
    [self setupLoadingIndicator];
}

- (void)setupLoadingIndicator {
    _loadingIndicator = [[UIRefreshControl alloc] init];
    [_mainTableView addSubview:_loadingIndicator];
    [_loadingIndicator addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Loading indicator
- (void)refresh {
    
    NSLog(@"refresh");
    
    
    PFQuery *query;
    
    if (_joiningType == PQEventJoiningTypeAll) {
        query = [PFQuery queryWithClassName:@"Event"];
    } else {
        query = [PFQuery queryWithClassName:@"JoiningInfo"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query includeKey:@"event"];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            [_events removeAllObjects];
            if (_joiningType == PQEventJoiningTypeAll) {
                for (PFObject *object in objects) {
                    [_events addObject:[[PQEvent alloc] initWithPFObject:object]];
                }
            } else {
                for (PFObject *object in objects) {
                    [_events addObject:[[PQEvent alloc] initWithPFObject:object[@"event"]]];
                }
            }
            [_mainTableView reloadData];
            [_loadingIndicator endRefreshing];
        }
        else {
            
        }
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if(tableView == self.searchDisplayController.searchResultsTableView)
    //    return _searchResult.count;
    //else
    return _events.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PQEventTableViewCell *cell = (PQEventTableViewCell *)[self.mainTableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    
    PQEvent *event = nil;
    //if(tableView == self.searchDisplayController.searchResultsTableView)
    //    partner = [_searchResult objectAtIndex:indexPath.row];
    //else
    event = [_events objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [cell configCellUsingEvent:event];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    _hud.delegate = self;
    _hud.labelText = @"Checking...";
    _hud.minSize = CGSizeMake(135.f, 135.f);
    
    PFQuery *query = [PFQuery queryWithClassName:@"JoiningInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"event" equalTo:[[_events objectAtIndex:indexPath.row] pfObject]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [_hud hide:YES];
        if (objects.count == 0) {
            PQEventDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailView"];
            [vc configUsingEvent:[_events objectAtIndex:indexPath.row] andCurrentUserJoinStatus:NO];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [[nc navigationBar] setTintColor:[UIColor colorWithRed:238.0/255.0 green:44.0/255.0 blue:141.0/255.0 alpha:1.0]];
            [[nc navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:238.0/255.0 green:44.0/255.0 blue:141.0/255.0 alpha:1.0]}];
            [self.parentViewController presentViewController:nc animated:YES completion:nil];
        }
        else {
            PQEvent *selectedEvent = _events[indexPath.row];
            [selectedEvent updateConnectCode:(objects[0])[@"connectCode"]];
            PQPeopleListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PeopleListView"];
            [vc configUsingEvent:[_events objectAtIndex:indexPath.row]];
            [self.parentViewController showViewController:vc sender:self.parentViewController];
        }
    }];
    
    
    //NSLog(@"%@", self.parentViewController);
}

#pragma mark - HUD delegates
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [_hud removeFromSuperview];
    _hud = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end
