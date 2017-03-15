//
//  PGFilterView.h
//  Ping
//
//  Created by Joseph Ross on 2017-01-10.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PGMapInterfaceVC.h"

@interface PGFilterView : UIView
-(id)initWithMapInterface: (PGMapInterfaceVC *) mapIV;

-(NSInteger)getStarFilterValue;

@end
