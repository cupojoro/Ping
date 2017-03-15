//
//  PGTagHolderView.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-18.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGTagHolderView.h"


@implementation PGTagHolderView

-(id)initWithImage:(NSString *)imageName andFrame:(CGRect) frame
{
    self = [super init];
    [self setImage:[UIImage imageNamed:@"tagholder"]];
    self.frame = frame;
    self.clipsToBounds=NO;
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    CGRect temp = CGRectMake(-frame.size.width/5+6, -frame.size.height/5+4.6, icon.frame.size.width/5.5, icon.frame.size.height/5.5);
    icon.frame=temp;
    [icon setTintColor:[UIColor redColor]];
    [self setTintColor:[UIColor redColor]];
    
    [self addSubview:icon];
    
    return self;
}

-(id)initWithNoImageAndFrame:(CGRect)frame
{
    self = [super init];
    
    [self setImage:[UIImage imageNamed:@"tagholder"]];
    self.frame = frame;
    self.clipsToBounds=NO;
    
    UIImageView *icon = [[UIImageView alloc] init];
    CGRect temp = CGRectMake(-frame.size.width/5+6, -frame.size.height/5+4.6, icon.frame.size.width/5.5, icon.frame.size.height/5.5);
    icon.frame=temp;
    [self addSubview:icon];
    [icon setTintColor:[UIColor redColor]];
    [self setTintColor:[UIColor redColor]];
    return self;
}

-(void)updateImage:(NSString *)imageName
{
    UIImageView *icon = (UIImageView *) [self subviews][0];
    [icon setImage:[UIImage imageNamed:imageName]];
    CGRect temp = CGRectMake(-self.frame.size.width/5+6, -self.frame.size.height/5+4.6, 5.81818, 5.81818);
    icon.frame=temp;
    [icon setTintColor:[UIColor redColor]];
    [self setTintColor:[UIColor redColor]];
    [self setNeedsDisplay];
}
@end

