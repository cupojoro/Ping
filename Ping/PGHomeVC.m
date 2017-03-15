//
//  PGHomeVC.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-07.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGHomeVC.h"

#import "PGSearchCell.h"
#import "PGGamePageVC.h"

#import "Masonry.h"
#import "Firebase.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PGHomeVC () <UIScrollViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIScrollView* featureGameView;
@property (nonatomic, strong) UIPageControl* fgPageControl;
@property (nonatomic, strong) UISearchBar* gameSearchBar;
@property (nonatomic, strong) NSMutableArray* searchResultViews;

@end

@implementation PGHomeVC
{
    NSInteger totalFeaturedGames;
    NSInteger maxTextLength;
    
    NSString *searchResults;
    NSString *storageURL;
    
    NSInteger maxSearchResults; //Make it even
    
}

-(id)init{
    self = [super init];
    
    if(self){
        totalFeaturedGames = 3;
        maxTextLength = 20;
        storageURL = @"gs://ping-75955.appspot.com";
        maxSearchResults = 5;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillDismiss:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        NSString *lastSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastSearch"];
        if(lastSearch != NULL) searchResults = lastSearch;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.featureGameView = [[UIScrollView alloc] init];
    self.featureGameView.delegate = self;
    CGSize cSize = self.view.bounds.size;
    cSize.width *= totalFeaturedGames;
    cSize.height /= 2;
    self.featureGameView.contentSize = cSize;
    self.featureGameView.pagingEnabled = YES;
    self.featureGameView.bounces = NO;
    self.featureGameView.showsHorizontalScrollIndicator = NO;
    
    
    self.fgPageControl = [[UIPageControl alloc] init];
    self.fgPageControl.numberOfPages = totalFeaturedGames;
    self.fgPageControl.currentPage = 0;
    self.fgPageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    
    self.gameSearchBar = [[UISearchBar alloc] init];
    self.gameSearchBar.delegate = self;
    [self.gameSearchBar setPlaceholder:@"Search For Game Maps"];
    self.gameSearchBar.barStyle = UISearchBarStyleMinimal;
    self.gameSearchBar.translucent = YES;
    [self.gameSearchBar setKeyboardType:UIKeyboardTypeASCIICapable];
    
    [self.view addSubview:self.featureGameView];
    [self.view addSubview:self.fgPageControl];
    [self.view addSubview:self.gameSearchBar];
    [self.view bringSubviewToFront:self.gameSearchBar];
    
    [self applyMASConstraints];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    [self setFeaturedImages];
    if(searchResults != NULL) [self quierySearchResults];
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self createSearchBar];
    
}
-(void)applyMASConstraints{
    [self.featureGameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).dividedBy(2);
        make.height.equalTo(self.view).dividedBy(2);
        make.width.equalTo(self.view);
    }];
    
    [self.fgPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.gameSearchBar.mas_top);
        make.centerX.equalTo(self.featureGameView.mas_centerX);
    }];
    
    [self.gameSearchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_centerY);
        make.width.equalTo(self.view);
    }];
     
}

-(void) createSearchBar{
    /*
    if(self.searchResultViews != NULL) return;
    self.searchResultViews = [[NSMutableArray alloc] initWithCapacity:maxSearchResults];
    float cellHeight = (self.view.frame.size.height - self.gameSearchBar.frame.size.height * 2 ) / (2 * maxSearchResults);
    
    for( int viewNumber = 0; viewNumber < maxSearchResults; viewNumber++){
        
        PGSearchCell *view = [[PGSearchCell alloc] initWith:@"" PointingTo:@"" withParent:self];
        [self.searchResultViews addObject:view];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo([NSNumber numberWithFloat:cellHeight]);
            if(viewNumber == (maxSearchResults - 1)){
                UIView *temp = [self.searchResultViews objectAtIndex:(viewNumber-1)];
                make.top.equalTo(temp.mas_bottom);
                make.bottom.equalTo(self.view.mas_bottom);
            }else if(viewNumber != 0){
                UIView *temp = [self.searchResultViews objectAtIndex:(viewNumber-1)];
                make.top.equalTo(temp.mas_bottom);
            }
        }];
    }
     */
}

-(void) setFeaturedImages{
    
    //Need to access images this way since we will never know the image name thats in storage
    FIRDatabaseReference *dataRef = [[FIRDatabase database] reference];
    [[dataRef child:@"featuredImages"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableString *tag = [[NSMutableString alloc] initWithString:@"f0URL"];
        for( int imageNumber = 0; imageNumber < totalFeaturedGames; imageNumber++){
            [tag replaceCharactersInRange:NSMakeRange(1, 1) withString:[@(imageNumber) stringValue]];
            NSURL *url = [NSURL URLWithString:snapshot.value[tag]];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
            imageView.tag = imageNumber;
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.clipsToBounds = YES;
            imageView.frame = CGRectMake( self.featureGameView.frame.size.width * imageNumber, 0, self.featureGameView.frame.size.width, self.featureGameView.frame.size.height);
            [self.featureGameView addSubview:imageView];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(featureGameTap:)];
            singleTap.numberOfTapsRequired = 1;
            [imageView setUserInteractionEnabled: YES];
            [imageView addGestureRecognizer:singleTap];
        }
        
    }];
}

#pragma mark ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.featureGameView.frame.size.width;
    float fractionalPage = self.featureGameView.contentOffset.x /pageWidth;
    NSInteger page = lround(fractionalPage);
    self.fgPageControl.currentPage = page;
}

-(void)featureGameTap: (UITapGestureRecognizer *) sender {
    UIImageView *iV = (UIImageView *) [sender view];
    FIRDatabaseReference *dataRef = [[FIRDatabase database] reference];
    NSString *fName;
    if(iV.tag == 0) fName = @"f0Name";
    else if(iV.tag == 1) fName = @"f1Name";
    else if(iV.tag == 2) fName = @"f2Name";
    [[dataRef child:@"featuredImages"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        PGGamePageVC *gamePage = [[PGGamePageVC alloc] initWithGameTitle:snapshot.value[fName] andDestination:snapshot.value[fName]];
        [self.navigationController pushViewController:gamePage animated:NO];
    }];
}

#pragma mark Keyboard

-(void)keyboardWillShow: (NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self.gameSearchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(0-kbSize.height);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width);
    }];
    [UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [self.gameSearchBar layoutIfNeeded];
    }];
}

-(void)keyboardWillDismiss: (NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    [self.gameSearchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_centerY);
        make.width.equalTo(self.view.mas_width);
    }];
    [UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [self.gameSearchBar layoutIfNeeded];
    }];
}

#pragma mark SearchBar

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchText = ([searchText length] > maxTextLength) ? [searchText substringToIndex:maxTextLength] : searchText;
    [searchBar setText:searchText];
    
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    for(PGSearchCell *cell in self.searchResultViews){
        [cell setTitle:@"" setDestination:@"" buttonVisibile:NO];
        cell.inUse = NO;
    }
    searchResults = [searchBar.text lowercaseString];
    [[NSUserDefaults standardUserDefaults] setObject:searchResults forKey:@"LastSearch"];
    [self.view endEditing:YES];
    [self quierySearchResults];
}

#pragma mark Search Results

-(void) quierySearchResults
{
    NSString *currentSearch = searchResults;
    FIRDatabaseReference *dataRef = [[FIRDatabase database] reference];
    FIRDatabaseQuery *gameList = [dataRef child:@"gameList"];
    [gameList observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        BOOL foundData = NO;
        for(FIRDataSnapshot *child in snapshot.children){
            if([currentSearch isEqualToString:child.key]){
                foundData = YES;
                if([child hasChildren]){
                    //Wont go deeper than this
                    for(FIRDataSnapshot *grandChild in child.children){
                        searchResults = grandChild.key;
                        [self quierySearchResults];
                    }
                }else if([child.value isEqualToString:@"active"]){
                    //LOAD DATA
                    for(PGSearchCell *cell in self.searchResultViews){
                        if(!cell.inUse){
                            [cell setTitle:child.key setDestination:child.key buttonVisibile:YES];
                            return;
                        }
                    }
                    return;
                    
                }else if([child.value isEqualToString:@"inactive"]){
                    //NO DATA
                    for(PGSearchCell *cell in self.searchResultViews){
                        if(!cell.inUse){
                            NSString *report = [NSString stringWithFormat:@"%@ DOESNT HAVE ALL ITS MAP DATA", child.key];
                            [cell setTitle:report setDestination:@"" buttonVisibile:NO];
                            return;
                        }
                    }
                    return;
                }else{
                    //VALUE IS FOR ANOTHER SEARCH
                    searchResults = child.value;
                    [self quierySearchResults];
                    return;
                }
            }
        }if(!foundData){ //COULDNT MATCH THE STRING
            for(PGSearchCell *cell in self.searchResultViews){
                if(!cell.inUse){
                    NSString *report = [NSString stringWithFormat:@"COULD NOT FIND MAP DATA FOR %@", currentSearch];
                    [cell setTitle:report setDestination:@"" buttonVisibile:NO];
                    break;
                }
            }
            return;
        }
        
    }];

}
@end
