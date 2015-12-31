//
//  PQEventTableViewCell.m
//  MSPYEPMobileClient
//
//  Created by Le Thai Phuc Quang on 5/1/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQEventTableViewCell.h"
#import "PQEvent.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface PQEventTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *gradientView;

@property BOOL gradientSet;
@end

@implementation PQEventTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    if (!_gradientSet) {
//        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//        gradientLayer.frame = _gradientView.bounds;
//        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor,(id)[UIColor redColor].CGColor, nil];
//        gradientLayer.startPoint = CGPointMake(0.25f, 0.25f);
//        gradientLayer.endPoint = CGPointMake(1.0f, 1.0f);
//        _gradientView.layer.mask = gradientLayer;
//        _gradientSet = YES;
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellUsingEvent:(PQEvent *)event {
    
    //CAGradientLayer *bgLayer = [self blackGradient];
    //bgLayer.frame = _gradientView.bounds;
    //[_gradientView.layer insertSublayer:bgLayer atIndex:0];
    
    
    _nameLabel.text = [NSString stringWithFormat:@" #%@ ", event.codeName];
    _mainImage.image = nil;
    [_mainImage setImageWithURL:[NSURL URLWithString:event.image]];
}

@end
