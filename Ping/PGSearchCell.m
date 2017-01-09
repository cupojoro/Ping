//
//  PGSearchCell.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-08.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGSearchCell.h"
#import "PGGamePageVC.h"
#import "Masonry.h"

@interface PGSearchCell()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *arrow;

@end

@implementation PGSearchCell

-(id)initWith:(NSString *)title PointingTo:(NSString *)destination withParent:(UIViewController *)vc
{
    self = [super init];
    
    self.gameTitle = title;
    self.gameDestination = destination;
    self.inUse = NO;
    self.parent = vc;
    
    if(self){
        
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        
        self.title = [[UILabel alloc] init];
        self.title.text = self.gameTitle;
        [self addSubview:self.title];
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.95);
        }];
        
        self.arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder"]];
        self.arrow.contentMode = UIViewContentModeScaleAspectFit;
        self.arrow.hidden = YES;
        [self addSubview:self.arrow];
        [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.height.equalTo(self.mas_height);
            make.right.equalTo(self.mas_right).multipliedBy(0.95);
        }];
        
        self.button = [[UIButton alloc] init];
        [self.button addTarget:self action:@selector(cellPicked) forControlEvents:UIControlEventTouchUpInside];
        [self.button setEnabled:NO];
        [self addSubview:self.button];
        [self bringSubviewToFront:self.button];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self).multipliedBy(0.95);
            make.center.equalTo(self);
        }];
        
    }
    
    return self;
}

-(void)cellPicked
{
    PGGamePageVC *gamePage = [[PGGamePageVC alloc] initWithGameTitle:self.gameTitle andDestination:self.gameDestination];
    
    [self.parent.navigationController pushViewController:gamePage animated:NO];
}
-(void)updateCell
{
    [self.title setText:self.gameTitle];
    [self setNeedsDisplay];
}

-(void)setTitle:(NSString *) title setDestination :(NSString *)destination buttonVisibile:(BOOL)hidden
{
    self.inUse = YES;
    self.gameTitle = title;
    self.gameDestination = destination;
    self.arrow.hidden = !hidden; //IS ARROW HIDDEN?
    [self.button setEnabled:hidden]; //IS BUTTON ENABLED?
    [self updateCell];
}
@end
