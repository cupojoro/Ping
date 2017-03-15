//
//  PGErrorView.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGErrorView.h"

#import "Masonry.h"

@interface PGErrorView ()

@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *sectionalView;
@property (nonatomic, strong) UIButton *dismissButton;

@end

@implementation PGErrorView

-(id)initWithError:(NSString *)message
{
    self = [super init];
    
    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = YES;
    
    self.infoLabel = [[UILabel alloc] init];
    [self.infoLabel setText:message];
    [self.infoLabel setTextAlignment:NSTextAlignmentCenter];
    [self.infoLabel setTextColor:[UIColor darkGrayColor]];
    [self.infoLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self addSubview:self.infoLabel];
    
    self.sectionalView = [[UIView alloc] init];
    [self.sectionalView setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:self.sectionalView];
    
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setTitle:@"Okay" forState:UIControlStateNormal];
    [self.dismissButton setBackgroundColor:[UIColor blueColor]];
    [self.dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    [self makeConstraints];
    return self;
}

-(void)makeConstraints
{
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self.sectionalView.mas_top);
        make.top.equalTo(self);
    }];
    
    [self.sectionalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.bottom.equalTo(self.dismissButton.mas_top);
        make.centerX.equalTo(self.mas_centerX);
        make.height.equalTo(@2);
    }];
    
    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(@64);
        make.bottom.equalTo(self);
        make.centerX.equalTo(self);
    }];
}
@end
