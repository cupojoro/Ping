//
//  PGGameView.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PGGamePageViewController.h"

@interface PGGameView : UIView

-(id)initWithController:(PGGamePageViewController *)vc;

-(void)setCoverImage:(NSURL *) url;
-(void)reloadTable;

@end
