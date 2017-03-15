//
//  PGGamePageViewController.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGGamePageViewController.h"

#import "PGGameView.h"
#import "PGMapViewController.h"

#import "Masonry.h"
#import "Firebase.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PGGamePageViewController () 

@property (nonatomic, strong) PGGameView *gameView;

@property (nonatomic, strong) NSNumber *totalMaps;
@property (nonatomic, strong) NSArray *mapNames;
@property (nonatomic, strong) NSString *gameName;

@end

@implementation PGGamePageViewController

-(id)initWith:(NSString *)gameName At:(NSString *)gamePath
{
    self = [super init];
    
    self.totalMaps = @0;
    self.gameName = gameName;
    
    self.gameView = [[PGGameView alloc] initWithController:self];
    [self.view addSubview:self.gameView];
    
    NSString *mapNamesPath = [NSString stringWithFormat:@"%@/info", gamePath];
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    
    [[dBref child:mapNamesPath] observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSURL *url = [NSURL URLWithString:snapshot.value[@"coverImageURL"]];
        self.mapNames = (NSArray *) snapshot.value[@"mapNames"];
        self.totalMaps =  @([self.mapNames count]);
        [self.gameView setCoverImage:url];
        [self.gameView reloadTable];
    }];
    
    [self.gameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
    }];
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.totalMaps integerValue];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = [self.mapNames objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"ButtonFrame"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SELECTED CELL : %@", [self.mapNames objectAtIndex:indexPath.row]);
    NSString *mapName = [self.mapNames objectAtIndex:indexPath.row];
    NSString *path = [NSString stringWithFormat:@"gameMap:%@:%@",self.gameName, mapName];
    PGMapViewController *mVC = [[PGMapViewController alloc] initWithMapPath:path];
    [self.navigationController pushViewController:mVC animated:NO];
}
@end
