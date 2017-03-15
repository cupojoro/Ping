//
//  PGMapInteraceView.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PGMapViewController.h"

@interface PGMapInteraceView : UIView

typedef enum
{
    ViewOrientationUp = 0,
    ViewOrientationDown = 1,
    ViewOrientationLeft = 2,
    ViewOrientationRight = 3
} ViewOrientation;

-(id)initWithController:(PGMapViewController *)vc;

-(void)setTagViewWith:(NSArray *)tagArray;
-(void)setFrames;
-(void)setMapImage:(NSURL *)url;
-(float)getZoom;
-(int)returnIconSelect;
-(NSString *)returnCommentString;
-(void)hideEdit;
+(NSString *)iconImageNameLookup:(NSNumber *)type;
-(void)attachCommentLabelToView:(UIView *)view withComment:(NSString *)comment;
-(void)createTagForEdit:(NSArray *)iconList withXPerc:(float)x andYPerc:(float)y;
-(void)inTagEditMode:(BOOL)inMode;
-(void)updateTagHolderImage:(int)type;
@end
