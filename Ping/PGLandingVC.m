//
//  PGLandingVC.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-21.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGLandingVC.h"
#import "PGGradientView.h"
#import "PGHomeVC.h"

#import "Masonry.h"
#import "Firebase.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PGLandingVC () <UITextFieldDelegate> {
    NSString *userName;
    NSNumber *rank;
    BOOL firstLogin;
}

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

@implementation PGLandingVC

-(id)init{
    self = [super init];
    if(self){
        firstLogin = NO;
        /*
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
            plistPath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSError *error;
        NSPropertyListFormat format;
        NSDictionary *temp = (NSDictionary *) [NSPropertyListSerialization dataWithPropertyList:plistXML format:format options:0 error:&error];
        if(!temp){
            NSLog(@"Error reading plist: %@", error);
        }
         */
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"admin" forKey:@"Username"]; //CHANGE THIS LINE TO ACCES OTHER ACCOUNTS
        userName = [defaults objectForKey:@"Username"];
        //userName = nil;
        if(userName == nil){
            firstLogin = YES;
        }else rank = [defaults objectForKey:@"Rank"];
        [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            NSLog(@"ANON SIGNIN");
            if(!firstLogin) [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(login) userInfo:nil repeats:NO];
            
        }];
        //userName = [temp objectForKey:@"Username"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    //[self.view setBackgroundColor:[UIColor lightGrayColor]];
    self.backgroundView = [[PGGradientView alloc] init];
    [self.view addSubview:self.backgroundView];
    
    self.titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Title"]];
    [self.titleImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview: self.titleImage];
    
    UIImage *pingImage0 = [UIImage imageNamed:@"PingTitle0"];
    UIImage *pingImage1 = [UIImage imageNamed:@"PingTitle1"];
    UIImage *pingImage2 = [UIImage imageNamed:@"PingTitle2"];
    
    self.pingImage = [[UIImageView alloc] initWithImage:pingImage2];
    [self.pingImage setContentMode:UIViewContentModeScaleAspectFit];
    self.pingImage.animationImages = [[NSArray alloc] initWithObjects:pingImage0, pingImage1, pingImage2, nil];
    self.pingImage.animationDuration = 1.2;
    self.pingImage.animationRepeatCount = 1;
    [self.view addSubview: self.pingImage];
    
    self.statusLabel = [[UILabel alloc] init];
    [self.statusLabel setText:@"Connecting to server:"];
    [self.view addSubview:self.statusLabel];
    
    self.statusView = [[UIImageView alloc] init];
    [self.statusView setContentMode:UIViewContentModeScaleAspectFit];    self.statusView.animationImages = [[NSArray alloc] initWithObjects:pingImage0, pingImage1, pingImage2, nil];
    self.statusView.animationDuration = 2;
    
    [self.view addSubview:self.statusView];
    if(firstLogin){
        
        self.notificationLabel = [[UILabel alloc] init];
        [self.notificationLabel setText:@"Please enter a username:"];
        [self.view addSubview:self.notificationLabel];
        
        self.usernameField = [[UITextField alloc] init];
        [self.usernameField setPlaceholder:@"Enter Username Here"];
        self.usernameField.clearsOnBeginEditing = YES;
        [self.usernameField setDelegate:self];
        [self.usernameField setTextColor:[UIColor blackColor]];
        [self.usernameField setMinimumFontSize:60];
        [self.usernameField setTextAlignment:NSTextAlignmentCenter];
        [self.usernameField setKeyboardType:UIKeyboardTypeNamePhonePad];
        [self.usernameField addTarget:self action:@selector(textFieldRecievedTouch) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:self.usernameField];
        
        
        self.acceptButton = [[UIButton alloc] init];
        [self.acceptButton setBackgroundImage:[UIImage imageNamed:@"ButtonFrame"] forState:UIControlStateNormal];
        [self.acceptButton setTitle:@"Register Username" forState:UIControlStateNormal];
        [self.acceptButton addTarget:self action:@selector(checkUserName) forControlEvents:UIControlEventTouchUpInside];
        //[self.acceptButton setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:self.acceptButton];
        
        UIImage *braceImage = [UIImage imageNamed:@"Brace"];
        self.braceLeft = [[UIImageView alloc] initWithImage:braceImage];
        UIImage *flippedBrace = [UIImage imageWithCGImage:braceImage.CGImage scale:1 orientation:UIImageOrientationDown];
        self.braceRight = [[UIImageView alloc] initWithImage:flippedBrace];
        [self.view addSubview:self.braceLeft];
        [self.view addSubview:self.braceRight];
        
        self.statusLabel.hidden = YES;
        self.statusView.hidden = YES;
    }
    
    [self.statusView startAnimating];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.backgroundRipple =[CATransition animation];
    //[animation setDelegate:self.backgroundView];
    [self.backgroundRipple setDuration:2.5];
    [self.backgroundRipple setTimingFunction:UIViewAnimationCurveEaseInOut];
    [self.backgroundRipple setType:@"rippleEffect"];
    self.backgroundRipple.repeatCount = MAXFLOAT;
    [self.backgroundView.layer addAnimation:self.backgroundRipple forKey:nil];
    
    if(firstLogin)[NSTimer scheduledTimerWithTimeInterval:1.25 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self.pingImage startAnimating];
    }];
}

- (void)updateViewConstraints{
    [self.titleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).dividedBy(2);
        make.width.equalTo(@400);
    }];
    
    [self.pingImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY).dividedBy(2).with.offset(2);
        make.width.equalTo(@400);
        make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
    }];
    
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
        //make.center.equalTo(self.pingImage);
    }];
    
    [self.statusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY);
        make.right.equalTo(self.statusView.mas_left);
        make.centerX.lessThanOrEqualTo(self.view.mas_centerX);
    }];
    
    [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY);
        make.left.equalTo(self.statusLabel.mas_right);
        make.width.height.equalTo(@64);
    }];
    if(firstLogin){
        [self.notificationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            //make.centerX.equalTo(self.view);
            make.right.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view).with.offset(-100);
        }];
        
        [self.usernameField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.notificationLabel.mas_bottom).with.offset(15);
            make.centerX.equalTo(self.view.mas_centerX);
            //make.height.equalTo(@44);
        }];
        
        [self.braceLeft mas_remakeConstraints:^(MASConstraintMaker *make) {
           // make.left.equalTo(self.view);
            make.right.equalTo(self.usernameField.mas_left);
            make.height.equalTo(@15);
            make.centerY.equalTo(self.usernameField.mas_centerY);
        }];
        
        [self.braceRight mas_remakeConstraints:^(MASConstraintMaker *make) {
           // make.right.equalTo(self.view);
            make.left.equalTo(self.usernameField.mas_right);
            make.height.equalTo(@15);
            make.centerY.equalTo(self.usernameField.mas_centerY);
        }];
        
        [self.acceptButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.usernameField.mas_bottom).with.offset(15);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    
    [super updateViewConstraints];
}

-(void)textFieldRecievedTouch {
    NSLog(@"TOUCH");
    self.backgroundView.frame = [[self.backgroundView.layer presentationLayer] frame];
    [self.backgroundView.layer removeAllAnimations];
    
}

- (void)login{
    self.usernameField.hidden = YES;
    self.acceptButton.hidden = YES;
    self.notificationLabel.hidden = YES;
    self.braceLeft.hidden = YES;
    self.braceRight.hidden = YES;
    self.statusView.hidden = NO;
    self.statusLabel.hidden = NO;
    
    if(!firstLogin){
        FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        [[[dBref child:@"userList"] child:userName] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSString *lastLogin = (NSString *) snapshot.value[@"login"];
            NSDate *lastLoginDate = [dateFormatter dateFromString:lastLogin];
            NSTimeInterval timeBetween = [date timeIntervalSinceDate:lastLoginDate];
            NSInteger hours = timeBetween / 3600;
            NSNumber *dBRank = (NSNumber *) snapshot.value[@"rank"];
            BOOL rankChange = ![dBRank isEqualToNumber:rank];
            if(hours > 12 || rankChange){
                NSLog(@"12 HOUR RESET");
                NSString *path = [NSString stringWithFormat:@"userList/%@/login", userName];
                [[dBref child:path] setValue:dateString];
                [[NSUserDefaults standardUserDefaults] setValue:dBRank forKey:@"Rank"];
                rank = dBRank;
                NSNumber *countReset = @10000;
                NSNumber *editReset = @10000;
                switch (dBRank.integerValue)
                {
                    case 0:
                        countReset = @5;
                        editReset = @0;
                        break;
                    case 1:
                        countReset = @10;
                        editReset = @0;
                        break;
                    case 2:
                        countReset = @15;
                        editReset = @1;
                        break;
                    case 3:
                        countReset = @20;
                        editReset = @5;
                        break;
                    case 4:
                        countReset = @30;
                        editReset = @10;
                        break;
                    case 5:
                        countReset = @10000;
                        editReset = @10000;
                        break;
                    case 6:
                        countReset = @10000;
                        editReset = @10000;
                        break;
                    default:
                        countReset = @0;
                        editReset = @0;
                        break;
                }
                [[[[dBref child:@"userList"] child:userName] child:@"soft"] setValue:countReset];
                [[[[dBref child:@"userList"] child:userName] child:@"edits"] setValue:editReset];
            }
        }];
        
    }
    [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        
        NSLog(@"USERNAME : %@", userName);
        NSLog(@"RANK : %@", rank);
        [self.navigationController pushViewController:[[PGHomeVC alloc] init] animated:NO];
    }];
}

- (void)checkUserName{
    if(userName.length < 1 || userName == nil) return;
    NSString *officialUsername = [userName stringByAppendingString:@"(1)"];
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    //THIS REQUIRES THE WHOLE USERLIST TO DOWNLOAD
    [[dBref child:@"userList"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *user = (NSString *) snapshot.value[officialUsername];
        if(user){
            //USER EXISTS
            NSNumber *loc = (NSNumber *) snapshot.value[officialUsername][@"origin"];
            loc = [NSNumber numberWithInteger:[loc intValue] + 1];
            NSString *path = [NSString stringWithFormat:@"userList/%@/origin", officialUsername];
            [[dBref child:path] setValue:loc];
            NSMutableString *finalName = [[NSMutableString alloc] initWithString:userName];
            [finalName appendString:@"("];
            [finalName appendString:[loc stringValue]];
            [finalName appendString:@")"];
            [[NSUserDefaults standardUserDefaults] setObject:finalName forKey:@"Username"];
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"Rank"];
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:date];
            NSLog(@"%@",dateString);
            [[[dBref child:@"userList"] child:finalName] setValue:@{@"rank":@0, @"hard":@5, @"soft":@5,@"edits":@0,@"login":dateString}];
            [self login];
        }else{
            //NO USER
            [[NSUserDefaults standardUserDefaults] setObject:officialUsername forKey:@"Username"];
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"Rank"];
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:date];
            [[[dBref child:@"userList"] child:officialUsername] setValue:@{@"rank":@0, @"hard":@5, @"soft":@5,@"edits":@0,@"login":dateString}];
            [self login];
        }
    }withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.usernameField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    NSLog(@"Finished Editing");
    userName = textField.text;
    [self.backgroundView.layer addAnimation:self.backgroundRipple forKey:nil];
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
