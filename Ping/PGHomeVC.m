//
//  PGHomeVC.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-07.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGHomeVC.h"
#import "Masonry.h"
#import "Firebase.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PGHomeVC () <UIScrollViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIScrollView* featureGameView;
@property (nonatomic, strong) UIPageControl* fgPageControl;
@property (nonatomic, strong) UISearchBar* gameSearchBar;
@property (nonatomic, strong) FIRDatabaseReference *dataRef;

@end

@implementation PGHomeVC
{
    NSInteger totalFeaturedGames;
    NSInteger maxTextLength;
    NSString *storageURL;
}

-(id)init{
    self = [super init];
    
    if(self){
        totalFeaturedGames = 3;
        maxTextLength = 20;
        storageURL = @"gs://ping-75955.appspot.com";
        
        self.dataRef = [[FIRDatabase database] reference];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillDismiss:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
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
    
    [self applyMASConstraints];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setFeaturedImages];
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
        make.center.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
     
}

-(void) setFeaturedImages{
    
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage referenceForURL:storageURL];
    NSString *userID = [FIRAuth auth].currentUser.uid;
    NSLog(@"\nUSER ID : %@", userID);
    NSLog(@"\nUSER CREATED");
    
    [[self.dataRef child:@"featuredImages"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableString *tag = [[NSMutableString alloc] initWithString:@"f0URL"];
        for( int imageNumber = 0; imageNumber <= totalFeaturedGames; imageNumber++){
            [tag replaceCharactersInRange:NSMakeRange(1, 1) withString:[@(imageNumber) stringValue]];
            NSURL *url = [NSURL URLWithString:snapshot.value[tag]];
            NSLog(@"\nURL : %@", url);
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.clipsToBounds = YES;
            imageView.frame = CGRectMake( self.featureGameView.frame.size.width * imageNumber, 0, self.featureGameView.frame.size.width, self.featureGameView.frame.size.height);
            [self.featureGameView addSubview:imageView];
        }
        
    }];
    
    //[[[self.dataRef child:@"featuredImages"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    //    NSURL *url = [NSURL URLWithString:snapshot.value[@"f1URL" ]];
    //    NSLog(@"\n F! URL : %@", url);
    //} withCancelBlock:^(NSError * _Nonnull error) {
    //    NSLog(@"\n HERE WE ARE!!!!! %@", error.localizedDescription);
    //}];
    
    /*
    NSArray* imageNames = @[@"FFXV", @"RE7", @"SAO"];
    for ( int imageNumber = 0; imageNumber < totalFeaturedGames; imageNumber++){
        NSString *imageName = imageNames[imageNumber];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;
        imageView.frame = CGRectMake( self.featureGameView.frame.size.width * imageNumber, 0, self.featureGameView.frame.size.width, self.featureGameView.frame.size.height);
        [self.featureGameView addSubview:imageView];
    }
    */
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.featureGameView.frame.size.width;
    float fractionalPage = self.featureGameView.contentOffset.x /pageWidth;
    NSInteger page = lround(fractionalPage);
    self.fgPageControl.currentPage = page;
}

-(void)keyboardWillShow: (NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self.gameSearchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(0-kbSize.height);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width);
    }];
    //NSLog(@"\nAnimation Duration : %@", [info objectForKey:UIKeyboardAnimationDurationUserInfoKey]);
    [UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [self.gameSearchBar layoutIfNeeded];
    }];
}

-(void)keyboardWillDismiss: (NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    [self.gameSearchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view.mas_width);
    }];
    //NSLog(@"\nAnimation Duration : %@", [info objectForKey:UIKeyboardAnimationDurationUserInfoKey]);
    [UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [self.gameSearchBar layoutIfNeeded];
    }];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchText = ([searchText length] > maxTextLength) ? [searchText substringToIndex:maxTextLength] : searchText;
    [searchBar setText:searchText];
    
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"\nSEARCHED TEXT : %@", searchBar.text);
    [self.view endEditing:YES];
}
@end
