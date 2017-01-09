//
//  PGGamePageVC.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-08.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGGamePageVC.h"

#import "Masonry.h"
#import "Firebase.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PGGamePageVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *coverImage;
@property (nonatomic, strong) UITableView *mapList;

@property (nonatomic, strong) FIRDatabaseReference *dataRef;

@end

@implementation PGGamePageVC

NSString *gameTitle;
NSString *gameDestination;
NSInteger totalShownRows;
NSInteger totalMaps;
NSMutableArray *mapNames;

-(id)initWithGameTitle: (NSString *) title andDestination: (NSString *) destination{
    self = [super init];
    if(self){
        self.dataRef = [[FIRDatabase database] reference];
        gameTitle = title;
        gameDestination = destination;
        totalShownRows = 4;
        totalMaps = 0;
        mapNames = [[NSMutableArray alloc] init];
        
        [[[[self.dataRef child:@"activeGames"] child:gameDestination] child:@"gridValues"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            for(FIRDataSnapshot *child in snapshot.children){
                NSLog(@"MAP NAMES : %@", child.key);
                [mapNames addObject:child.key];
            }
        }];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO];
    
    // Do any additional setup after loading the view.
    [[[[self.dataRef child:@"activeGames"] child:gameDestination] child:@"images"]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSURL *url = [NSURL URLWithString:snapshot.value[@"titleCard"]];
        self.coverImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
        self.coverImage.contentMode = UIViewContentModeScaleToFill;
        self.coverImage.clipsToBounds = YES;
        self.coverImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2);
        [self.view addSubview:self.coverImage];
    }];
    
    self.mapList = [[UITableView alloc] init];
    [self.mapList setDataSource:self];
    [self.mapList setDelegate:self];
    self.mapList.bounces = NO;
    self.mapList.rowHeight = self.view.frame.size.height / ( 2 * totalShownRows);
    [self.view addSubview:self.mapList];
    
    
    [[[[self.dataRef child:@"activeGames"] child:gameDestination] child:@"info"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSNumber *mapCount = snapshot.value[@"totalMaps"];
        totalMaps = [mapCount intValue];
        NSLog(@"Total Maps = %ld", totalMaps);
        [self.mapList reloadData];
    }];
    
    [self applyMASConstraints];
}

#pragma mark Layout

-(void) applyMASConstraints
{
    [self.coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
    }];
    
    [self.mapList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.view.mas_centerY);
        make.width.equalTo(self.view);
    }];
}

#pragma mark Table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"NUMBER OF ROWS = %ld", (long)totalMaps);
    return totalMaps;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"BUILDING CELL #%ld with mapName: %@", indexPath.row, [mapNames objectAtIndex:indexPath.row]);
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [mapNames objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
