//
//  PGMapInterfaceVC.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-08.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGMapInterfaceVC.h"
#import "PGGridCell.h"
#import "PGFilterView.h"
#import "PGMapView.h"
#import "PGToolbarView.h"

#import "Masonry.h"
#import "Firebase.h"

@interface PGMapInterfaceVC () 


@property (nonatomic, strong) UILabel *contributorLabel;
@property (nonatomic, strong) UIView *greyoutView;

@property (nonatomic, strong) PGFilterView *filterView;
@property (nonatomic, strong) PGMapView *mapView;
@property (nonatomic, strong) PGToolbarView *toolbarView;

@end

@implementation PGMapInterfaceVC

typedef enum
{
    ViewMode = 1,
    VoteMode = 2,
    EditMode = 3
} StatusModes;

NSURL *mapImageURL;
NSMutableArray *gridData;
BOOL gridNotHidden = NO;
NSInteger geoID = 0;
int toolbarHeight = 85;
int toolbarSectionHeight = 15;
UIColor *iconColor;
StatusModes status;
int viewFlag;


-(id)initWithURL: (NSURL *)url andGrid: (NSMutableArray *)gData
{
    self = [super init];
    if(self){
        mapImageURL = url;
        iconColor = [UIColor blackColor];
        status = EditMode;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //SETUP NAVIGATION BAR
    
    [self.navigationItem setTitle:@"Contributors: 25"];
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(openFilterMenu)];
    self.navigationItem.rightBarButtonItem = filterButton;
    
    //FILTER MENU
    
    self.filterView = [[PGFilterView alloc] initWithMapInterface:self];
    self.filterView.hidden = YES;
    [self.filterView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:self.filterView];
    
    self.greyoutView = [[UIView alloc] init];
    self.greyoutView.hidden = YES;
    [self.greyoutView setBackgroundColor:[UIColor colorWithRed:0.169 green:0.169 blue:0.169 alpha:0.65]];
    [self.view addSubview:self.greyoutView];
    
    //TOOLBAR
    
    self.toolbarView = [[PGToolbarView alloc] initWithToolbarHeight:toolbarHeight toolBarSectionHeight:toolbarSectionHeight mapInterface:self];
    [self.view addSubview:self.toolbarView];
    
    //MAP VIEW
    
    CGRect frame = self.view.frame;
    frame.size.height -= toolbarHeight;
    self.mapView = [[PGMapView alloc] initWithFrame:frame mapInterface:self];
    [self.view addSubview:self.mapView];
    
    [self.view addSubview:self.toolbarView];
    [self.view bringSubviewToFront:self.toolbarView];
    [self.view bringSubviewToFront:self.filterView];
    [self.view bringSubviewToFront:self.greyoutView];
    
    [self applyMASConstraints];
}

-(void) applyMASConstraints
{
    [self.greyoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view.mas_height).dividedBy(2);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
    }];
    
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height).dividedBy(2);
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
    }];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.bottom.equalTo(self.toolbarView.mas_top);
        make.height.equalTo(self.view.mas_height).with.offset(toolbarHeight);
        make.left.equalTo(self.view.mas_left);
    }];
    
    [self.toolbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo([NSNumber numberWithInteger:toolbarHeight]);
        make.width.equalTo(self.view.mas_width);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
}

-(void)gridButtonSwitch
{
    [self.mapView gridSwitch];
}

-(NSInteger)getGeoID
{
    return geoID;
}

-(UIColor *)getTintColor
{
    return iconColor;
}

-(void)updateFilter
{
    [self.mapView setUserInteractionEnabled: YES];
    [self.toolbarView setUserInteractionEnabled:YES];
    self.filterView.hidden = YES;
    self.greyoutView.hidden = YES;
    [self.mapView reloadGrid];
}

-(void)updateIconColor: (id) sender
{
    UIButton *button  = (UIButton *) sender;
    if(button.tag == 1) iconColor = [UIColor blackColor];
    else if(button.tag == 2) iconColor = [UIColor redColor];
    else if(button.tag == 3) iconColor = [UIColor whiteColor];
}

-(void)openFilterMenu
{
    NSLog(@"OPENING FILTER MENU");
    [self.mapView setUserInteractionEnabled:NO];
    [self.toolbarView setUserInteractionEnabled:NO];
    self.filterView.hidden = NO;
    self.greyoutView.hidden = NO;
}

-(void)updateStatusMode: (id) sender
{
    UIButton *button = (UIButton *)sender;
    status = (StatusModes) button.tag;
}

-(void)updateGeoID : (id) sender
{
    [self.toolbarView clearButtonHighlights];
    UIButton *button = (UIButton *) sender;
    if(geoID == button.tag){
        geoID = 0;
        button.backgroundColor = [UIColor clearColor];
    }
    else{
        geoID = button.tag;
        button.backgroundColor = [UIColor yellowColor];
    }
    
    
}





@end
