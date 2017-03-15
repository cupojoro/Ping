//
//  PGHomeViewController.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGHomeViewController.h"

#import "PGGamePageViewController.h"
#import "PGHomeModel.h"
#import "PGHomeView.h"
#import "PGSearchCell.h"

#import "Firebase.h"

@interface PGHomeViewController () < UISearchBarDelegate>

@property (nonatomic, strong) PGHomeModel *homeModel;
@property (nonatomic, strong) PGHomeView *homeView;

@property (nonatomic) int maxTextLength;
@end

@implementation PGHomeViewController

-(id)init
{
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearchCells) name:@"PGQueryComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retroSearch) name:@"PGRetroSearch" object:nil];
    
    self.maxTextLength = 20;
    
    self.homeModel = [[PGHomeModel alloc] init];
    
    self.homeView = [[PGHomeView alloc] initWithController:self];
    [self.view addSubview:self.homeView];
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    self.homeView.frame = self.view.frame;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.homeModel retroCheck];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Search

-(void)retroSearch
{
    [self.homeView clearSearchCells];
    [self.homeModel querySearchResults];
}

#pragma mark Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.view.frame.size.width;
    float fractionalPage = [self.homeView getContentOffset].x /pageWidth;
    NSInteger page = lround(fractionalPage);
    [self.homeView setCurrentPage:page];
}

#pragma mark Feautred Game

-(void)featureGameTap: (UITapGestureRecognizer *) sender {
    UIImageView *iV = (UIImageView *) [sender view];
    FIRDatabaseReference *dataRef = [[FIRDatabase database] reference];
    NSString *fName;
    if(iV.tag == 0) fName = @"f0Name";
    else if(iV.tag == 1) fName = @"f1Name";
    else if(iV.tag == 2) fName = @"f2Name";
    NSString *path = [NSString stringWithFormat:@"featuredImages/%@",fName];
    
    [[dataRef child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *gameDestination = (NSString *) snapshot.value;
        NSString *gameTitle = [[gameDestination componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]] objectAtIndex:1];
        PGGamePageViewController *gamePage = [[PGGamePageViewController alloc] initWith:gameTitle At:gameDestination];
        [self.navigationController pushViewController:gamePage animated:NO];
    }];
}
#pragma mark SearchBar

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *text = ([searchText length] > self.maxTextLength) ? [searchText substringToIndex:self.maxTextLength] : searchText;
    [searchBar setText:text];
    
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.homeView clearSearchCells];
    [self.homeModel setSearch:[searchBar.text lowercaseString]];
    [searchBar endEditing:YES];
    [self.homeModel querySearchResults];
}

#pragma mark Cell

-(void) cellPicked:(id)sender
{
    UIButton *button = (UIButton *) sender;
    PGSearchCell *cell = [self.homeView cellWithTag:(int) button.tag];
    if(cell.inUse == YES)
    {
        NSString *gameTitle = cell.gameTitle;
        NSString *gameDestination = cell.gameDestination;
        PGGamePageViewController *gamePage = [[PGGamePageViewController alloc] initWith:gameTitle At:gameDestination];
        [self.navigationController pushViewController:gamePage animated:NO];
    }
}

-(void)updateSearchCells
{
    NSArray *gameTitles = [self.homeModel getSearchTitles];
    NSArray *gameDestinations = [self.homeModel getSearchDest];
    [self.homeView setCellsWithGame:gameTitles andDestinations:gameDestinations];
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
}
@end
