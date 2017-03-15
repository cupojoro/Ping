//
//  PGGamePageVC.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-08.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//
#import "PGGamePageVC.h"
#import "PGMapInterfaceVC.h"

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
        NSString *path = [NSString stringWithFormat:@"activeGames/%@/info/mapNames", gameDestination];
        [[self.dataRef child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            for(FIRDataSnapshot *child in snapshot.children){
                NSLog(@"MAP NAMES : %@", child.value);
                [mapNames addObject:child.value];
            }
        }];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO];
    
    // Do any additional setup after loading the view.
    NSString *path = [NSString stringWithFormat:@"activeGames/%@/images/titleCard", gameDestination];
    [[self.dataRef child:path]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSURL *url = [NSURL URLWithString:snapshot.value];
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
    
    
    NSString *path2 = [NSString stringWithFormat:@"activeGames/%@/info/totalMaps", gameDestination];
    [[self.dataRef child:path2] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSNumber *mapCount = snapshot.value;
        totalMaps = [mapCount intValue];
        NSLog(@"Total Maps = %ld", (long)totalMaps);
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
    return totalMaps;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    NSString *mapContributors = [NSString stringWithFormat:@"activeGames/%@/mapContributors/%@", gameTitle, [mapNames objectAtIndex:indexPath.row]];
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[dBref child:mapContributors] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSArray *contributors = (NSArray *) snapshot.value;
        NSUInteger total = 0;
        NSMutableString *firstUser = [[NSMutableString alloc] initWithString:@""];
        if(![contributors isEqual:[NSNull null]])
        {
            total = [contributors count];
            firstUser = (NSMutableString *) contributors[0];
        }
        if([firstUser isEqualToString:@"admin"]) total = 0;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Population: %lu", (unsigned long) total];
        
    }];
    cell.textLabel.text = [mapNames objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"ButtonFrame"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *path = [NSString stringWithFormat:@"activeGames/%@/gridValues/%@", gameTitle, [mapNames objectAtIndex:indexPath.row]];
    [[dBref child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableArray *grid = (NSMutableArray *) snapshot.value;
        NSString *mapContributors = [NSString stringWithFormat:@"activeGames/%@/mapContributors/%@", gameTitle, [mapNames objectAtIndex:indexPath.row]];
        [[dBref child:mapContributors] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
            NSMutableArray *contributors = (NSMutableArray *) currentData.value;
            if(contributors == nil || [contributors isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
            for(NSString *user in contributors)
            {
                if([user isEqualToString:@"admin"] && [contributors indexOfObject:user] == 0)
                {
                    [contributors removeAllObjects];
                    break;
                }
                if([user isEqualToString:username]) return [FIRTransactionResult successWithValue:currentData];
            }
            [contributors addObject:username];
            currentData.value = contributors;
            return [FIRTransactionResult successWithValue:currentData];
        }andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
            if(committed){
            PGMapInterfaceVC *mapInterface = [[PGMapInterfaceVC alloc] initWithURL:[NSURL URLWithString:@"http"] andGrid:grid andTitle:gameTitle andMap:[mapNames objectAtIndex:indexPath.row]];
            [[self navigationController] pushViewController:mapInterface animated:NO];
            }
        }];
    }];
}


@end
