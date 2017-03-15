//
//  PGLandingModel.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PGLandingViewController.h"

@interface PGLandingModel : NSObject

-(id)init:(PGLandingViewController *)creator;

-(void)login;
-(void)validateUsername:(NSString *)name;
-(BOOL)getFirstLogin;
@end
