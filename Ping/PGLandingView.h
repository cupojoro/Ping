//
//  PGLandingView.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PGLandingViewController.h"

@interface PGLandingView : UIView

-(id)initWithController:(PGLandingViewController *) vc IsFirstLogin:(BOOL)newUser;
-(void)startAnimations;
-(void)hideForLogin;
-(NSString *)getUserInput;
-(void)setupForRegistration:(BOOL)success;
@end
