//
//  PGLandingViewController.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGLandingViewController.h"

#import "PGHomeViewController.h"
#import "PGLandingModel.h"
#import "PGLandingView.h"

@interface PGLandingViewController ()

@property (nonatomic, strong) PGLandingModel *landingData;
@property (nonatomic, strong) PGLandingView *landingView;

@end

@implementation PGLandingViewController

-(id)init
{
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popError:) name:@"PGError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popInfo:) name:@"PGInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushHome) name:@"PGLoginComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login) name:@"PGUserEntryCreated" object:nil];
    self.landingData = [[PGLandingModel alloc] init:self];
    
    self.landingView = [[PGLandingView alloc] initWithController:self IsFirstLogin:[self.landingData getFirstLogin]];
    
    
    [self.view addSubview:self.landingView];
    
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    self.landingView.frame = self.view.frame;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.landingView startAnimations];
    [self.view setNeedsDisplay];
}
-(void)pushHome
{
    [self.navigationController pushViewController:[[PGHomeViewController alloc] init] animated:NO];
}

-(void)login
{
    [self.landingView hideForLogin];
    [self.landingData login];
}

-(void)popError:(NSNotification *)notification
{
    NSString *message = [notification object];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {[alert dismissViewControllerAnimated:YES completion:nil];}];
    
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];
    [self.landingView setupForRegistration:NO];
}

-(void)popInfo:(NSNotification *)notification
{
    NSString *message = [notification object];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Hello There!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {[alert dismissViewControllerAnimated:YES completion:nil];}];
    
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)checkUsername
{
    [self.landingView setupForRegistration:YES];
    [self.landingView resignFirstResponder];
    [self.landingData validateUsername:[self.landingView getUserInput]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
