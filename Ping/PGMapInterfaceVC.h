//
//  PGMapInterfaceVC.h
//  Ping
//
//  Created by Joseph Ross on 2017-01-08.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGMapInterfaceVC : UIViewController

typedef enum
{
    KeyView = (1 << 0),
    CrownView = (1 << 1),
    MoneyView = (1 << 2)
} ViewState;

typedef enum
{
    ViewMode = 1,
    VoteMode = 2,
    EditMode = 3
} StatusModes;

-(id)initWithURL: (NSURL *)url andGrid: (NSMutableArray *)gData andTitle: (NSString*) title andMap: (NSString *) name;

-(void)updateIconColor:(id)sender;
-(void)updateFilter;
-(void)updateStatusMode:(id)sender;
-(void)gridButtonSwitch;
-(void)updateGeoID:(id)sender;
-(void)updateViewFlag:(id)sender;
-(void)toggleToolbar;
-(void)castVote:(id)sender;
-(void)updateCurrentCell:(NSNumber *)cell;
-(void)updateStatusBarForVote;
-(void)updateStatusBarForEdit;

-(void)reloadMapDataWithVoter:(BOOL)update;

-(NSString *)getGameName;
-(NSString *)getMapName;
-(int)getCurrentCell;

-(UIColor *)getTintColor;
-(NSInteger)getGeoID;
-(BOOL)getCellEditMode;
-(NSInteger)getStarFilterValue;

-(StatusModes)getStatusMode;
-(unsigned int)getViewFlag;

@end
