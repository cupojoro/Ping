//
//  PGSearchCell.h
//  Ping
//
//  Created by Joseph Ross on 2017-01-08.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGSearchCell : UIView

@property (nonatomic) BOOL inUse;
@property (nonatomic) NSString *gameTitle;
@property (nonatomic) NSString *gameDestination;
@property (nonatomic, strong) UIViewController *parent;

-(id) initWith: (NSString *) title PointingTo:(NSString *) destination withParent:(UIViewController *) vc;
-(void) setTitle: (NSString *) title setDestination: (NSString *) destination buttonVisibile: (BOOL) hidden;
-(void) updateCell;
@end
