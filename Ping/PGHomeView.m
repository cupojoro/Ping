//
//  PGHomeView.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGHomeView.h"

#import "Masonry.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PGHomeView ()

@property (nonatomic, strong) UIScrollView* featureGameView;
@property (nonatomic, strong) UIPageControl* fgPageControl;
@property (nonatomic, strong) UISearchBar* gameSearchBar;
@property (nonatomic, strong) NSMutableArray* searchResultViews;

@property (nonatomic, strong) NSString *storageURL;
@property (nonatomic) int maxSearchResults;
@property (nonatomic) int totalFeaturedGames;

@end

@implementation PGHomeView

-(id)initWithController:(PGHomeViewController *)controller
{
    self = [super init];
    
    self.totalFeaturedGames = 3;
    self.storageURL = @"gs://ping-75955.appspot.com";
    self.maxSearchResults = 5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDismiss:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.featureGameView = [[UIScrollView alloc] init];
    self.featureGameView.delegate = controller;
    CGSize cSize = controller.view.bounds.size;
    cSize.width *= self.totalFeaturedGames;
    cSize.height /= 2;
    self.featureGameView.contentSize = cSize;
    self.featureGameView.pagingEnabled = YES;
    self.featureGameView.bounces = NO;
    self.featureGameView.showsHorizontalScrollIndicator = NO;
    
    self.fgPageControl = [[UIPageControl alloc] init];
    self.fgPageControl.numberOfPages = self.totalFeaturedGames;
    self.fgPageControl.currentPage = 0;
    self.fgPageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    
    self.gameSearchBar = [[UISearchBar alloc] init];
    self.gameSearchBar.delegate = controller;
    [self.gameSearchBar setPlaceholder:@"Search For Game Maps"];
    self.gameSearchBar.barStyle = UISearchBarStyleMinimal;
    self.gameSearchBar.translucent = YES;
    [self.gameSearchBar setKeyboardType:UIKeyboardTypeASCIICapable];
    
    [self addSubview:self.featureGameView];
    [self addSubview:self.fgPageControl];
    [self addSubview:self.gameSearchBar];
    [self bringSubviewToFront:self.gameSearchBar];
    
    //THIS ARRAY HOLDS ALL OF THE SEARCHCELL VIEWS
    self.searchResultViews = [[NSMutableArray alloc] initWithCapacity:self.maxSearchResults];
    
    //float cellHeight = (self.frame.size.height - self.gameSearchBar.frame.size.height * 2 ) / (2 * self.maxSearchResults);
    //INIT CELLS TO BE BLANK
    for( int viewNumber = 0; viewNumber < self.maxSearchResults; viewNumber++){
        
        PGSearchCell *view = [[PGSearchCell alloc] initWith:@"" PointingTo:@"" withParent:controller];
        view.tag = viewNumber;
        [self.searchResultViews addObject:view];
        [self addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.centerX.equalTo(self);
            //CANT GET SEARCH BAR HEIGHT YET - DEFAULT IS 44. OFFSET 44
            make.height.equalTo(self).dividedBy(2 * self.maxSearchResults).with.offset(-44/(self.maxSearchResults));
            if(viewNumber == (self.maxSearchResults - 1)){
                UIView *temp = [self.searchResultViews objectAtIndex:(viewNumber-1)];
                make.top.equalTo(temp.mas_bottom);
                make.bottom.equalTo(self.mas_bottom);
            }else if(viewNumber != 0){
                UIView *temp = [self.searchResultViews objectAtIndex:(viewNumber-1)];
                make.top.equalTo(temp.mas_bottom);
            }
        }];
    }
    //LOAD AND PLACE IMAGES
    FIRDatabaseReference *dataRef = [[FIRDatabase database] reference];
    [[dataRef child:@"featuredImages"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableString *tag = [[NSMutableString alloc] initWithString:@"f0URL"];
        for( int imageNumber = 0; imageNumber < self.totalFeaturedGames; imageNumber++){
            [tag replaceCharactersInRange:NSMakeRange(1, 1) withString:[@(imageNumber) stringValue]];
            NSURL *url = [NSURL URLWithString:snapshot.value[tag]];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
            imageView.tag = imageNumber;
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.clipsToBounds = YES;
            imageView.frame = CGRectMake( self.featureGameView.frame.size.width * imageNumber, 0, self.featureGameView.frame.size.width, self.featureGameView.frame.size.height);
            [self.featureGameView addSubview:imageView];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:controller action:@selector(featureGameTap:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.delaysTouchesEnded = NO;
            [imageView setUserInteractionEnabled: YES];
            [imageView addGestureRecognizer:singleTap];
        }
        
    }];
    
    [self makeConstraints];
    return self;
}

#pragma mark Constraints

-(void)makeConstraints
{
    
    [self.featureGameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).dividedBy(2);
        make.height.equalTo(self).dividedBy(2);
        make.width.equalTo(self);
    }];
    
    [self.fgPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.gameSearchBar.mas_top);
        make.centerX.equalTo(self.featureGameView.mas_centerX);
    }];
    
    [self.gameSearchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_centerY);
        make.width.equalTo(self);
    }];
}

#pragma mark Scroll View

-(void)setCurrentPage:(NSInteger)page
{
    self.fgPageControl.currentPage = page;
}

-(CGPoint)getContentOffset
{
    return self.featureGameView.contentOffset;
}

#pragma mark Keyboard

-(void)keyboardWillShow: (NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self.gameSearchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(0-kbSize.height);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(self.mas_width);
    }];
    [UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [self.gameSearchBar layoutIfNeeded];
    }];
}

-(void)keyboardWillDismiss: (NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    [self.gameSearchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_centerY);
        make.width.equalTo(self.mas_width);
    }];
    [UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [self.gameSearchBar layoutIfNeeded];
    }];
}

#pragma mark Search Cells

-(PGSearchCell *)cellWithTag:(int)number
{
    for(PGSearchCell *cell in self.searchResultViews)
    {
        if(cell.tag == number) return cell;
    }
    return nil;
}

-(void)clearSearchCells
{
    for(PGSearchCell *cell in self.searchResultViews){
        [cell setTitle:@"" setDestination:@"" buttonVisibile:NO];
        cell.inUse = NO;
    }
}

-(void)setCellsWithGame:(NSArray *)titles andDestinations:(NSArray *)dest
{
    int index = 0;
    for(PGSearchCell *cell in self.searchResultViews)
    {
        if(index < [titles count])
        {
            [cell setTitle:titles[index] setDestination:dest[index] buttonVisibile:YES];
            if([dest[index] isEqualToString:@""]) cell.inUse = NO;
            else cell.inUse = YES;
        }
        index++;
    }
}

@end
