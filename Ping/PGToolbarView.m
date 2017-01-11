//
//  PGToolbarView.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-10.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGToolbarView.h"

#import "PGMapInterfaceVC.h"


#import "Masonry.h"

@interface PGToolbarView ()

@property (nonatomic, strong) PGMapInterfaceVC *mapInterface;

@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UIButton *gridButton;
@property (nonatomic, strong) UIButton *keyButton;
@property (nonatomic, strong) UIButton *crownButton;
@property (nonatomic, strong) UIButton *moneyButton;
@property (nonatomic, strong) UIButton *editModeButton;
@property (nonatomic, strong) UIButton *voteModeButton;
@property (nonatomic, strong) UIButton *viewModeButton;
@property (nonatomic, strong) UIView *editTab;
@property (nonatomic, strong) UIView *voteTab;
@property (nonatomic, strong) UIView *viewTab;

@end

@implementation PGToolbarView

int toolbarHeight;
int toolbarSectionHeight;

-(id)initWithToolbarHeight:(int)tbHeight toolBarSectionHeight:(int) secHeight mapInterface:(PGMapInterfaceVC *) mapIV
{
    self = [super init];
    
    self.mapInterface = mapIV;
    toolbarHeight = tbHeight;
    toolbarSectionHeight = secHeight;
    
    
    self.toolbarView = [[UIView alloc] init];
    self.toolbarView.backgroundColor = [UIColor grayColor];
    
    self.viewModeButton = [[UIButton alloc] init];
    self.viewModeButton.tag = 1;
    [self.viewModeButton setTitle:@"VIEW MODE" forState:UIControlStateNormal];
    [self.viewModeButton addTarget:self.mapInterface action:@selector(updateStatusMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView addSubview:self.viewModeButton];
    
    self.voteModeButton = [[UIButton alloc] init];
    self.voteModeButton.tag = 2;
    [self.voteModeButton setTitle:@"VOTE MODE" forState:UIControlStateNormal];
    [self.voteModeButton addTarget:self.mapInterface  action:@selector(updateStatusMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView addSubview:self.voteModeButton];
    
    self.editModeButton = [[UIButton alloc] init];
    self.editModeButton.tag = 3;
    [self.editModeButton setTitle:@"EDIT MODE" forState:UIControlStateNormal];
    [self.editModeButton addTarget:self.mapInterface  action:@selector(updateStatusMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.editModeButton setBackgroundColor:[UIColor redColor]];
    [self.toolbarView addSubview:self.editModeButton];
    
    //TAB SECTIONS
    
    self.viewTab = [[UIView alloc] init];
    [self.toolbarView addSubview:self.viewTab];
    
    self.voteTab = [[UIView alloc] init];
    [self.toolbarView addSubview:self.voteTab];
    
    self.editTab = [[UIView alloc] init];
    [self.toolbarView addSubview:self.editTab];
    
    //INTERFACE OPTIONS EDIT TAB
    
    self.gridButton = [[UIButton alloc] init];
    [self.gridButton setImage:[UIImage imageNamed:@"grid"] forState:UIControlStateNormal];
    [self.gridButton addTarget:self.mapInterface action:@selector(gridButtonSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self.editTab addSubview:self.gridButton];
    
    self.keyButton = [[UIButton alloc] init];
    self.keyButton.tag = 1;
    [self.keyButton setImage:[UIImage imageNamed:@"key"] forState:UIControlStateNormal];
    [self.keyButton addTarget:self.mapInterface action:@selector(updateGeoID:) forControlEvents:UIControlEventTouchUpInside];
    [self.editTab addSubview:self.keyButton];
    
    self.crownButton = [[UIButton alloc] init];
    self.crownButton.tag = 2;
    [self.crownButton setImage:[UIImage imageNamed:@"king"] forState:UIControlStateNormal];
    [self.crownButton addTarget:self.mapInterface action:@selector(updateGeoID:) forControlEvents:UIControlEventTouchUpInside];
    [self.editTab addSubview:self.crownButton];
    
    self.moneyButton = [[UIButton alloc] init];
    self.moneyButton.tag = 3;
    [self.moneyButton setImage:[UIImage imageNamed:@"money"] forState:UIControlStateNormal];
    [self.moneyButton addTarget:self.mapInterface action:@selector(updateGeoID:) forControlEvents:UIControlEventTouchUpInside];
    [self.editTab addSubview:self.moneyButton];
    
    [self applyMASConstraints];
    
    return self;
}

-(void)applyMASConstraints
{
    //TOOLBAR
    
    [self.toolbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo([NSNumber numberWithInteger:toolbarHeight]);
        make.width.equalTo(self.mas_width);
        make.bottom.equalTo(self.mas_bottom);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    
    [self.viewModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolbarView.mas_top);
        make.width.equalTo(self.toolbarView.mas_width).dividedBy(3);
        make.height.equalTo([NSNumber numberWithInteger:toolbarSectionHeight]);
        make.left.equalTo(self.toolbarView.mas_left);
    }];
    
    [self.voteModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolbarView.mas_top);
        make.width.equalTo(self.toolbarView.mas_width).dividedBy(3);
        make.height.equalTo([NSNumber numberWithInteger:toolbarSectionHeight]);
        make.left.equalTo(self.viewModeButton.mas_right);
    }];
    
    [self.editModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolbarView.mas_top);
        make.width.equalTo(self.toolbarView.mas_width).dividedBy(3);
        make.height.equalTo([NSNumber numberWithInteger:toolbarSectionHeight]);
        make.left.equalTo(self.voteModeButton.mas_right);
    }];
    
    //EDIT TAB
    
    [self.editTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.toolbarView.mas_height).with.offset(-toolbarSectionHeight);
        make.width.equalTo(self.toolbarView.mas_width);
        make.bottom.equalTo(self.toolbarView.mas_bottom);
        make.left.equalTo(self.toolbarView.mas_left);
    }];
    
    [self.gridButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerX.equalTo(self.editTab.mas_right).multipliedBy(0.2);
        make.centerY.equalTo(self.editTab.mas_centerY);
    }];
    
    [self.keyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerY.equalTo(self.editTab.mas_centerY);
        make.centerX.equalTo(self.editTab.mas_right).multipliedBy(0.4);
    }];
    
    [self.crownButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerY.equalTo(self.editTab.mas_centerY);
        make.centerX.equalTo(self.editTab.mas_right).multipliedBy(0.6);
    }];
    
    [self.moneyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerY.equalTo(self.editTab.mas_centerY);
        make.left.equalTo(self.editTab.mas_right).multipliedBy(0.8);
    }];

}

-(void)clearButtonHighlights
{
    self.keyButton.backgroundColor = [UIColor clearColor];
    self.crownButton.backgroundColor = [UIColor clearColor];
    self.moneyButton.backgroundColor = [UIColor clearColor];
    self.viewModeButton.backgroundColor = [UIColor clearColor];
    self.voteModeButton.backgroundColor = [UIColor clearColor];
    self.editModeButton.backgroundColor = [UIColor clearColor];
}

@end
