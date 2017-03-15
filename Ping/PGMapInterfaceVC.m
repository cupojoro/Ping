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
#import "PGAdminControlView.h"

#import "Masonry.h"
#import "Firebase.h"

@interface PGMapInterfaceVC ()


@property (nonatomic, strong) UILabel *contributorLabel;
@property (nonatomic, strong) UIView *greyoutView;
@property (nonatomic, strong) UIButton *maxToolbar;

@property (nonatomic, strong) PGFilterView *filterView;
@property (nonatomic, strong) PGMapView *mapView;
@property (nonatomic, strong) PGToolbarView *toolbarView;
@property (nonatomic, strong) PGAdminControlView *adminView;

@property (nonatomic, strong) NSMutableArray *gridData;
@property (nonatomic, strong) NSURL *mapImageURL;
@property (nonatomic, strong) UIColor *iconColor;
@property (nonatomic) NSInteger geoID;
@property (nonatomic, strong) NSNumber *currentCell;
@property (nonatomic, strong) NSString *gameTitle;
@property (nonatomic, strong) NSString *gameMap;
@property (nonatomic) int starPeak;
@property (nonatomic) int toolbarHeight;
@property (nonatomic) int toolbarSectionHeight;
@property (nonatomic) unsigned int viewFlag;


@end

@implementation PGMapInterfaceVC


unsigned int flagsOn = 7;
StatusModes status;


-(id)initWithURL: (NSURL *)url andGrid: (NSMutableArray *)gData andTitle: (NSString*) title andMap: (NSString *) name;
{
    self = [super init];
    if(self){
        self.mapImageURL = url;
        self.iconColor = [UIColor blackColor];
        self.toolbarHeight = 80;
        self.toolbarSectionHeight = 35;
        self.viewFlag= flagsOn;
        status = EditMode;
        self.currentCell = @(-1);
        self.gameTitle = title;
        self.gameMap = name;
        self.starPeak = 25;
        self.gridData = gData;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //SETUP NAVIGATION BAR
    
    [self updateStatusBarForEdit];
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
    
    self.toolbarView = [[PGToolbarView alloc] initWithToolbarHeight:self.toolbarHeight toolBarSectionHeight:self.toolbarSectionHeight mapInterface:self];
    [self.view addSubview:self.toolbarView];
    
    self.maxToolbar = [[UIButton alloc] init];
    [self.maxToolbar setBackgroundImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
    [self.maxToolbar addTarget:self action:@selector(toggleToolbar) forControlEvents:UIControlEventTouchUpInside];
    self.maxToolbar.hidden = YES;
    [self.view addSubview:self.maxToolbar];
    
    //MAP VIEW
    
    //CGRect frame = self.view.frame;
    //frame.size.height -= (self.toolbarHeight + self.topLayoutGuide.length);
    //NSLog(@"\nView Height %f \nTop Layout %f\n ToolbarHeight %d", self.view.frame.size.height, self.topLayoutGuide.length, self.toolbarHeight);
    /*
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *path = [NSString stringWithFormat:@"activeGames/%@/info/mapGridSizes/%@",self.gameTitle, self.gameMap];
    [[dBref child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        int gridSize = [(NSNumber *) snapshot.value intValue];
        self.mapView = [[PGMapView alloc] initWithMapInterface:self andGridSize:gridSize];
        [self.view addSubview:self.mapView];
        [self updateViewConstraints];
    }];
    */
    //NEED TO DEAL WITH GRID DATA == NIL
    self.mapView = [[PGMapView alloc] initWithMapInterface:self andGridSize:20 andGridData:self.gridData];
    [self.view addSubview:self.mapView];
    
    [self.view addSubview:self.toolbarView];
    [self.view bringSubviewToFront:self.toolbarView];
    [self.view bringSubviewToFront:self.maxToolbar];
    [self.view bringSubviewToFront:self.filterView];
    [self.view bringSubviewToFront:self.greyoutView];
    
    //ADMING VIEW
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"Rank"]  isEqual: @6])
    {
        NSLog(@"ADMIN LOGGED");
        self.adminView = [[PGAdminControlView alloc] initWithGameName:self.gameTitle andMapName:self.gameMap];
        self.adminView.userInteractionEnabled = YES;
        [self.view addSubview:self.adminView];
        [self.view bringSubviewToFront:self.adminView];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateViewConstraints];
}

-(void) updateViewConstraints
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
    
    //if(![self.mapView isEqual:[NSNull null]])
    //{
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.mas_width);
            make.bottom.equalTo(self.toolbarView.mas_top);
            make.top.equalTo(self.mas_topLayoutGuide);
            make.left.equalTo(self.view.mas_left);
        }];
    //}
    [self.toolbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo([NSNumber numberWithInteger:self.toolbarHeight]);
        make.width.equalTo(self.view.mas_width);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self.maxToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@34);
        make.width.equalTo(@44);
        make.centerX.equalTo(self.toolbarView.mas_centerX);
        make.bottom.equalTo(self.toolbarView.mas_top);
    }];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"Rank"]  isEqual: @6])
    {
        [self.adminView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.view.mas_height).dividedBy(2);
            make.width.equalTo(self.view.mas_width).dividedBy(3);
            make.centerY.equalTo(self.view.mas_centerY);
            make.right.equalTo(self.view.mas_right);
        }];
    }
    [super updateViewConstraints];
}

-(void)gridButtonSwitch
{
    [self.mapView gridSwitch];
}

-(StatusModes)getStatusMode
{
    return status;
}

-(NSInteger)getGeoID
{
    return self.geoID;
}

-(UIColor *)getTintColor
{
    return self.iconColor;
}

-(void)toggleToolbar
{
    [self.toolbarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo([NSNumber numberWithInteger:self.toolbarHeight]);
        make.width.equalTo(self.view.mas_width);
        make.left.equalTo(self.view.mas_left);
        if(self.view.frame.size.height == self.toolbarView.frame.origin.y)
            make.bottom.equalTo(self.view.mas_bottom);
        else
            make.top.equalTo(self.view.mas_bottom);
    }];
    
    self.maxToolbar.hidden = !self.maxToolbar.hidden;
    
    //[UIView animateWithDuration:2 animations:^{
    //    [self.view layoutIfNeeded];
    //}];
    [self.view layoutIfNeeded];
    [self.mapView reloadGridWithVoters:NO];
    
}

-(unsigned int)getViewFlag
{
    return self.viewFlag;
}
-(void)updateViewFlag:(id)sender
{
    //KEY CROWN MONEY
    UIButton *button = (UIButton *) sender;
    if(button.tag == 1){
        if( self.viewFlag & KeyView )
        {
            self.viewFlag = self.viewFlag^KeyView;
            button.backgroundColor = [UIColor clearColor];
        }
        else{
            self.viewFlag = self.viewFlag | KeyView;
            button.backgroundColor = [UIColor yellowColor];
        }
    }
    else if(button.tag == 2){
        if( self.viewFlag & CrownView )
        {
            self.viewFlag = self.viewFlag^CrownView;
            button.backgroundColor = [UIColor clearColor];
        }
        else
        {
            self.viewFlag = self.viewFlag | CrownView;
            button.backgroundColor = [UIColor yellowColor];
        }
    }
    else if(button.tag == 3){
        if( self.viewFlag & MoneyView )
        {
            self.viewFlag = self.viewFlag^MoneyView;
            button.backgroundColor = [UIColor clearColor];
        }
        else
        {
            self.viewFlag = self.viewFlag | MoneyView;
            button.backgroundColor = [UIColor yellowColor];
        }
    }
    [self.mapView reloadGridWithVoters:NO];
}

-(NSInteger) getStarFilterValue
{
    return [self.filterView getStarFilterValue];
}

-(NSString *)getGameName
{
    return self.gameTitle;
}

-(NSString *)getMapName
{
    return self.gameMap;
}

-(BOOL)getCellEditMode
{
    return [self.adminView getCellEditMode];
}

-(void)updateFilter
{
    [self.mapView setUserInteractionEnabled: YES];
    [self.toolbarView setUserInteractionEnabled:YES];
    self.filterView.hidden = YES;
    self.greyoutView.hidden = YES;
    [self.mapView reloadGridWithVoters:NO];
}

-(void)updateIconColor: (id) sender
{
    UIButton *button  = (UIButton *) sender;
    if(button.tag == 1) self.iconColor = [UIColor blackColor];
    else if(button.tag == 2) self.iconColor = [UIColor redColor];
    else if(button.tag == 3) self.iconColor = [UIColor whiteColor];
}

-(void)openFilterMenu
{
    [self.mapView setUserInteractionEnabled:NO];
    [self.toolbarView setUserInteractionEnabled:NO];
    self.filterView.hidden = NO;
    self.greyoutView.hidden = NO;
}

-(void)updateStatusMode: (id) sender
{
    UIButton *button = (UIButton *)sender;
    status = (StatusModes) button.tag;
    if(status != EditMode ) [self.mapView forceGrid:NO];
    if(status == VoteMode || status == EditMode) self.viewFlag = flagsOn;
    self.geoID = 0;
    [self.toolbarView resetButtons];
    [self.toolbarView updateToolbar];
    [self.mapView reloadGridWithVoters:NO];
}

-(void)reloadMapDataWithVoter:(BOOL)update
{
    update = NO;
    [self.mapView reloadGridWithVoters:update];
}
-(void)updateGeoID : (id) sender
{
    UIButton *button = (UIButton *) sender;
    if(self.geoID == button.tag){
        self.geoID = 0;
        button.backgroundColor = [UIColor clearColor];
    }
    else{
        self.geoID = button.tag;
        button.backgroundColor = [UIColor yellowColor];
    }
    
    [self.toolbarView updateToolbar];
    
}
-(int)getCurrentCell
{
    return self.currentCell.intValue;
}
-(void)updateCurrentCell:(NSNumber *) cell
{
    self.currentCell = cell;
    if(status == VoteMode && [self.mapView hasItemAtIndex:cell.intValue])
    {
        NSLog(@"Item at location");
        FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
        NSString *cell = [@"cell" stringByAppendingString:[self.currentCell stringValue]];
        NSString *path = [NSString stringWithFormat:@"activeGames/%@/gridVotes/%@/%@", self.gameTitle, self.gameMap, cell];
        NSLog(@"VOTE PATH : %@", path);
        [[dBref child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if([snapshot.value isEqual:[NSNull null]]) { [self.toolbarView toggleVote:@0]; return;}
            
            NSMutableArray *upvotes = snapshot.value[@"upvote"];
            NSMutableArray *downvotes = snapshot.value[@"downvote"];
            NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
            BOOL voted = NO;
            
            //IF DATA DOESNT EXIST
            if([upvotes isEqual:[NSNull null]]){ [self.toolbarView toggleVote:@0]; return;}
            if([downvotes isEqual:[NSNull null]]){ [self.toolbarView toggleVote:@0]; return;}
            
            for(NSString *user in upvotes)
            {
                if([userName isEqualToString:user]){
                    [self.toolbarView toggleVote:@(1)];
                    voted = YES;
                    break;
                }
            }
            for(NSString *user in downvotes)
            {
                if([userName isEqualToString:user]){
                    [self.toolbarView toggleVote:@(-1)];
                    voted = YES;
                    break;
                }
            }
            if(!voted)[self.toolbarView toggleVote:@0];
        }];
    }else if(status == VoteMode){
        [self.toolbarView toggleVote:@(3)];
    }else if(status == ViewMode)
    {
        FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
        NSString * cell = [@"cell" stringByAppendingString:[self.currentCell stringValue]];
        NSString *path = [NSString stringWithFormat:@"activeGames/%@/gridDetails/%@/%@", self.gameTitle, self.gameMap, cell];
        [[dBref child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSString *details = (NSString *) snapshot.value;
            if(![details isEqual:[NSNull null]] && ![details isEqualToString:@"0"] && details.length!=0)
            {
                [self.navigationItem setTitle:details];
            }else{
                [self.navigationItem setTitle:@"Details about an icon will appear here"];
            }
        }];
    }
}
-(void)updateStatusBarForEdit
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *path = [NSString stringWithFormat:@"userList/%@/edits",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]];
    [[dBref child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.navigationItem setTitle:[@"Total edits left : " stringByAppendingString:[(NSNumber *) snapshot.value stringValue]]];
    }];
}
-(void)updateStatusBarForVote
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *path = [NSString stringWithFormat:@"userList/%@/soft",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]];
    NSLog(@"STATUS BAR VOTE PATH: %@", path);
    [[dBref child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.navigationItem setTitle:[@"Total votes left : " stringByAppendingString:[(NSNumber *) snapshot.value stringValue]]];
    }];
}
-(void)castVote:(id)sender
{
    if(self.currentCell.integerValue < 0){ NSLog(@"BAD CELL VOTE"); return; }
    
    UIButton *sent = (UIButton *) sender;
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    
    __block NSString *userSoftPath = [NSString stringWithFormat:@"userList/%@/soft", [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]];
    [[dBref child:userSoftPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        __block NSNumber *votes = (NSNumber *) snapshot.value;
        if(votes.integerValue == 0) return;
        
        
        __block NSMutableArray *updated;
        __block NSMutableArray *counter;
        __block long prevNet;
        __block BOOL force;
        NSString *cell = [@"cell" stringByAppendingString:self.currentCell.stringValue];
        __block NSString *path = [NSString stringWithFormat:@"activeGames/%@/gridVotes/%@/%@", self.gameTitle, self.gameMap, cell];
        [[dBref child:path] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
            NSDictionary *votes = (NSDictionary *)currentData.value;
            
            //CHECK FOR NIL DATA
            if(!votes || [votes isEqual:[NSNull null]] ) return [FIRTransactionResult successWithValue:currentData];
            
            NSMutableArray *upvoters = (NSMutableArray *) votes[@"upvote"];
            NSMutableArray *downvoters = (NSMutableArray *) votes[@"downvote"];
            
            //SELECT VOTER DATA
            NSNumber *votePower = [[NSUserDefaults standardUserDefaults] objectForKey:@"Rank"];
            NSMutableArray *voters;
            NSString *key;
            
            if(sent.tag == 1){
                key = @"upvote";
                voters = upvoters;
                counter = downvoters;
            }else{
                key = @"downvote";
                voters = downvoters;
                counter = upvoters;
            }
            prevNet = voters.count - counter.count;
            if([[voters objectAtIndex:0] isKindOfClass:[NSNumber class]]) voters = [[NSMutableArray alloc] init];
            if([[counter objectAtIndex:0] isKindOfClass:[NSNumber class]]) counter = [[NSMutableArray alloc] init];
            [voters addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]];
            
            force = NO;
            
            //ADD CORRESPONDING RANK WEIGHT
            if([votePower  isEqualToNumber: @4] || [votePower isEqualToNumber:@5]){
                if([votePower isEqualToNumber:@5]) votePower = @22;
                while(![votePower  isEqualToNumber: @0]){
                    [voters addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]];
                    votePower = @(votePower.intValue - 1);
                }
                force = YES;
            }
            [votes setValue:voters forKey:key];
            currentData.value = votes;
            
            updated = voters;
            
            return [FIRTransactionResult successWithValue:currentData];
        } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
            if(error){
                NSLog(@"%@", error.localizedDescription);
            }
            if(committed){
                NSLog(@"COMMITTED");
                votes = @(votes.integerValue - 1 );
                
                [[dBref child:userSoftPath] setValue:votes withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    
                    
                    [self.toolbarView toggleVote:@(sent.tag)];
                    //HANDLE STAR PEAK
                    long netvotes = updated.count - counter.count;
                    //if(netvotes == self.starPeak || (netvotes >= self.starPeak && force && netvotes < (self.starPeak + 23 + 1))){
                    if( netvotes >= self.starPeak && prevNet < self.starPeak){
                        FIRDatabaseReference *dBref2 = [[FIRDatabase database] reference];
                        
                        [[dBref2 child:@"userList"] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
                            
                            NSDictionary *users = (NSDictionary *) currentData.value;
                            
                            if(!currentData.value || [currentData.value isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
                            for(NSString *user in updated){
                                
                                NSDictionary *userData = (NSDictionary *) users[user];
                                NSNumber *hardCount = [userData objectForKey:@"hard"];
                                hardCount = @(hardCount.intValue + 1);
                                [userData setValue:hardCount forKey:@"hard"];
                                if([hardCount  isEqual: @10]) [userData setValue:@1 forKey:@"rank"];
                                else if([hardCount isEqual:@25]) [userData setValue:@2 forKey:@"rank"];
                                else if([hardCount isEqual:@60]) [userData setValue:@3 forKey:@"rank"];
                                else if([hardCount isEqual:@150]) [userData setValue:@4 forKey:@"rank"];
                                [users setValue:userData forKey:user];
                            }
                            for(NSString *user in counter){
                                NSDictionary *userData = users[user];
                                NSNumber *hardCount = [userData objectForKey:@"hard"];
                                hardCount = @(hardCount.intValue - 1);
                                [userData setValue:hardCount forKey:@"hard"];
                                if([hardCount  isEqual: @9]) [userData setValue:@0 forKey:@"rank"];
                                else if([hardCount isEqual:@24]) [userData setValue:@1 forKey:@"rank"];
                                else if([hardCount isEqual:@59]) [userData setValue:@2 forKey:@"rank"];
                                else if([hardCount isEqual:@149]) [userData setValue:@3 forKey:@"rank"];
                                [users setValue:userData forKey:user];
                            }
                            currentData.value = users;
                            return [FIRTransactionResult successWithValue:currentData];
                        }andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
                            if(error) NSLog(@"%@",error.localizedDescription);
                            if(committed){
                                if(sent.tag == -1){
                                    //need to delete cell
                                    NSString *cellDataPath = [NSString stringWithFormat:@"activeGames/%@/gridValues/%@/%@", self.gameTitle, self.gameMap, self.currentCell.stringValue];
                                    [[dBref child:cellDataPath] setValue:@0 withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                                        [[dBref child:path] removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                                            NSString *cellDetailPath = [NSString stringWithFormat:@"activeGames/%@/gridDetails/%@/cell%@", self.gameTitle, self.gameMap, self.currentCell.stringValue];
                                            [[dBref child:cellDetailPath] removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                                                [self updateStatusBarForVote];
                                            }];
                                        }];
                                    }];
                                }else [self updateStatusBarForVote];
                            }
                        }];
                    }
                }];
            }
        }];
    }];
    
}





@end
