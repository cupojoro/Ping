//
//  PGTagEditView.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-17.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PGMapInteraceView.h"
#import "PGMapViewController.h"


@interface PGTagEditView : UIView

-(id)initWithController:(PGMapViewController *)vc;

@property (nonatomic) int selectedIconFlag;
@property (nonatomic) NSString *commentString;

-(void)reset;
-(void)updateOrientation:(ViewOrientation)orientation;
-(void)updateCharacterLabel:(int)charactersLeft;
-(void)setIcons:(NSArray *)iconFlags;

@end
