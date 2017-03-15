//
//  PGMapInteraceView.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGMapInteraceView.h"

#import "PGMenuView.h"
#import "PGTagEditView.h"
#import "PGTagHolderView.h"

#import "Masonry.h"

@interface PGMapInteraceView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIImageView *mapView;
@property (nonatomic, strong) UIView *tagView;

@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIView *viewWithComment;

@property (nonatomic, strong) PGTagEditView *tagEditView;
@property (nonatomic, strong) PGMapViewController *controller;
@property (nonatomic) NSNumber *scrollZoom;

@property (nonatomic, strong) PGTagHolderView *referenceTag;

@property (nonatomic, strong) PGMenuView *menuView;

@end

@implementation PGMapInteraceView

-(id)initWithController:(PGMapViewController *)vc
{
    self = [super init];
    
    self.controller = vc;
    self.scrollZoom = @(1);
    
    self.tagView = [[UIView alloc] init];
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(tagViewGesture:)];
    [self.tagView addGestureRecognizer:rec];
    
    self.mapView = [[UIImageView alloc] init];
    self.mapView.tag = -1;
    self.mapView.contentMode = UIViewContentModeScaleToFill;
    [self.tagView addSubview:self.mapView];
    
    self.contentView = [[UIScrollView alloc] init];
    
    self.contentView.delegate = self;
    [self.contentView setScrollEnabled:YES];
    self.contentView.bounces = NO;
    self.contentView.bouncesZoom = NO;
    [self.contentView setMinimumZoomScale:1.0];
    [self.contentView setMaximumZoomScale:5.0];
    self.contentView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.tagView];
    [self addSubview:self.contentView];
    
    self.tagEditView = [[PGTagEditView alloc] initWithController:vc];
    self.tagEditView.hidden = YES;
    [self addSubview:self.tagEditView]; //THIS IS IMPORTANT TO HAVE THE SUPERVIEW BE THE INTERFACE FOR TAGEDIT SELECTEDICON
    
    self.menuView = [[PGMenuView alloc] initWithController:vc];
    [self addSubview:self.menuView];
    [self bringSubviewToFront:self.menuView];
    [self makeConstraints];
    
    return self;
}

-(void)makeConstraints
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(self);
        make.width.equalTo(self);
        make.center.equalTo(self);
    }];
    
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@200); //NEEDS TO CHANGE IF BUTTONS CHANGE
        make.height.equalTo(@165); //NEEDS TO CHANGE IF BUTTONS CHANGE
    }];
}

+(NSString *)iconImageNameLookup:(NSNumber *)type
{
    switch ([type intValue]) {
        case 0:
            return @"list";
        case 1:
            return @"checked";
        case 2:
            return @"grid";
        case 3:
            return @"key";
        case 4:
            return @"king";
        case 5:
            return @"placeholder";
        case 6:
            return @"rotate";
        case 7:
            return @"star";
        default:
            return @"cross-out";
    }
}

#pragma mark TagView

-(void)setTagViewWith:(NSArray *)tagArray
{
    [[self.tagView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; //MUTATES ARRAY WHILE REMOVING BUT SUBVIEWS SHOULD RETURN COPY
    [self.tagView addSubview:self.mapView]; //THIS NEEDS TO BE IN THE BACK SO WE ADD IT FIRST
    for(NSDictionary *point in tagArray)
    {
        NSNumber *x = (NSNumber *)point[@"x"];
        NSNumber *y = (NSNumber *)point[@"y"];
        x = @([x floatValue] * self.tagView.frame.size.width/[self.scrollZoom floatValue]);
        y = @([y floatValue] * self.tagView.frame.size.height/[self.scrollZoom floatValue]);
        NSNumber *type = (NSNumber *)point[@"type"];
        PGTagHolderView *holder = [[PGTagHolderView alloc] initWithImage:[PGMapInteraceView iconImageNameLookup:type] andFrame:CGRectMake([x floatValue]-32.0/5.0, [y floatValue]-64.0/5.0, 64.0/5.0, 64.0/5.0)];
        //if([y floatValue] < 70) holder.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI),0, -64/5.0); //SHOULDNT NEED SINCE WE HAVE MAP BUFFER NOW. THE COMMENT TEXT SHOULD NEVER REACH
        holder.tag = [tagArray indexOfObject:point];
        UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self.controller action:@selector(tapHolderGesture:)];
        [holder addGestureRecognizer:rec];
        holder.userInteractionEnabled = YES;
        [self.tagView addSubview:holder];
    }
    //for testing
    /*
     [self.tagEditView setIcons:@[@1,@1,@1,@1,@1,@1,@1]];
     [self.tagEditView updateOrientation:ViewOrientationRight];
     [self.tagEditView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.centerX.equalTo(temp.mas_centerX);
     make.bottom.equalTo(temp.mas_top);
     make.width.equalTo(@260);
     make.height.equalTo(@190);
     }];
     [self bringSubviewToFront:self.tagEditView];
     */
}

-(void)attachCommentLabelToView:(UIView *)view withComment:(NSString *)comment
{
    if(self.commentLabel) [self.commentLabel removeFromSuperview];
    if(self.viewWithComment)
    {
        if(self.viewWithComment.tag == view.tag){
            self.viewWithComment = nil;
            return;
        }
        else self.viewWithComment = view;
    }else self.viewWithComment = view;
    self.commentLabel = [[UILabel alloc] init];
    self.commentLabel.text = comment;
    self.commentLabel.layer.cornerRadius = 5.0;
    self.commentLabel.layer.masksToBounds = YES;
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.textAlignment = NSTextAlignmentCenter;
    self.commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.commentLabel.font = [UIFont systemFontOfSize:8];
    [self.commentLabel setBackgroundColor:[UIColor whiteColor]];
    [view.superview addSubview:self.commentLabel];
    if(view.frame.origin.x > self.bounds.size.width/2)
    {
        [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(view.mas_left);
            make.bottom.equalTo(view.mas_bottom);
            make.width.equalTo(@95);
        }];
    }else
    {
        [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_right);
            make.bottom.equalTo(view.mas_bottom);
            make.width.equalTo(@95);
        }];
    }
    [self.contentView zoomToRect:view.frame animated:YES];
}
#pragma mark TagEdit

-(void)inTagEditMode:(BOOL)inMode
{
    self.contentView.scrollEnabled = !inMode;
    if(inMode) self.controller.mode = ModeTagEdit;
    else self.controller.mode = ModeEdit;
}

-(int)returnIconSelect
{
    return self.tagEditView.selectedIconFlag;
}

-(NSString *)returnCommentString
{
    return self.tagEditView.commentString;
}

-(void)hideEdit
{
    if(self.referenceTag) [self.referenceTag removeFromSuperview];
    self.referenceTag = nil;
    self.tagEditView.hidden = YES;
    [self.tagEditView reset];
    self.contentView.minimumZoomScale = 1.0;
}

-(void)createTagForEdit:(NSArray *)iconList withXPerc:(float)x andYPerc:(float)y
{
    if(self.referenceTag) [self.referenceTag removeFromSuperview];
    
    float xPos = x * self.tagView.frame.size.width;
    float yPos = y * self.tagView.frame.size.height;
    PGTagHolderView *holder = [[PGTagHolderView alloc] initWithNoImageAndFrame:CGRectMake(xPos/[self getZoom]-32.0/5.0, yPos/[self getZoom]-64.0/5.0, 64.0/5.0, 64.0/5.0)];
    holder.tag = -2; //NEEDED TO KEEP THIS OUT OF COLLISSION DETECTION FOR MINIMUM DISTANCE
    [self.tagView addSubview:holder];
    self.referenceTag = holder;
    
    [self.contentView zoomToRect:holder.frame animated:YES];
    
    [self.tagEditView setIcons:iconList];
}

-(void)updateTagHolderImage:(int)type
{
    NSString *imageName = [PGMapInteraceView iconImageNameLookup:@(type)];
    [self.referenceTag updateImage:imageName];
}

-(void)layoutTagEdit
{
    //IF IT SCROLLS AND ZOOMS THIS GETS CALLED TWICE
    if(self.referenceTag)
    {
        self.contentView.minimumZoomScale = 5.0;
        self.tagEditView.hidden = NO;
        CGPoint originInWindow = [self.tagView convertPoint:self.referenceTag.frame.origin toView:nil];
        self.tagEditView.frame = CGRectMake(originInWindow.x+64,originInWindow.y-190/2+64/2,260, 190);
        [self.tagView bringSubviewToFront:self.tagEditView];
        [self.tagView setNeedsDisplay];
    }
}
#pragma  mark Frames

-(void)setFrames
{
    if([self.scrollZoom intValue] != 1) NSLog(@"SETTING FRAMES WHEN IN ZOOM");
    self.tagView.frame = self.contentView.frame;
    self.mapView.frame = self.tagView.frame;
}

-(void)setMapImage:(NSURL *)url
{
    [self.mapView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
}

#pragma mark ScrollView

-(float)getZoom
{
    return [self.scrollZoom floatValue];
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.tagView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.scrollZoom = @(scale);
    [self layoutTagEdit];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self layoutTagEdit];
}
@end
