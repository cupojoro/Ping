//
//  PGMapView.m
//  Ping
//
//  Created by Joseph Ross on 2017-01-10.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGMapView.h"

#import "PGGridCell.h"

#import "Masonry.h"

@interface PGMapView () <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) PGMapInterfaceVC *mapInterface;

@property (nonatomic, strong) UIScrollView *contentWindow;
@property (nonatomic, strong) UIView *imageModule;
@property (nonatomic, strong) UICollectionView *gridView;
@property (nonatomic, strong) UIImageView *mapImage;

@end

@implementation PGMapView

NSInteger gridSize = 60; //ABOUT MAX SIZE
BOOL gridNotHidden = NO;

//STAND IN DATA
NSMutableArray *gridData;

-(id) initWithFrame:(CGRect)viewFrame mapInterface:(PGMapInterfaceVC *)mapIV
{
    self = [super init];
    
    self.frame = viewFrame;
    
    self.mapInterface = mapIV;
    
    //STAND IN DATA
    gridData = [NSMutableArray arrayWithCapacity:(gridSize * gridSize)];
    int i = 0;
    for(i = 0; i < (gridSize * gridSize); i++)
        [gridData addObject:[NSNumber numberWithInteger:0]];
    
    //MAP CONTENT
    self.mapImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ffxvDuscae"]];
    CGRect frame = viewFrame;
    //frame.size.height -= toolbarHeight;
    [self.mapImage setFrame:frame];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumLineSpacing:0];
    [layout setMinimumInteritemSpacing:0];
    [layout setItemSize:CGSizeMake(frame.size.width/gridSize, frame.size.height/gridSize)];
    self.gridView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.userInteractionEnabled = YES;
    self.gridView.bounces = NO;
    self.gridView.bouncesZoom = NO;
    [self.gridView setDelegate:self];
    [self.gridView setDataSource:self];
    [self.gridView registerClass:[PGGridCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    self.contentWindow = [[UIScrollView alloc] initWithFrame:frame];
    self.contentWindow.delegate = self;
    self.contentWindow.contentSize = frame.size;
    [self.contentWindow setScrollEnabled:YES];
    self.contentWindow.bounces = NO;
    self.contentWindow.bouncesZoom = NO;
    [self.contentWindow setMinimumZoomScale:1.0];
    [self.contentWindow setMaximumZoomScale:10.0];
    self.contentWindow.userInteractionEnabled = YES;
    
    self.imageModule = [[UIView alloc] initWithFrame:frame];
    [self.imageModule addSubview:self.mapImage];
    [self.imageModule addSubview:self.gridView];
    [self.contentWindow addSubview:self.imageModule];
    [self addSubview:self.contentWindow];
    
    return self;
}

-(void) applyMASConstraints
{
    [self.contentWindow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.center.equalTo(self);
    }];
}

-(void)gridSwitch
{
    gridNotHidden = !gridNotHidden;
    [self.gridView reloadData];
}

-(void)reloadGrid
{
    [self.gridView reloadData];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageModule;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return gridSize*gridSize;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    PGGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    NSNumber *data = [gridData objectAtIndex:indexPath.row];
    if(data.intValue != 0){
        if(data.intValue == 1){
            [cell addImage:@"key"];
        }else if(data.intValue == 2){
            [cell addImage:@"king"];
        }else if(data.intValue == 3){
            [cell addImage:@"money"];
        }
        [cell setTintColor:[self.mapInterface getTintColor]];
    }
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
    
    return CGSizeMake(self.frame.size.width/gridSize, (self.frame.size.height)/gridSize);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger geoID = [self.mapInterface getGeoID];
    if(geoID != 0){
        NSNumber *data = [gridData objectAtIndex:indexPath.row];
        if(geoID == [data integerValue]) [gridData replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:0]];
        else [gridData replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:geoID]];
    }
    NSLog(@"CELL:GEOID || %ld, %@",indexPath.row, [gridData objectAtIndex:indexPath.row]);
    [self.gridView reloadData];
}

@end
