//
//  PGMapViewController.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#define MinimumIconDistance 12.8

#import "PGMapViewController.h"

#import "PGMapInteraceView.h"
#import "PGMapModel.h"

#import "Masonry.h"
#import "Firebase.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PGMapViewController ()

@property (nonatomic, strong) PGMapInteraceView *mapInterfaceView;
@property (nonatomic, strong) PGMapModel *mapModel;

@property (nonatomic, strong) NSString *mapPath;

@property (nonatomic) float tapXCordPercentage;
@property (nonatomic) float tapYCordPercentage;
@property (nonatomic) NSString *commentString;
@property (nonatomic) int iconSelected;
@property (nonatomic) UIView *stagingView;

@property (nonatomic) int inEditFlag;
@property (nonatomic, strong) NSTimer *editTimer;
@property (nonatomic) int currentIndex;

@end

@implementation PGMapViewController

-(id)initWithMapPath:(NSString *)path
{
    self = [super init];
    
    self.mapPath = path;
    self.mode = ModeEdit;
    self.inEditFlag = 0;
    self.currentIndex = -1;
    self.mapModel = [[PGMapModel alloc] initWithController:self andMapPath:path];
    self.mapInterfaceView = [[PGMapInteraceView alloc] initWithController:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanNodeSuccess:) name:@"PGCleanNodeSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagLocationSuccess) name:@"PGTagLocationSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagCommentSuccess) name:@"PGTagCommentSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagVoteSuccess) name:@"PGTagVoteSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentRetreval:) name:@"PGCommentRetreval" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconRetreval:) name:@"PGIconListRetreval" object:nil];
    
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[dBref child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSURL *url = [NSURL URLWithString:(NSString *) snapshot.value[@"imageURL"]];
        [self.mapInterfaceView setMapImage:url];
        [self.mapInterfaceView setFrames];
    }];
    [[dBref child:path] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(self.mode != ModeTagEdit){
            NSArray *tagLocations = (NSArray *) snapshot.value[@"tagLocations"];
            [self.mapInterfaceView setTagViewWith:tagLocations];
            [self.view setNeedsDisplay];
            [self.view setNeedsLayout];
        }
        
    }];
    
    [self.view addSubview:self.mapInterfaceView];
    
    [self.mapInterfaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapInterfaceView.frame = self.view.frame;
    [self.mapInterfaceView setFrames];
    
}

#pragma mark Buttons

-(void)tagViewCancel
{
    [self.mapInterfaceView hideEdit];
    [self.mapInterfaceView inTagEditMode:NO];
    [self forceTagCheck];
}

-(void)tagViewConfirm
{
    
    self.iconSelected = [self.mapInterfaceView returnIconSelect];
    self.commentString = [self.mapInterfaceView returnCommentString];
    [self.mapModel createNode];
    [self.editTimer invalidate];
}

-(void)popSettings
{
    
}

-(void)changeMode:(id)sender
{
    UIView *sendie = (UIView *)sender;
    if(sendie.tag == 1)
    {
        self.mode = ModeView;
    }else if(sendie.tag == 2)
    {
        self.mode = ModeVote;
    }else if(sendie.tag == 3)
    {
        self.mode = ModeEdit;
    }else
    {
        NSLog(@"Unrecognized sender sent to selector:ChangeMode:(id)sender");
    }
}

#pragma mark Notifications

-(void)cleanNodeSuccess:(NSNotification *) notification
{
    //IF PGERROR IS THROWN NEED TO HANDLE clean up of remaining nodes //I THINK THIS IS HANDLED NOW BY THE MODEL
    NSNumber *index = [notification object];
    [self.mapModel setTagLocationX:self.tapXCordPercentage Y:self.tapYCordPercentage atIndex:[index intValue] withType:self.iconSelected];
    [self.mapModel setCommentAtIndex:[index intValue] withText:self.commentString];
    [self.mapModel addUserToVoters:YES atIndex:[index intValue] forTotal:[PGMapViewController userRankToVotes]];
    self.currentIndex = [index intValue];
}

-(void)tagLocationSuccess
{
    //NSLog(@"Location added");
    [self updateInEditFlag];
}

-(void)tagCommentSuccess
{
    //NSLog(@"Comment Added");
    [self updateInEditFlag];
}

-(void)tagVoteSuccess
{
    //NSLog(@"Vote Added");
    [self updateInEditFlag];
}

-(void)commentRetreval:(NSNotification *)notification
{
    NSString *comment = [notification object];
    [self.mapInterfaceView attachCommentLabelToView:self.stagingView withComment:comment];
}

-(void)iconRetreval:(NSNotification *)notification
{
    NSArray *icons = (NSArray *) [notification object];
    [self.mapInterfaceView createTagForEdit:icons withXPerc:self.tapXCordPercentage andYPerc:self.tapYCordPercentage];
}

-(void)updateInEditFlag
{
    self.inEditFlag++;
    if(self.inEditFlag == 3)
    {
        self.inEditFlag = 0;
        [self forceTagCheck];
        [self.mapInterfaceView hideEdit];
        [self.mapInterfaceView inTagEditMode:NO];
        [self.mapModel returnCheckout];
    }
}

#pragma mark Tap

-(void)tagViewGesture:(UIGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateRecognized && (self.mode == ModeEdit || self.mode == ModeTagEdit))
    {
        CGPoint point = [recognizer locationInView:recognizer.view];
        UIView *view = recognizer.view;
        float zoom = [self.mapInterfaceView getZoom];
        if(point.x > MapBuffer && point.x < view.frame.size.width/zoom-MapBuffer && point.y > MapBuffer && point.y < view.frame.size.height/zoom-MapBuffer) //keep taps away from edges
        {
            NSLog(@"Tap Cords : (%f,%f)", point.x, point.y);
            self.tapXCordPercentage = point.x/(view.frame.size.width / zoom);
            self.tapYCordPercentage = point.y/(view.frame.size.height / zoom);
            BOOL valid = YES;
            for(UIView *compView in [view subviews])//Check for frame collisions
            {
                if(compView.tag >= 0)
                {
                    CGRect holder = CGRectMake(point.x-6.4, point.y-12.8, 12.8, 12.8); //Since tap is bottom middle of frame we draw, we have to offset origin by its size
                    bool intersects = CGRectIntersectsRect(holder, compView.frame);
                    if(intersects) valid = NO;
                }
            }
            if(valid)
            {
                [self.mapModel iconsForMap];
                [self.mapInterfaceView inTagEditMode:YES];
                self.editTimer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(tagViewCancel) userInfo:nil repeats:NO]; //Keep user from hanging out in edit mode and missing updates
            }
        }
    }
}

-(void)tapHolderGesture:(UIGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateRecognized && self.mode == ModeView)
    {
        [self.mapModel commentAtIndex:gesture.view.tag];
        self.stagingView = gesture.view;
    }
}

#pragma mark Helpers

-(void)forceTagCheck
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[dBref child:self.mapPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSArray *tagLocations = (NSArray *) snapshot.value[@"tagLocations"];
        if(![self collisionAtIndex:tagLocations])
        {
            [self.mapInterfaceView setTagViewWith:tagLocations];
            [self.view setNeedsDisplay];
            [self.view setNeedsLayout];
            self.currentIndex = -1;
        }else
        {
            [self.mapModel removeNodeAtIndex:self.currentIndex];
            self.currentIndex = -1;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGInfo" object:@"While you were making your edit, someone placed one right in the same spot!\nUnfortunately, we can't stack edits so we had to remove yours. "];
        }
    }];
}

-(bool)collisionAtIndex:(NSArray *)tagLocations //Used for checking if background updates conflict with current edit
{
    //If two collision removals happen at the same time and the topmost isnt removed first it will offset index
    if(self.currentIndex >= 0) //NEG MEANS NOTHING TO CHECK
    {
        NSDictionary *currentTag = (NSDictionary *)tagLocations[self.currentIndex];
        NSNumber *xPerc = (NSNumber *) currentTag[@"x"];
        NSNumber *yPerc = (NSNumber *) currentTag[@"y"];
        float xOrig = [xPerc floatValue] * self.view.frame.size.width;
        float yOrig = [yPerc floatValue] * self.view.frame.size.height;
        CGRect currentTagFrame = CGRectMake(xOrig - 6.4, yOrig - 12.8, 12.8, 12.8);
        bool intersects = NO;
        for(NSDictionary *compTag in tagLocations)
        {
            NSLog(@"Location Index : %d", [tagLocations indexOfObject:compTag]);
            if([tagLocations indexOfObject:compTag] != self.currentIndex)
            {
                NSNumber *xCompPerc = (NSNumber *) compTag[@"x"];
                NSNumber *yCompPerc = (NSNumber *) compTag[@"y"];
                float xCompOrig = [xCompPerc floatValue] * self.view.frame.size.width;
                float yCompOrig = [yCompPerc floatValue] * self.view.frame.size.height;
                CGRect compTagFrame = CGRectMake(xCompOrig - 6.4, yCompOrig - 12.8, 12.8, 12.8);
                if(CGRectIntersectsRect(currentTagFrame, compTagFrame)) intersects = YES;
            }
        }
        return intersects;
    }else
    {
        return NO;
    }
}
#pragma mark Global

+(int)userRankToVotes
{
    NSNumber *rank = [[NSUserDefaults standardUserDefaults] objectForKey:@"Rank"];
    switch([rank intValue])
    {
        case 0:
        case 1:
        case 2:
        case 3:
            return 1;
        case 4:
            return 5;
        case 5:
            return 23;
        case 6:
            return 50;
        default:
            return 1;
    }
}

@end
