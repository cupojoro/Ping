//
//  PGMenuView.m
//  Ping
//
//  Created by Joseph Ross on 2017-03-01.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGMenuView.h"

#import "Masonry.h"

@interface PGMenuView ()

@property (nonatomic, strong) UIButton *viewButton;
@property (nonatomic, strong) UIButton *voteButton;
@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIButton *settingsButton;

@end

@implementation PGMenuView

-(id)initWithController:(PGMapViewController *)controller
{
    self = [super init];
    
    [self setUserInteractionEnabled:YES];
    
    self.viewButton = [[UIButton alloc] init];
    self.viewButton.tag = 1;
    [self.viewButton setTitle:@"View" forState:UIControlStateNormal];
    [self.viewButton addTarget:controller action:@selector(changeMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewButton addTarget:self action:@selector(minimizeToggle) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.viewButton];
    
    self.voteButton = [[UIButton alloc] init];
    self.voteButton.tag = 2;
    [self.voteButton setTitle:@"Vote" forState:UIControlStateNormal];
    [self.voteButton addTarget:controller action:@selector(changeMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.voteButton addTarget:self action:@selector(minimizeToggle) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voteButton];
    
    self.editButton = [[UIButton alloc] init];
    self.editButton.tag = 3;
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.editButton addTarget:controller action:@selector(changeMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton addTarget:self action:@selector(minimizeToggle) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.editButton];
    
    self.toggleButton = [[UIButton alloc] init];
    [self.toggleButton setImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(minimizeToggle) forControlEvents:UIControlEventTouchUpInside];
    [self.toggleButton setUserInteractionEnabled:YES];
    [self addSubview: self.toggleButton];
    
    self.settingsButton = [[UIButton alloc] init];
    [self.settingsButton setImage:[UIImage imageNamed:@"PingTitle2"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:controller action:@selector(popSettings) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.settingsButton];
    
    [self bringSubviewToFront:self.toggleButton];
    [self initialLayout];
    
    self.settingsButton.hidden = YES;
    self.viewButton.hidden = YES;
    self.voteButton.hidden = YES;
    self.editButton.hidden = YES;
    [self sizeToFit];
    return self;
}

-(void)initialLayout
{
    [self.toggleButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@50);
        make.bottom.equalTo(self.mas_bottom);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self.settingsButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@50);
        make.center.equalTo(self.toggleButton);
    }];
    
    [self.voteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@50);
        make.center.equalTo(self.toggleButton);
    }];
    
    [self.viewButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@50);
        make.center.equalTo(self.toggleButton);
    }];
    
    [self.editButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@50);
        make.center.equalTo(self.toggleButton);
    }];
    
}
-(void)minimizeToggle
{
    //DOESNT ANIMATE
    if(self.settingsButton.hidden)
    {
        self.settingsButton.hidden = NO;
        self.viewButton.hidden = NO;
        self.voteButton.hidden = NO;
        self.editButton.hidden = NO;
        
        [self.settingsButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.toggleButton.mas_top).with.offset(-5);
            make.width.height.equalTo(@50);
            make.centerX.equalTo(self.toggleButton.mas_centerX);
        }];
        
        [self.viewButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.settingsButton.mas_top).with.offset(-5);
            make.width.height.equalTo(@50);
            make.centerX.equalTo(self.toggleButton.mas_centerX);
        }];
        
        [self.voteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.toggleButton.mas_top).with.offset(-25);
            make.height.width.equalTo(@50);
            make.right.equalTo(self.settingsButton.mas_left);
        }];
        
        [self.editButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.toggleButton.mas_top).with.offset(-25);
            make.height.width.equalTo(@50);
            make.left.equalTo(self.settingsButton.mas_right);
        }];
        
        [self sizeToFit];
        
        [UIView animateWithDuration:2 animations:^{
            [self setNeedsLayout];
            //self.toggleButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        }];
        
    }else
    {
        [self initialLayout];
        [UIView animateWithDuration:2 animations:^{
            [self setNeedsDisplay];
            //self.toggleButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        } completion:^(BOOL finished) {
            self.settingsButton.hidden = YES;
            self.viewButton.hidden = YES;
            self.voteButton.hidden = YES;
            self.editButton.hidden = YES;
        }];
    }
}


@end
