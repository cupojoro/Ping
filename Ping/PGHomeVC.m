//
//  PGHomeVC.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-07.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGHomeVC.h"
#import "Masonry.h"

@interface PGHomeVC () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView* featureGameView;
@property (nonatomic, strong) UIPageControl* fgPageControl;
@property (nonatomic, strong) UISearchBar* gameSearchBar;

@end

@implementation PGHomeVC
{
    NSInteger totalFeaturedGames;
}

-(id)init{
    self = [super init];
    if(self){
        totalFeaturedGames = 3;
        
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
    NSArray* imageNames = @[@"FFXV", @"RE7", @"SAO"];
    for ( int imageNumber = 0; imageNumber < totalFeaturedGames; imageNumber++){
        NSString *imageName = imageNames[imageNumber];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;
        imageView.frame = CGRectMake( self.featureGameView.frame.size.width * imageNumber, 0, self.featureGameView.frame.size.width, self.featureGameView.frame.size.height);
        [self.featureGameView addSubview:imageView];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.featureGameView.frame.size.width;
    float fractionalPage = self.featureGameView.contentOffset.x /pageWidth;
    NSInteger page = lround(fractionalPage);
    self.fgPageControl.currentPage = page;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)keyboardWillShow: (NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"\nKB SIZE: %f", kbSize.height);
    [self.gameSearchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(0-kbSize.height);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width);
    }];
    //NSLog(@"\nAnimation Duration : %@", [info objectForKey:UIKeyboardAnimationDurationUserInfoKey]);
    [UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)keyboardWillDismiss: (NSNotification*)notification
{
    
}

@end
