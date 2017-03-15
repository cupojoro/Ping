//
//  PGSplash.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-08.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//
#import "PGSplashVC.h"
#import "PGHomeVC.h"

#import "Firebase.h"
#import "Masonry.h"

@interface PGSplashVC ()

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *statusView;

@end

@implementation PGSplashVC

-(id)init
{
    self = [super init];
    if(self){
        [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            //User Signed In Anonymously
            //User object has user id :: user.uid
            NSLog(@"\n ANON : %@", user.uid);
            [self.statusView.layer removeAllAnimations];
            [self.navigationController pushViewController:[[PGHomeVC alloc] init] animated:NO];
        }];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if([FIRAuth auth].currentUser == NULL){
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splashBG"]];
        [self.view addSubview:self.backgroundView];
        
        self.statusLabel = [[UILabel alloc] init];
        [self.statusLabel setText:@"Connecting to Server"];
        [self.view addSubview:self.statusLabel];
        
        self.statusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rotate"]];
        [self.view addSubview:self.statusView];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self applyMASConstraints];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:3.5 delay:0 options:UIViewAnimationOptionRepeat animations:^{
        self.statusView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
       //To Jumpy
        self.statusView.transform = CGAffineTransformIdentity;
        self.statusView.transform = CGAffineTransformMakeScale(-1, -1);
    }];
}

-(void) applyMASConstraints
{
   [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.size.equalTo(self.view);
       make.center.equalTo(self.view);
   }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY);
        make.right.equalTo(self.statusLabel.mas_left);
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
