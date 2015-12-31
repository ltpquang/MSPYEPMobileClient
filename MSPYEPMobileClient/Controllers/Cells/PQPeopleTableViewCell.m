//
//  PQPeopleTableViewCell.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/12/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQPeopleTableViewCell.h"
#import "PQUser.h"
#import <UIImageView+AFNetworking.h>

@interface PQPeopleTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *userCodeNameLabel;

@end

@implementation PQPeopleTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configUsingUser:(PQUser *)user {
    _userCodeNameLabel.text = [NSString stringWithFormat:@" @%@",user.codeName];
    if (user.isConnected) {
        [_userCodeNameLabel setHidden:NO];
    }
    else {
        [_userCodeNameLabel setHidden:YES];
    }
    _pictureImageView.image = nil;
    [_pictureImageView setImageWithURL:[NSURL URLWithString:user.picture]];
    
}

@end
