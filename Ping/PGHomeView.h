//
//  PGHomeView.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PGHomeViewController.h"
#import "PGSearchCell.h"

@interface PGHomeView : UIView

-(id)initWithController:(PGHomeViewController *)controller;
-(CGPoint)getContentOffset;
-(void)setCurrentPage:(NSInteger) page;
-(void)clearSearchCells;
-(void)setCellsWithGame:(NSArray *)titles andDestinations:(NSArray *)dest;
-(PGSearchCell *)cellWithTag:(int)number;
@end
