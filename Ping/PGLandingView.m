//
//  PGLandingView.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGLandingView.h"
#import "PGGradientView.h"

#import "Masonry.h"

@interface PGLandingView () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIImageView *titleImage;
@property (nonatomic, strong) UIImageView *pingImage;

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *statusView;

@property (nonatomic, strong) UILabel *notificationLabel;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UIButton *acceptButton;

@property (nonatomic, strong) UIImageView *braceLeft;
@property (nonatomic, strong) UIImageView *braceRight;

@property (nonatomic, strong) CATransition *backgroundRipple;

@end

@implementation PGLandingView

-(id)initWithController:(PGLandingViewController *) vc IsFirstLogin:(BOOL)newUser
{
    self = [super init];
    
    self.backgroundView = [[PGGradientView alloc] init];
    self.backgroundView.userInteractionEnabled = NO;
    [self addSubview:self.backgroundView];
    
    self.titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Title"]];
    [self.titleImage setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview: self.titleImage];
    
    UIImage *pingImage0 = [UIImage imageNamed:@"PingTitle0"];
    UIImage *pingImage1 = [UIImage imageNamed:@"PingTitle1"];
    UIImage *pingImage2 = [UIImage imageNamed:@"PingTitle2"];
    
    self.pingImage = [[UIImageView alloc] initWithImage:pingImage2];
    [self.pingImage setContentMode:UIViewContentModeScaleAspectFit];
    self.pingImage.animationImages = [[NSArray alloc] initWithObjects:pingImage0, pingImage1, pingImage2, nil];
    self.pingImage.animationDuration = 1.2;
    self.pingImage.animationRepeatCount = 1;
    [self addSubview: self.pingImage];
    
    self.statusLabel = [[UILabel alloc] init];
    [self.statusLabel setText:@"Connecting to server:"];
    [self addSubview:self.statusLabel];
    
    self.statusView = [[UIImageView alloc] init];
    [self.statusView setContentMode:UIViewContentModeScaleAspectFit];
    self.statusView.animationImages = [[NSArray alloc] initWithObjects:pingImage0, pingImage1, pingImage2, nil];
    self.statusView.animationDuration = 2;
    
    [self addSubview:self.statusView];
    if(newUser){
        
        self.notificationLabel = [[UILabel alloc] init];
        [self.notificationLabel setText:@"Please enter a username:"];
        [self addSubview:self.notificationLabel];
        
        self.usernameField = [[UITextField alloc] init];
        [self.usernameField setPlaceholder:@"Enter Username Here"];
        self.usernameField.clearsOnBeginEditing = YES;
        [self.usernameField setDelegate:self];
        [self.usernameField setTextColor:[UIColor blackColor]];
        [self.usernameField setMinimumFontSize:60];
        [self.usernameField setTextAlignment:NSTextAlignmentCenter];
        [self.usernameField setKeyboardType:UIKeyboardTypeNamePhonePad];
        [self.usernameField addTarget:self action:@selector(textFieldRecievedTouch) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.usernameField];
        
        
        self.acceptButton = [[UIButton alloc] init];
        [self.acceptButton setBackgroundImage:[UIImage imageNamed:@"ButtonFrame"] forState:UIControlStateNormal];
        [self.acceptButton setTitle:@"Register Username" forState:UIControlStateNormal];
        [self.acceptButton addTarget:vc action:@selector(checkUsername) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.acceptButton];
        
        UIImage *braceImage = [UIImage imageNamed:@"Brace"];
        self.braceLeft = [[UIImageView alloc] initWithImage:braceImage];
        UIImage *flippedBrace = [UIImage imageWithCGImage:braceImage.CGImage scale:1 orientation:UIImageOrientationDown];
        self.braceRight = [[UIImageView alloc] initWithImage:flippedBrace];
        [self addSubview:self.braceLeft];
        [self addSubview:self.braceRight];
        
        
        self.statusLabel.hidden = YES;
        self.statusView.hidden = YES;
    }
    
    [self makeConstraints:newUser];
    
    
    return self;
}

#pragma mark Constraints

-(void)makeConstraints:(BOOL)newUser
{
    [self.titleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY).dividedBy(2);
        make.width.equalTo(@400);
    }];
    
    [self.pingImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).dividedBy(2).with.offset(2);
        make.width.equalTo(@400);
        make.centerX.equalTo(self.mas_centerX).with.offset(0);
    }];
    
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    [self.statusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.statusView.mas_left);
        make.centerX.lessThanOrEqualTo(self.mas_centerX);
    }];
    
    [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.statusLabel.mas_right);
        make.width.height.equalTo(@64);
    }];
    if(newUser){
        [self.notificationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_centerX);
            make.centerY.equalTo(self).with.offset(-100);
        }];
        
        [self.usernameField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.notificationLabel.mas_bottom).with.offset(15);
            make.centerX.equalTo(self.mas_centerX);
            make.height.greaterThanOrEqualTo(@44);
        }];
        
        [self.braceLeft mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.usernameField.mas_left);
            make.height.equalTo(@22);
            make.centerY.equalTo(self.usernameField.mas_centerY);
        }];
        
        [self.braceRight mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.usernameField.mas_right);
            make.height.equalTo(@22);
            make.centerY.equalTo(self.usernameField.mas_centerY);
        }];
        
        [self.acceptButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.usernameField.mas_bottom).with.offset(15);
            make.centerX.equalTo(self.mas_centerX);
        }];
    }
}

#pragma mark Animations and Views

-(void)startAnimations
{
    
    [self.pingImage performSelector:@selector(startAnimating) withObject:nil afterDelay:0.5];
    [self.statusView startAnimating];
    
    self.backgroundRipple =[CATransition animation];
    [self.backgroundRipple setDuration:2.5];
    [self.backgroundRipple setTimingFunction:UIViewAnimationCurveEaseInOut];
    //[self.backgroundRipple setType:@"rippleEffect"];
    self.backgroundRipple.repeatCount = MAXFLOAT;
    //[self.backgroundView.layer addAnimation:self.backgroundRipple forKey:nil];
}

-(void)setupForRegistration:(BOOL)success
{
    self.statusView.hidden = !success;
    if(!success)
    {
        self.notificationLabel.text = @"Please enter a username:";
        
        [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.statusLabel.mas_right);
            make.width.height.equalTo(@64);
        }];
    }
    else
    {
        self.notificationLabel.text = @"Registering Username";
        [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.notificationLabel.mas_right);
            make.centerY.equalTo(self.notificationLabel.mas_centerY);
            make.width.equalTo(@64);
        }];
    }
}

-(void)hideForLogin
{
    self.usernameField.hidden = YES;
    self.acceptButton.hidden = YES;
    self.notificationLabel.hidden = YES;
    self.braceLeft.hidden = YES;
    self.braceRight.hidden = YES;
    self.statusView.hidden = NO;
    self.statusLabel.hidden = NO;
    [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.statusLabel.mas_right);
        make.width.height.equalTo(@64);
    }];
}

#pragma mark Text Field

-(NSString *)getUserInput
{
    return self.usernameField.text;
}

-(void)textFieldRecievedTouch {
    //self.backgroundView.frame = [[self.backgroundView.layer presentationLayer] frame];
    //[self.backgroundView.layer removeAllAnimations];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.usernameField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    //[self.backgroundView.layer addAnimation:self.backgroundRipple forKey:nil];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *validUsernameSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"];
    if([string rangeOfCharacterFromSet:[validUsernameSet invertedSet]].location != NSNotFound) return NO;
    if(range.length + range.location > textField.text.length) return NO;
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 12;
}
@end
