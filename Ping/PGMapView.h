//
//  PGMapView.h
//  Ping
//
//  Created by Joseph Ross on 2017-01-10.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "PGMapInterfaceVC.h"

@interface PGMapView : UIView

-(id) initWithMapInterface:(PGMapInterfaceVC *)mapIV andGridSize:(int)size andGridData:(NSMutableArray *)gData;
-(void)gridSwitch;
-(void)reloadGridWithVoters:(BOOL)update;
-(bool)hasItemAtIndex:(int)cell;
-(void)forceGrid:(BOOL)value;
@end
