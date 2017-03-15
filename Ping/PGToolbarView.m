//
//  PGToolbarView.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-10.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//
#import "PGToolbarView.h"



#import "Masonry.h"

@interface PGToolbarView ()

@property (nonatomic, strong) PGMapInterfaceVC *mapInterface;

@property (nonatomic, strong) UIButton *gridButton;
@property (nonatomic, strong) UIButton *keyEditB;
@property (nonatomic, strong) UIButton *crownEditB;
@property (nonatomic, strong) UIButton *moneyEditB;
@property (nonatomic, strong) UIButton *editModeButton;


@property (nonatomic, strong) UIButton *voteModeButton;
@property (nonatomic, strong) UIButton *upvoteButton;
@property (nonatomic, strong) UIButton *downvoteButton;
@property (nonatomic, strong) UILabel *voteLabel;

@property (nonatomic, strong) UIButton *keyViewB;
@property (nonatomic, strong) UIButton *crownViewB;
@property (nonatomic, strong) UIButton *moneyViewB;
@property (nonatomic, strong) UIButton *minimizeViewB;
@property (nonatomic, strong) UIButton *viewModeButton;


@property (nonatomic, strong) UIView *editTab;
@property (nonatomic, strong) UIView *voteTab;
@property (nonatomic, strong) UIView *viewTab;

@property (nonatomic) int toolbarHeight;
@property (nonatomic) int toolbarSectionHeight;
@property (nonatomic) BOOL gridVisible;

@end

@implementation PGToolbarView

-(id)initWithToolbarHeight:(int)tbHeight toolBarSectionHeight:(int) secHeight mapInterface:(PGMapInterfaceVC *) mapIV
{
    self = [super init];
    
    self.mapInterface = mapIV;
    self.toolbarHeight = tbHeight;
    self.toolbarSectionHeight = secHeight;
    self.gridVisible = NO;
    
    
    self.backgroundColor = [UIColor grayColor];
    
    self.viewModeButton = [[UIButton alloc] init];
    self.viewModeButton.tag = 1;
    [self.viewModeButton setTitle:@"VIEW MODE" forState:UIControlStateNormal];
    [self.viewModeButton addTarget:self.mapInterface action:@selector(updateStatusMode:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.viewModeButton];
    
    self.voteModeButton = [[UIButton alloc] init];
    self.voteModeButton.tag = 2;
    [self.voteModeButton setTitle:@"VOTE MODE" forState:UIControlStateNormal];
    [self.voteModeButton addTarget:self.mapInterface  action:@selector(updateStatusMode:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voteModeButton];
    
    self.editModeButton = [[UIButton alloc] init];
    self.editModeButton.tag = 3;
    [self.editModeButton setTitle:@"EDIT MODE" forState:UIControlStateNormal];
    [self.editModeButton addTarget:self.mapInterface  action:@selector(updateStatusMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.editModeButton setBackgroundColor:[UIColor redColor]];
    [self addSubview:self.editModeButton];
    
    //TAB SECTIONS
    
    self.viewTab = [[UIView alloc] init];
    self.viewTab.hidden = YES;
    [self addSubview:self.viewTab];
    
    self.voteTab = [[UIView alloc] init];
    self.voteTab.hidden = YES;
    [self addSubview:self.voteTab];
    
    self.editTab = [[UIView alloc] init];
    self.editTab.hidden = NO;
    [self addSubview:self.editTab];
    
    //INTERFACE OPTIONS VIEW TAB
    
    self.keyViewB = [[UIButton alloc] init];
    self.keyViewB.tag = 1;
    self.keyViewB.backgroundColor = [UIColor yellowColor];
    [self.keyViewB setImage:[UIImage imageNamed:@"key"] forState:UIControlStateNormal];
    [self.keyViewB addTarget:self.mapInterface action:@selector(updateViewFlag:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:self.keyViewB];
    
    self.crownViewB = [[UIButton alloc] init];
    self.crownViewB.tag = 2;
    self.crownViewB.backgroundColor = [UIColor yellowColor];
    [self.crownViewB setImage:[UIImage imageNamed:@"king"] forState:UIControlStateNormal];
    [self.crownViewB addTarget:self.mapInterface action:@selector(updateViewFlag:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:self.crownViewB];
    
    self.moneyViewB = [[UIButton alloc] init];
    self.moneyViewB.tag = 3;
    self.moneyViewB.backgroundColor = [UIColor yellowColor];
    [self.moneyViewB setImage:[UIImage imageNamed:@"money"] forState:UIControlStateNormal];
    [self.moneyViewB addTarget:self.mapInterface action:@selector(updateViewFlag:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:self.moneyViewB];
    
    self.minimizeViewB = [[UIButton alloc] init];
    [self.minimizeViewB setImage:[UIImage imageNamed:@"minimize"] forState:UIControlStateNormal];
    [self.minimizeViewB addTarget:self.mapInterface action:@selector(toggleToolbar) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:self.minimizeViewB];
    
    //INTERFACE OPTIONS EDIT TAB
    //GEOID BREAKDOWN
    // DEFAULT IS 0: BLANK CELL
    // ADMIN CAN -1: HIDDEN CELL
    // USER 1 - 3 : CORRESPONDING ICON
    self.gridButton = [[UIButton alloc] init];
    [self.gridButton setImage:[UIImage imageNamed:@"grid"] forState:UIControlStateNormal];
    [self.gridButton addTarget:self.mapInterface action:@selector(gridButtonSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self.gridButton addTarget:self action:@selector(toggleGridHighlight) forControlEvents:UIControlEventTouchUpInside];
    [self.editTab addSubview:self.gridButton];
    
    self.keyEditB = [[UIButton alloc] init];
    self.keyEditB.tag = 1;
    [self.keyEditB setImage:[UIImage imageNamed:@"key"] forState:UIControlStateNormal];
    [self.keyEditB addTarget:self.mapInterface action:@selector(updateGeoID:) forControlEvents:UIControlEventTouchUpInside];
    [self.editTab addSubview:self.keyEditB];
    
    self.crownEditB = [[UIButton alloc] init];
    self.crownEditB.tag = 2;
    [self.crownEditB setImage:[UIImage imageNamed:@"king"] forState:UIControlStateNormal];
    [self.crownEditB addTarget:self.mapInterface action:@selector(updateGeoID:) forControlEvents:UIControlEventTouchUpInside];
    [self.editTab addSubview:self.crownEditB];
    
    self.moneyEditB = [[UIButton alloc] init];
    self.moneyEditB.tag = 3;
    [self.moneyEditB setImage:[UIImage imageNamed:@"money"] forState:UIControlStateNormal];
    [self.moneyEditB addTarget:self.mapInterface action:@selector(updateGeoID:) forControlEvents:UIControlEventTouchUpInside];
    [self.editTab addSubview:self.moneyEditB];
    
    //INTERFACE OPTIONS VOTE TAB
    
    self.upvoteButton = [[UIButton alloc] init];
    [self.upvoteButton setBackgroundImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    self.upvoteButton.tag = 1;
    [self.upvoteButton addTarget:self.mapInterface action:@selector(castVote:) forControlEvents:UIControlEventTouchUpInside];
    self.upvoteButton.hidden = YES;
    [self.voteTab addSubview:self.upvoteButton];
    
    self.downvoteButton = [[UIButton alloc] init];
    [self.downvoteButton setBackgroundImage:[UIImage imageNamed:@"cross-out"] forState:UIControlStateNormal];
    self.downvoteButton.tag = -1;
    [self.downvoteButton addTarget:self.mapInterface action:@selector(castVote:) forControlEvents:UIControlEventTouchUpInside];
    self.downvoteButton.hidden = YES;
    [self.voteTab addSubview:self.downvoteButton];
    
    self.voteLabel = [[UILabel alloc] init];
    [self.voteLabel setText:@"SELECT AND ICON TO VOTE"];
    [self.voteTab addSubview:self.voteLabel];
    
    
    
    return self;
}

-(void)updateConstraints
{
    
    [self.viewModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.width.equalTo(self.mas_width).dividedBy(3);
        make.height.equalTo([NSNumber numberWithInteger:self.toolbarSectionHeight]);
        make.left.equalTo(self.mas_left);
    }];
    
    [self.voteModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.width.equalTo(self.mas_width).dividedBy(3);
        make.height.equalTo([NSNumber numberWithInteger:self.toolbarSectionHeight]);
        make.left.equalTo(self.viewModeButton.mas_right);
    }];
    
    [self.editModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.width.equalTo(self.mas_width).dividedBy(3);
        make.height.equalTo([NSNumber numberWithInteger:self.toolbarSectionHeight]);
        make.left.equalTo(self.voteModeButton.mas_right);
    }];
    
    //EDIT TAB
    
    [self.editTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mas_height).with.offset(-self.toolbarSectionHeight);
        make.width.equalTo(self.mas_width);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
    }];
    
    [self.gridButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerX.equalTo(self.editTab.mas_right).multipliedBy(0.2);
        make.centerY.equalTo(self.editTab.mas_centerY);
    }];
    
    [self.keyEditB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerY.equalTo(self.editTab.mas_centerY);
        make.centerX.equalTo(self.editTab.mas_right).multipliedBy(0.4);
    }];
    
    [self.crownEditB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerY.equalTo(self.editTab.mas_centerY);
        make.centerX.equalTo(self.editTab.mas_right).multipliedBy(0.6);
    }];
    
    [self.moneyEditB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerY.equalTo(self.editTab.mas_centerY);
        make.left.equalTo(self.editTab.mas_right).multipliedBy(0.8);
    }];
    
    //VIEW TAB
    
    [self.viewTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mas_height).with.offset(-self.toolbarSectionHeight);
        make.width.equalTo(self.mas_width);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
    }];
    
    [self.keyViewB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerX.equalTo(self.editTab.mas_right).multipliedBy(0.2);
        make.centerY.equalTo(self.editTab.mas_centerY);
    }];
    
    [self.crownViewB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerY.equalTo(self.editTab.mas_centerY);
        make.centerX.equalTo(self.editTab.mas_right).multipliedBy(0.4);
    }];
    
    [self.moneyViewB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerY.equalTo(self.editTab.mas_centerY);
        make.centerX.equalTo(self.editTab.mas_right).multipliedBy(0.6);
    }];
    
    [self.minimizeViewB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.editTab.mas_height);
        make.centerY.equalTo(self.editTab.mas_centerY);
        make.left.equalTo(self.editTab.mas_right).multipliedBy(0.8);
    }];
    
    //VOTE TAB
    
    [self.voteTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mas_height).with.offset(-self.toolbarSectionHeight);
        make.width.equalTo(self.mas_width);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
    }];
    
    [self.upvoteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.voteTab.mas_height);
        make.height.equalTo(self.voteTab.mas_height);
        make.bottom.equalTo(self.voteTab.mas_bottom);
        make.centerX.equalTo(self.viewModeButton.mas_centerX);
    }];
    
    [self.downvoteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.voteTab.mas_height);
        make.height.equalTo(self.voteTab.mas_height);
        make.bottom.equalTo(self.voteTab.mas_bottom);
        make.centerX.equalTo(self.editModeButton.mas_centerX);
    }];
    
    [self.voteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.voteTab.mas_height);
        make.centerX.equalTo(self.voteTab.mas_centerX);
        make.bottom.equalTo(self.voteTab.mas_bottom);
    }];

    [super updateConstraints];
}

-(void)toggleGridHighlight
{
    self.gridVisible = !self.gridVisible;
    [self updateToolbar];
}
-(void)toggleVote:(NSNumber *)vote
{
    self.voteTab.hidden = NO;
    self.upvoteButton.hidden = NO;
    self.downvoteButton.hidden = NO;
    
    if(vote.integerValue == 1){
        //VOTED UP
        [self.upvoteButton setBackgroundColor:[UIColor orangeColor]];
        [self.downvoteButton setBackgroundColor:[UIColor clearColor]];
        [self.voteLabel setText:@"STARRED THIS EDIT"];
        self.upvoteButton.userInteractionEnabled = NO;
        self.downvoteButton.userInteractionEnabled = NO;
    }else if(vote.integerValue == -1){
        //VOTE DOWN
        [self.upvoteButton setBackgroundColor:[UIColor clearColor]];
        [self.downvoteButton setBackgroundColor:[UIColor redColor]];
        [self.voteLabel setText:@"DOWN VOTED THIS EDIT"];
        self.upvoteButton.userInteractionEnabled = NO;
        self.downvoteButton.userInteractionEnabled = NO;
    }else if(vote.integerValue == 0){
        [self.upvoteButton setBackgroundColor:[UIColor clearColor]];
        [self.downvoteButton setBackgroundColor:[UIColor clearColor]];
        [self.voteLabel setText:@"CAST YOUR VOTE"];
        self.upvoteButton.userInteractionEnabled = YES;
        self.downvoteButton.userInteractionEnabled = YES;
    }else{
        [self.upvoteButton setBackgroundColor:[UIColor clearColor]];
        [self.downvoteButton setBackgroundColor:[UIColor clearColor]];
        self.upvoteButton.hidden = YES;
        self.downvoteButton.hidden = YES;
        [self.voteLabel setText:@"SELECT AN ICON TO VOTE"];
        self.upvoteButton.userInteractionEnabled = NO;
        self.downvoteButton.userInteractionEnabled = NO;
    }
    [self setNeedsDisplay];
}

-(void)updateToolbar
{
    [self defaultButtonHighlights];
    
    StatusModes currentStatus = [self.mapInterface getStatusMode];
    if(currentStatus == EditMode){
        self.editModeButton.backgroundColor = [UIColor redColor];
        self.editTab.hidden = NO;
        self.viewTab.hidden = YES;
        self.voteTab.hidden = YES;
        [self.mapInterface updateStatusBarForEdit];
    }else if(currentStatus == ViewMode){
        self.viewModeButton.backgroundColor = [UIColor redColor];
        self.editTab.hidden = YES;
        self.viewTab.hidden = NO;
        self.voteTab.hidden = YES;
        [self.mapInterface.navigationItem setTitle:@"Details about an icon will appear here"];
    }else{
        self.voteModeButton.backgroundColor = [UIColor redColor];
        self.editTab.hidden = YES;
        self.viewTab.hidden = YES;
        self.voteTab.hidden = NO;
        [self toggleVote:@(3)];
        [self.mapInterface updateStatusBarForVote];
    }
    unsigned int vF = [self.mapInterface getViewFlag];
    if(vF & KeyView) self.keyViewB.backgroundColor = [UIColor yellowColor];
    else self.keyViewB.backgroundColor = [UIColor clearColor];
    if(vF & CrownView) self.crownViewB.backgroundColor = [UIColor yellowColor];
    else self.crownViewB.backgroundColor = [UIColor clearColor];
    if(vF & MoneyView) self.moneyViewB.backgroundColor = [UIColor yellowColor];
    else self.moneyViewB.backgroundColor = [UIColor clearColor];
    
    switch([self.mapInterface getGeoID])
    {
        case 0:
            break;
        case 1:
            self.keyEditB.backgroundColor = [UIColor yellowColor];
            break;
        case 2:
            self.crownEditB.backgroundColor = [UIColor yellowColor];
            break;
        case 3:
            self.moneyEditB.backgroundColor = [UIColor yellowColor];
            break;
        default:
            NSLog(@"ATTEMPTING TO FOCUS UNIDENTIFIED BUTTON");
            break;
    }
    
    if(self.gridVisible) self.gridButton.backgroundColor = [UIColor yellowColor];
    else self.gridButton.backgroundColor = [UIColor clearColor];
}

-(void)defaultButtonHighlights
{
    self.gridButton.backgroundColor = [UIColor clearColor];
    self.keyEditB.backgroundColor = [UIColor clearColor];
    self.crownEditB.backgroundColor = [UIColor clearColor];
    self.moneyEditB.backgroundColor = [UIColor clearColor];
    self.keyViewB.backgroundColor = [UIColor yellowColor];
    self.crownViewB.backgroundColor = [UIColor yellowColor];
    self.moneyViewB.backgroundColor = [UIColor yellowColor];
    self.viewModeButton.backgroundColor = [UIColor clearColor];
    self.voteModeButton.backgroundColor = [UIColor clearColor];
    self.editModeButton.backgroundColor = [UIColor clearColor];
}
-(void)resetButtons
{
    self.gridVisible = NO;
}
@end
