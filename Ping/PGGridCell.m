//
//  PGGridCell.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-09.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGGridCell.h"
#import "Masonry.h"

@interface PGGridCell ()

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation PGGridCell

-(void)addImage:(NSString *)name
{
    
    self.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    self.iconView.contentMode = UIViewContentModeScaleToFill;
    self.iconView.frame = self.contentView.frame;
    self.iconView.image = [self.iconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentView addSubview:self.iconView];
    [self.contentView setNeedsDisplay];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.iconView removeFromSuperview];
    self.iconView = nil;
}
@end
