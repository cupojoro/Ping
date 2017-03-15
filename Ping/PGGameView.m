//
//  PGGameView.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGGameView.h"

#import "Masonry.h"

@interface PGGameView()

@property (nonatomic, strong) UIImageView *coverTitle;
@property (nonatomic, strong) UITableView *mapTable;

@end

@implementation PGGameView

-(id)initWithController:(PGGamePageViewController *)vc
{
    self = [super init];
    
    self.coverTitle = [[UIImageView alloc] init];
    self.coverTitle.contentMode = UIViewContentModeScaleToFill;
    self.coverTitle.clipsToBounds = YES;
    [self addSubview:self.coverTitle];
    
    self.mapTable = [[UITableView alloc] init];
    [self.mapTable setDelegate:vc];
    [self.mapTable setDataSource:vc];
    self.mapTable.bounces = NO;
    self.mapTable.separatorStyle = 0;
    [self addSubview:self.mapTable];
    
    [self makeConstraints];
    return self;
}

-(void)makeConstraints
{
    [self.coverTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mas_height).dividedBy(2);
        make.width.equalTo(self);
        make.top.equalTo(self);
        make.centerX.equalTo(self);
    }];
    
    [self.mapTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mas_height).dividedBy(2).with.offset(-20);
        make.width.equalTo(self).multipliedBy(0.75);
        make.bottom.equalTo(self);
        make.centerX.equalTo(self);
    }];
}

#pragma mark Cover

-(void)setCoverImage:(NSURL *)url
{
    UIImage *coverImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    [self.coverTitle setImage:coverImage];
}

#pragma mark Table

-(void)reloadTable
{
    [self.mapTable reloadData];
}

@end
