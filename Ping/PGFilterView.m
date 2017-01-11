//
//  PGFilterView.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-10.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGFilterView.h"

#import "Masonry.h"

@interface PGFilterView () <UITextFieldDelegate>

@property (nonatomic, strong) PGMapInterfaceVC *mapInterface;

//THIS SHOULD PROBABLY BE HANDLED AS A POPOVER
@property (nonatomic, strong) UIView *filterView;
@property (nonatomic, strong) UILabel *starFilterLabel;
@property (nonatomic, strong) UILabel *colorFilterLabel;
@property (nonatomic, strong) UITextField *starFilterField;
@property (nonatomic, strong) UIView *colorFilterView;
@property (nonatomic, strong) UIButton *blackButton;
@property (nonatomic, strong) UIButton *redButton;
@property (nonatomic, strong) UIButton *whiteButton;
@property (nonatomic, strong) UIButton *filterAccept;

@end
@implementation PGFilterView

NSInteger starFilter = 0;

-(id)initWithMapInterface: (PGMapInterfaceVC *) mapIV
{
    self = [super init];
    
    self.hidden = YES;
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.mapInterface = mapIV;
    
    self.starFilterLabel =[[UILabel alloc] init];
    [self.starFilterLabel setText:@"Shows icons with star rating of atleast:"];
    [self.filterView addSubview:self.starFilterLabel];
    
    self.colorFilterLabel = [[UILabel alloc] init];
    [self.colorFilterLabel setText:@"Change icon color"];
    [self.filterView addSubview:self.colorFilterLabel];
    
    self.starFilterField = [[UITextField alloc] init];
    [self.starFilterField setPlaceholder:@"0"];
    self.starFilterField.clearsOnBeginEditing = YES;
    [self.starFilterField setDelegate:self];
    [self.starFilterField setTextColor:[UIColor blackColor]];
    [self.starFilterField setTextAlignment:NSTextAlignmentCenter];
    [self.starFilterField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.starFilterField reloadInputViews];
    [self.filterView addSubview:self.starFilterField];
    
    self.colorFilterView = [[UIView alloc] init];
    [self.filterView addSubview:self.colorFilterView];
    
    self.blackButton = [[UIButton alloc] init];
    self.blackButton.tag = 1;
    [self.blackButton setBackgroundColor:[UIColor blackColor]];
    [self.blackButton addTarget:self.mapInterface action:@selector(updateIconColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.colorFilterView addSubview:self.blackButton];
    
    self.redButton = [[UIButton alloc] init];
    self.redButton.tag = 2;
    [self.redButton setBackgroundColor:[UIColor redColor]];
    [self.redButton addTarget:self.mapInterface action:@selector(updateIconColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.colorFilterView addSubview:self.redButton];
    
    self.whiteButton = [[UIButton alloc] init];
    self.whiteButton.tag = 3;
    [self.whiteButton setBackgroundColor:[UIColor whiteColor]];
    [self.whiteButton addTarget:self.mapInterface action:@selector(updateIconColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.colorFilterView addSubview:self.whiteButton];
    
    self.filterAccept = [[UIButton alloc] init];
    [self.filterAccept setTitle:@"ACCEPT" forState:UIControlStateNormal];
    [self.filterAccept addTarget:self.mapInterface action:@selector(updateFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.filterView addSubview:self.filterAccept];
    
    [self applyMASConstraints];
    
    return self;
}

-(void) applyMASConstraints
{
    [self.filterAccept mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.filterView);
        make.bottom.equalTo(self.filterView);
        make.left.equalTo(self.filterView.mas_left);
    }];
    
    [self.starFilterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.filterView.mas_left);
        make.centerY.equalTo(self.filterView.mas_bottom).dividedBy(3);
        make.width.lessThanOrEqualTo(self.filterView.mas_width).multipliedBy(0.75);
    }];
    
    [self.starFilterField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.starFilterLabel.mas_right);
        make.centerY.equalTo(self.starFilterLabel.mas_centerY);
        make.right.equalTo(self.filterView.mas_right);
    }];
    
    [self.colorFilterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.filterView.mas_left);
        make.centerY.equalTo(self.filterView.mas_bottom).multipliedBy(0.66);
        make.width.lessThanOrEqualTo(self.filterView.mas_width).multipliedBy(0.75);
    }];
    
    [self.colorFilterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.colorFilterLabel.mas_right);
        make.right.equalTo(self.filterView.mas_right);
        make.centerY.equalTo(self.colorFilterLabel.mas_centerY);
    }];
    
    [self.blackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.colorFilterView);
        make.left.equalTo(self.colorFilterView);
        make.bottom.equalTo(self.colorFilterView);
        make.width.equalTo(self.colorFilterView).dividedBy(3);
    }];
    
    [self.redButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.colorFilterView);
        make.center.equalTo(self.colorFilterView);
        make.width.equalTo(self.colorFilterView).dividedBy(3);
    }];
    
    [self.whiteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.colorFilterView);
        make.right.equalTo(self.colorFilterView);
        make.bottom.equalTo(self.colorFilterView);
        make.width.equalTo(self.colorFilterView).dividedBy(3);
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    starFilter = [textField.text integerValue];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location != NSNotFound) return NO;
    if(range.length + range.location > textField.text.length) return NO;
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 5;
}

@end
