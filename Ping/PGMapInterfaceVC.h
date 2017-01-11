//
//  PGMapInterfaceVC.h
//  Ping
//
//  Created by Joseph Ross on 2017-01-08.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGMapInterfaceVC : UIViewController 
-(id)initWithURL: (NSURL *)url andGrid: (NSMutableArray *)gData;
-(void)updateIconColor:(id)sender;
-(void)updateFilter;
-(void)updateStatusMode:(id)sender;
-(void)gridButtonSwitch;
-(void)updateGeoID:(id)sender;

-(UIColor *)getTintColor;
-(NSInteger)getGeoID;

@end
