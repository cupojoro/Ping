//
//  PGMapInterfaceVC.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-08.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGMapInterfaceVC.h"

#import "Masonry.h"
#import "Firebase.h"

@interface PGMapInterfaceVC () <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIScrollView *contentWindow;
@property (nonatomic, strong) UIView *imageModule;
@property (nonatomic, strong) UICollectionView *gridView;
@property (nonatomic, strong) UIImageView *mapImage;
@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UIButton *gridButton;
@property (nonatomic, strong) UIButton *keyButton;
@property (nonatomic, strong) UIButton *crownButton;
@property (nonatomic, strong) UIButton *moneyButton;

@end

@implementation PGMapInterfaceVC

NSURL *mapImageURL;
NSMutableArray *gridData;
NSInteger axisSize;
BOOL gridNotHidden;

-(id)initWithURL: (NSURL *)url andGrid: (NSMutableArray *)gData
{
    self = [super init];
    if(self){
        mapImageURL = url;
        gridData = gData;
        axisSize = 30;
        gridNotHidden = YES;
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //TOOLBAR
    self.toolbarView = [[UIView alloc] init];
    self.toolbarView.backgroundColor = [UIColor grayColor];
    
    self.gridButton = [[UIButton alloc] init];
    [self.gridButton setImage:[UIImage imageNamed:@"grid"] forState:UIControlStateNormal];
    [self.gridButton addTarget:self action:@selector(gridButtonSwitch) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolbarView addSubview:self.gridButton];
    
    //MAP CONTENT
    self.mapImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ffxvDuscae"]];
    [self.mapImage setFrame:self.view.frame];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumLineSpacing:0];
    [layout setMinimumInteritemSpacing:0];
    [layout setItemSize:CGSizeMake(self.view.frame.size.width/axisSize, self.view.frame.size.height/axisSize)];
    self.gridView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.userInteractionEnabled = YES;
    [self.gridView setDelegate:self];
    [self.gridView setDataSource:self];
    [self.gridView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    self.imageModule = [[UIView alloc] initWithFrame:self.view.frame];
    [self.imageModule addSubview:self.mapImage];
    [self.imageModule addSubview:self.gridView];
    
    self.contentWindow = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.contentWindow.delegate = self;
    self.contentWindow.contentSize = self.view.frame.size;
    [self.contentWindow setScrollEnabled:YES];
    self.contentWindow.bounces = NO;
    self.contentWindow.bouncesZoom = NO;
    [self.contentWindow setMinimumZoomScale:1.0];
    [self.contentWindow setMaximumZoomScale:10.0];
    self.contentWindow.userInteractionEnabled = YES;
    
    [self.view addSubview:self.toolbarView];
    [self.view addSubview:self.contentWindow];
    [self.contentWindow addSubview:self.imageModule];
    [self.view bringSubviewToFront:self.toolbarView];
    
    [self applyMASConstraints];
}

-(void) applyMASConstraints
{
    [self.contentWindow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    
    [self.toolbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@75);
        make.width.equalTo(self.view.mas_width);
        make.bottom.equalTo(self.view.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.gridButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.toolbarView.mas_height);
        make.left.equalTo(self.toolbarView.mas_left);
        make.centerY.equalTo(self.toolbarView.mas_centerY);
    }];
    
}


-(void)gridButtonSwitch
{
    NSLog(@"BUTTON CLICKED");
    gridNotHidden = !gridNotHidden;
    [self.gridView reloadData];
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageModule;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return axisSize*axisSize;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    if(gridNotHidden){
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.backgroundColor = [UIColor clearColor];
    }else{
        cell.layer.borderWidth = 0;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    return CGSizeMake(self.view.frame.size.width/axisSize, self.view.frame.size.height/axisSize);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"CELL %ld",indexPath.row);
}
@end
