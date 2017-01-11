//
//  PGToolbarView.h
//  Ping
//
//  Created by Joseph Ross on 2017-01-10.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGToolbarView : UIView
-(id)initWithToolbarHeight:(int)tbHeight toolBarSectionHeight:(int) secHeight mapInterface:(PGMapInterfaceVC *) mapIV;

-(void)clearButtonHighlights;

@end
