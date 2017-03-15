//
//  PGTagEditView.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-17.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#define kArrowHeight 20
#define kButtonPadding 5
#import "PGTagEditView.h"

#import "PGMapInteraceView.h"

#import "Masonry.h"
@interface PGTagEditView () <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIScrollView *iconScrollView;
@property (nonatomic, strong) UITextField *commentSection;
@property (nonatomic, strong) UILabel *charactersLeftLabel;

@property (nonatomic) ViewOrientation orientation;
@property (nonatomic) NSMutableArray *iconButtons;

@property (nonatomic, strong) PGMapViewController *controller;
@end

@implementation PGTagEditView

-(id)initWithController:(PGMapViewController *)vc
{
    self = [super init];
    
    self.controller = vc;
    
    self.iconButtons = [[NSMutableArray alloc] init];
    self.orientation = ViewOrientationLeft;
    [self setClipsToBounds:YES];
    self.frame = CGRectMake(0, 0, 260, 190);
    [self setBackgroundColor:[UIColor clearColor]];
    
    
    self.confirmButton = [[UIButton alloc] init];
    self.confirmButton.hidden = NO;
    self.confirmButton.layer.cornerRadius = 5.0;
    [self.confirmButton setBackgroundColor:[UIColor greenColor]];
    [self.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmButton addTarget:vc action:@selector(tagViewConfirm) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.confirmButton];
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.layer.cornerRadius = 5.0;
    [self.cancelButton setBackgroundColor:[UIColor redColor]];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:vc action:@selector(tagViewCancel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    
    self.iconScrollView = [[UIScrollView alloc] init];
    self.iconScrollView.bounces = YES;
    self.iconScrollView.showsHorizontalScrollIndicator = YES;
    self.iconScrollView.alwaysBounceHorizontal = YES;
    [self addSubview:self.iconScrollView];
    
    self.commentSection = [[UITextField alloc] init];
    self.commentSection.delegate = self;
    self.commentSection.layer.cornerRadius = 5.0;
    self.commentSection.backgroundColor = [UIColor whiteColor];
    self.commentSection.placeholder = @"Comment: 75 Characters Max";
    self.commentSection.borderStyle = UITextBorderStyleNone;
    [self addSubview:self.commentSection];
    
    self.charactersLeftLabel = [[UILabel alloc] init];
    self.charactersLeftLabel.text = @"75";
    self.charactersLeftLabel.adjustsFontSizeToFitWidth = YES;
    [self.commentSection addSubview:self.charactersLeftLabel];
    
    [self refreshConstraints];
    
    return self;
}

#pragma mark Constraints

-(void)refreshConstraints
{
    self.confirmButton.hidden = YES;
    self.commentSection.hidden = YES;
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@45);
        if(self.orientation == ViewOrientationUp) make.top.equalTo(self.mas_top).with.offset(kArrowHeight+kButtonPadding);
        else make.top.equalTo(self.mas_top).with.offset(kButtonPadding);
        if(self.orientation == ViewOrientationLeft)
        {
            make.width.equalTo(self.mas_width).with.offset(-kArrowHeight-(2*kButtonPadding));
            make.left.equalTo(self.mas_left).with.offset(kArrowHeight+kButtonPadding);
        }else if(self.orientation == ViewOrientationRight)
        {
            make.left.equalTo(self.mas_left).with.offset(kButtonPadding);
            make.width.equalTo(self.mas_width).with.offset(-kArrowHeight-(2*kButtonPadding));
        }
        else
        {
            make.left.equalTo(self.mas_left).with.offset(kButtonPadding);
            make.width.equalTo(self).with.offset(-(2*kButtonPadding));
        }
    }];
    
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@45);
        if(self.orientation == ViewOrientationDown) make.bottom.equalTo(self.mas_bottom).with.offset(-(kButtonPadding+kArrowHeight));
        else make.bottom.equalTo(self.mas_bottom).with.offset(-kButtonPadding);
        if(self.orientation == ViewOrientationLeft)
        {
            make.width.equalTo(self.mas_width).with.offset(-kArrowHeight-(2*kButtonPadding));
            make.left.equalTo(self.mas_left).with.offset(kArrowHeight+kButtonPadding);
        }else if(self.orientation == ViewOrientationRight)
        {
            make.width.equalTo(self.mas_width).with.offset(-kArrowHeight-(2*kButtonPadding));
            make.left.equalTo(self.mas_left).with.offset(kButtonPadding);
        }
        else
        {
            make.left.equalTo(self.mas_left).with.offset(kButtonPadding);
            make.width.equalTo(self.mas_width).with.offset(-(2*kButtonPadding));
        }
    }];
    
    [self.iconScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmButton.mas_bottom).with.offset(10);
        make.bottom.equalTo(self.cancelButton.mas_top).with.offset(-10);
        if(self.orientation == ViewOrientationLeft)
        {
            make.left.equalTo(self.mas_left).with.offset(kArrowHeight+kButtonPadding);
            make.width.equalTo(self.mas_width).with.offset(-kArrowHeight-(2*kButtonPadding));
        }else if(self.orientation == ViewOrientationRight)
        {
            make.left.equalTo(self.mas_left).with.offset(kButtonPadding);
            make.width.equalTo(self.mas_width).with.offset(-kArrowHeight-(2*kButtonPadding));
        }else
        {
            make.left.equalTo(self.mas_left).with.offset(kButtonPadding);
            make.width.equalTo(self.mas_width).with.offset(-(2*kButtonPadding));
        }
    }];
    
    [self.commentSection mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.iconScrollView.mas_height);
        make.width.equalTo(self.iconScrollView.mas_width);
        make.left.equalTo(self.iconScrollView.mas_right).with.offset(kButtonPadding);
        make.centerY.equalTo(self.iconScrollView.mas_centerY);
    }];
    
    [self.charactersLeftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@12);
        make.width.equalTo(@20);
        make.bottom.equalTo(self.commentSection.mas_bottom);
        make.right.equalTo(self.commentSection.mas_right);
    }];
}

#pragma mark Update View

-(void)reset
{
    [self refreshConstraints];
    self.confirmButton.hidden = YES;
    self.iconScrollView.hidden = NO;
    self.commentSection.hidden = YES;
    self.commentSection.text = @"";
    self.charactersLeftLabel.text = @"75";
}

-(void)updateCharacterLabel:(int)charactersLeft
{
    self.charactersLeftLabel.text = [NSString stringWithFormat:@"%d",charactersLeft];
}

-(void)setIcons:(NSArray *)iconFlags
{
    if([self.iconButtons count] != 0)
    {
        for(UIButton *iconButton in self.iconButtons)
        {
            [iconButton removeFromSuperview];
        }
        self.iconButtons = [[NSMutableArray alloc] init];
    }
    __block UIButton *prevButton;
    __block int totalIcons = 0;
    for(int i = 0; i < [iconFlags count]; i++)
    {
        NSString *buttonImage;
        NSNumber *flag = (NSNumber *) iconFlags[i];
        if([flag intValue] == 1){
            totalIcons++;
            buttonImage = [PGMapInteraceView iconImageNameLookup:@(i)];
            UIButton *icon = [[UIButton alloc] init];
            icon.tag = i;
            [icon addTarget:self action:@selector(iconSelected:) forControlEvents:UIControlEventTouchUpInside];
            [icon setImage:[UIImage imageNamed:buttonImage] forState:UIControlStateNormal];
            [self.iconScrollView addSubview:icon];
            if(i==0)
            {
                [icon mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.equalTo(@50);
                    make.left.equalTo(self.iconScrollView.mas_left);
                    make.centerY.equalTo(self.iconScrollView.mas_centerY);
                }];
            }else{
                [icon mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.equalTo(@50);
                    make.left.equalTo(prevButton.mas_right);
                    make.centerY.equalTo(self.iconScrollView.mas_centerY);
                }];
            }
            prevButton = icon;
        }
    }
    self.iconScrollView.contentSize = CGSizeMake(50*totalIcons, 50);
}
-(void)updateOrientation:(ViewOrientation)orientation
{
    self.orientation = orientation;
    [self refreshConstraints];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark Actions

-(void)iconSelected:(id) sender
{
    UIButton *iconButton = (UIButton *)sender;
    self.selectedIconFlag = iconButton.tag;
    self.commentSection.hidden = NO;
    [self.iconScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmButton.mas_bottom).with.offset(5);
        make.bottom.equalTo(self.cancelButton.mas_top).with.offset(-5);
        if(self.orientation == ViewOrientationLeft)
        {
            make.right.equalTo(self.mas_left).with.offset(kArrowHeight);
            make.width.equalTo(self.mas_width).with.offset(-kArrowHeight-(2*kButtonPadding));
        }else if(self.orientation == ViewOrientationRight)
        {
            make.right.equalTo(self.mas_left);
            make.width.equalTo(self.mas_width).with.offset(-kArrowHeight-(2*kButtonPadding));
        }
        else
        {
            make.right.equalTo(self.mas_left);
            make.width.equalTo(self.mas_width).with.offset(-(2*kButtonPadding));
        }
    }];
    [UIView animateWithDuration:1.5 animations:^{
        [self setNeedsLayout];
        self.iconScrollView.hidden = YES;
        self.confirmButton.hidden = NO;
    }];
    
    PGMapInteraceView *interfaceView = (PGMapInteraceView *) [self superview];
    [interfaceView updateTagHolderImage:self.selectedIconFlag];
}

#pragma mark TextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *detailSet = [NSCharacterSet characterSetWithCharactersInString:@" .,+-()abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"];
    if([string rangeOfCharacterFromSet:[detailSet invertedSet]].location != NSNotFound) return NO;
    if(range.length + range.location > textField.text.length) return NO;
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength <= 75){
        self.charactersLeftLabel.text = [NSString stringWithFormat:@"%u", 75 - newLength];
        self.commentString = [textField.text stringByAppendingString:string];
        return YES;
    }else{
        return NO;
    }
}

#pragma mark Draw

-(void)drawRect:(CGRect)rect
{
    float radius = 5;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    
    if(self.orientation == ViewOrientationUp){
        [fillPath moveToPoint:CGPointMake(radius, kArrowHeight)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width/2+(kArrowHeight/2), kArrowHeight)];//6
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width/2, 0)];//7
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width/2-(kArrowHeight/2), kArrowHeight)];//8
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width-radius, kArrowHeight)];
        [fillPath addQuadCurveToPoint:CGPointMake(self.bounds.size.width, radius+kArrowHeight) controlPoint:CGPointMake(self.bounds.size.width, kArrowHeight)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-radius)];
        [fillPath addQuadCurveToPoint:CGPointMake(self.bounds.size.width-radius, self.bounds.size.height) controlPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
        [fillPath addLineToPoint:CGPointMake(radius, self.bounds.size.height)];
        [fillPath addQuadCurveToPoint:CGPointMake(0, self.bounds.size.height-radius) controlPoint:CGPointMake(0, self.bounds.size.height)];
        [fillPath addLineToPoint:CGPointMake(0, radius+kArrowHeight)];
        [fillPath addQuadCurveToPoint:CGPointMake(radius, kArrowHeight) controlPoint:CGPointMake(0, kArrowHeight)];
    }else if(self.orientation == ViewOrientationDown)
    {
        [fillPath moveToPoint:CGPointMake(radius, 0)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width-radius, 0)];
        [fillPath addQuadCurveToPoint:CGPointMake(self.bounds.size.width, radius) controlPoint:CGPointMake(self.bounds.size.width, 0)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-kArrowHeight-radius)];
        [fillPath addQuadCurveToPoint:CGPointMake(self.bounds.size.width-radius, self.bounds.size.height-kArrowHeight) controlPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-kArrowHeight)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width/2+(kArrowHeight/2), self.bounds.size.height-kArrowHeight)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width/2, self.bounds.size.height)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width/2-(kArrowHeight/2), self.bounds.size.height-kArrowHeight)];
        [fillPath addLineToPoint:CGPointMake(radius, self.bounds.size.height-kArrowHeight)];
        [fillPath addQuadCurveToPoint:CGPointMake(0, self.bounds.size.height-kArrowHeight-radius) controlPoint:CGPointMake(0, self.bounds.size.height-kArrowHeight)];
        [fillPath addLineToPoint:CGPointMake(0, radius)];
        [fillPath addQuadCurveToPoint:CGPointMake(radius, 0) controlPoint:CGPointMake(0, 0)];
    }else if(self.orientation == ViewOrientationLeft)
    {
        [fillPath moveToPoint:CGPointMake(kArrowHeight+radius, 0)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width-radius, 0)];
        [fillPath addQuadCurveToPoint:CGPointMake(self.bounds.size.width, radius) controlPoint:CGPointMake(self.bounds.size.width, 0)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-radius)];
        [fillPath addQuadCurveToPoint:CGPointMake(self.bounds.size.width-radius, self.bounds.size.height) controlPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
        [fillPath addLineToPoint:CGPointMake(kArrowHeight+radius, self.bounds.size.height)];
        [fillPath addQuadCurveToPoint:CGPointMake(kArrowHeight, self.bounds.size.height-radius) controlPoint:CGPointMake(kArrowHeight, self.bounds.size.height)];
        [fillPath addLineToPoint:CGPointMake(kArrowHeight, self.bounds.size.height/2+(kArrowHeight/2))];//
        [fillPath addLineToPoint:CGPointMake(0, self.bounds.size.height/2)];
        [fillPath addLineToPoint:CGPointMake(kArrowHeight, self.bounds.size.height/2-(kArrowHeight/2))];
        [fillPath addLineToPoint:CGPointMake(kArrowHeight, radius)];
        [fillPath addQuadCurveToPoint:CGPointMake(kArrowHeight+radius, 0) controlPoint:CGPointMake(kArrowHeight, 0)];
    }else if(self.orientation == ViewOrientationRight)
    {
        [fillPath moveToPoint:CGPointMake(radius, 0)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width-kArrowHeight-radius,0)];
        [fillPath addQuadCurveToPoint:CGPointMake(self.bounds.size.width-kArrowHeight, radius) controlPoint:CGPointMake(self.bounds.size.width-kArrowHeight, 0)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width-kArrowHeight, self.bounds.size.height/2-(kArrowHeight/2))];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height/2)];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width-kArrowHeight, self.bounds.size.height/2+(kArrowHeight/2))];
        [fillPath addLineToPoint:CGPointMake(self.bounds.size.width-kArrowHeight, self.bounds.size.height-radius)];
        [fillPath addQuadCurveToPoint:CGPointMake(self.bounds.size.width-kArrowHeight-radius, self.bounds.size.height) controlPoint:CGPointMake(self.bounds.size.width-kArrowHeight, self.bounds.size.height)];
        [fillPath addLineToPoint:CGPointMake(radius, self.bounds.size.height)];
        [fillPath addQuadCurveToPoint:CGPointMake(0, self.bounds.size.height-radius) controlPoint:CGPointMake(0, self.bounds.size.height)];
        [fillPath addLineToPoint:CGPointMake(0, radius)];
        [fillPath addQuadCurveToPoint:CGPointMake(radius, 0) controlPoint:CGPointMake(0, 0)];
    }
    [fillPath closePath];
    
    CGContextAddPath(context, fillPath.CGPath);
    CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextFillPath(context);
}
@end
