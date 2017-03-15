//
//  PGMapViewController.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//
#define MapBuffer 64

#import <UIKit/UIKit.h>

@interface PGMapViewController : UIViewController 

typedef enum
{
    ModeEdit = 0,
    ModeView = 1,
    ModeVote = 2,
    ModeTagEdit = 3
}ControllerMode;

@property (nonatomic) ControllerMode mode;


-(id)initWithMapPath:(NSString *)path;
-(void)tagViewGesture:(UIGestureRecognizer *)recognizer;

-(void)tagViewConfirm;
-(void)tagViewCancel;

-(void)tapHolderGesture:(UIGestureRecognizer *)gesture;
-(void)forceTagCheck;

-(void)changeMode:(id)sender;
-(void)popSettings;

+(int)userRankToVotes;
@end
 
