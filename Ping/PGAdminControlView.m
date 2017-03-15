//
//  PGAdminControlView.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-29.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//
#import "PGAdminControlView.h"


#import "Masonry.h"
#import "Firebase.h"

@interface PGAdminControlView ()


@property (nonatomic, strong) UIButton *valueButton;

@property (nonatomic, strong) UIButton *voteButton;

@property (nonatomic, strong) UIButton *detailButton;

@property (nonatomic, strong) UIButton *removeCellButton;

@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *mapName;

@property (nonatomic) BOOL removeMode;
@end

@implementation PGAdminControlView

-(id)initWithGameName: (NSString *) game andMapName: (NSString *) name
{
    self = [super init];
    if(self)
    {
        self.gameName = game;
        self.mapName = name;
        self.removeMode = NO;
        
        self.userInteractionEnabled = YES;
        [self setBackgroundColor:[UIColor blackColor] ];
        
        self.valueButton = [[UIButton alloc] init];
        [self.valueButton setTitle:@"CLEAR AND CREATE FRESH VALUE DATA" forState:UIControlStateNormal];
        [self.valueButton addTarget:self action:@selector(createValueData) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.valueButton];
        
        self.voteButton = [[UIButton alloc] init];
        [self.voteButton setTitle:@"CLEAR AND CREATE FRESH VOTER DATA" forState:UIControlStateNormal];
        [self.voteButton addTarget:self action:@selector(createVoterData) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.voteButton];
        
        self.detailButton = [[UIButton alloc] init];
        [self.detailButton setTitle:@"CLEAR AND CREATE FRESH DETAIL DATA" forState:UIControlStateNormal];
        [self.detailButton addTarget:self action:@selector(createDetailData) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.detailButton];
        
        self.removeCellButton = [[UIButton alloc] init];
        [self.removeCellButton setTitle:@"TOGGLE REMOVE CELL MODE" forState:UIControlStateNormal];
        [self.removeCellButton addTarget:self action:@selector(toggleRemoveCellMode) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.removeCellButton];
    }
    return self;
}

-(void)updateConstraints
{
    [self.valueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@84);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.top.equalTo(self);
    }];
    
    [self.voteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@84);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.top.equalTo(self.valueButton.mas_bottom);
    }];
    
    [self.detailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@84);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.top.equalTo(self.voteButton.mas_bottom);
    }];
    
    [self.removeCellButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@84);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.top.equalTo(self.detailButton.mas_bottom);
    }];
    
    [super updateConstraints];
}

-(void)toggleRemoveCellMode
{
    self.removeMode = !self.removeMode;
    if(self.removeMode) [self.removeCellButton setBackgroundColor:[UIColor redColor]];
    else [self.removeCellButton setBackgroundColor:[UIColor clearColor]];
}

-(BOOL)getCellEditMode
{
    return self.removeMode;
}

-(void)createValueData
{
    //HAVE TO SET IT THIS WAY SINCE CHECKS USE LOCATIONS IN ARRAY AND CAN'T UPSET ORDER OR CHECKING
    NSLog(@"CLEARING VALUE DATA");
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    __block int totalCells = 0;
    NSString *pathGridSize = [NSString stringWithFormat:@"activeGames/%@/info/mapGridSizes/%@",self.gameName, self.mapName];
    [[dBref child:pathGridSize] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        totalCells = [(NSNumber *) snapshot.value intValue];
        totalCells = totalCells * totalCells;
        NSMutableString *path = [[NSMutableString alloc] initWithFormat:@"activeGames/%@/gridValues/%@", self.gameName, self.mapName];
        NSMutableArray *val = [[NSMutableArray alloc] initWithCapacity:totalCells];
        for(int i = 0; i < totalCells; i++)
        {
            val[i] = @0;
        }
        [[dBref child:path] setValue:val];
        NSString *mapContributors = [NSString stringWithFormat:@"activeGames/%@/mapContributors/%@", self.gameName, self.mapName];
        [[dBref child:mapContributors] setValue:@[@"admin"]];
    }];
}

-(void)createVoterData
{
    NSLog(@"CLEARING VOTER DATA");
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    //int totalCells = 30*30;
    NSMutableString *path = [[NSMutableString alloc] initWithFormat:@"activeGames/%@/gridVotes/%@", self.gameName, self.mapName];
    //for(int i = 0; i < totalCells; i++)
    //{
    //    NSString *cell = [@"cell" stringByAppendingString:[NSString stringWithFormat:@"%d", i]];
    //    [[[[dBref child:path] child:cell] child:@"upvote"] setValue:@[@0]];
    //    [[[[dBref child:path] child:cell] child:@"downvote"] setValue:@[@0]];
    //}
    [[dBref child:path] setValue:@0];
}

-(void)createDetailData
{
    NSLog(@"CLEARING DETAIL DATA");
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    //int totalCells = 30*30;
    NSMutableString *path = [[NSMutableString alloc] initWithFormat:@"activeGames/%@/gridDetails/%@", self.gameName, self.mapName];
    //for(int i = 0; i < totalCells; i++)
    //{
    //    NSString *cell = [@"cell" stringByAppendingString:[NSString stringWithFormat:@"%d", i]];
    //    [[[dBref child:path] child:cell] setValue:@"0"];
    //}
    [[dBref child:path] setValue:@0];
}

@end
