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
#import "Firebase.h"

@interface PGMapView () <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) PGMapInterfaceVC *mapInterface;

@property (nonatomic, strong) UIScrollView *contentWindow;
@property (nonatomic, strong) UIView *imageModule;
@property (nonatomic, strong) UICollectionView *gridView;
@property (nonatomic, strong) UIImageView *mapImage;
@property (nonatomic, strong) UITextField *detailsBar;
@property (nonatomic, strong) UILabel *detailCharacterCount;

@property (nonatomic) NSInteger gridSize;
@property (nonatomic) BOOL gridNotHidden;
@property (nonatomic, strong) NSMutableString *details;

@property (nonatomic, strong) NSMutableArray *gridData;
//@property (nonatomic) NSMutableArray *netVotes;

@end

@implementation PGMapView

-(id) initWithMapInterface:(PGMapInterfaceVC *)mapIV andGridSize:(int)size andGridData:(NSMutableArray *)gData
{
    self = [super init];
    
    self.gridSize = size;
    
    self.gridNotHidden = NO;
    self.details = [[NSMutableString alloc] initWithString:@""];
    
    self.mapInterface = mapIV;
    self.mapInterface.automaticallyAdjustsScrollViewInsets = NO;
    
    self.gridData = gData;
    /*
    self.netVotes = [[NSMutableArray alloc] initWithCapacity:self.gridSize*self.gridSize];
    for(int i = 0; i < (self.gridSize*self.gridSize); i++)
    {
        self.netVotes[i] = @0;
    }
    */
    //STAND IN DATA
    //gridData = [NSMutableArray arrayWithCapacity:(self.gridSize * self.gridSize)];
    //int i = 0;
    //for(i = 0; i < (self.gridSize * self.gridSize); i++)
    //    [gridData addObject:[NSNumber numberWithInteger:0]];
    /*
    NSString *path = [NSString stringWithFormat:@"activeGames/%@/gridValues/%@", [mapIV getGameName], [mapIV getMapName]];
    
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[dBref child:path] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.gridData = (NSMutableArray *) snapshot.value;
        if([self.gridData isEqual:[NSNull null]]){
            self.gridData = [[NSMutableArray alloc] initWithCapacity:self.gridSize*self.gridSize];
            for(int i = 0; i < (self.gridSize*self.gridSize); i++){
                self.gridData[i] = @0;
            }
        }
        
        NSString *voterPath = [NSString stringWithFormat:@"activeGames/%@/gridVotes/%@", [mapIV getGameName], [mapIV getMapName]];
        [[dBref child:voterPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            self.netVotes = [[NSMutableArray alloc] initWithCapacity:self.gridSize*self.gridSize];
            NSMutableString *cell = (NSMutableString *) @"cell";
            for(int i = 0; i < (self.gridSize*self.gridSize); i++)
            {
                cell = [NSMutableString stringWithFormat:@"cell%d", i];
                if(![snapshot.value isKindOfClass:[NSNumber class]]){
                    NSDictionary *voteDict = (NSDictionary *) snapshot.value[cell];
                    if(voteDict != nil && ![voteDict isEqual:[NSNull null]])
                    {
                        NSArray *up = (NSArray *) voteDict[@"upvote"];
                        NSArray *down = (NSArray *) voteDict[@"downvote"];
                        unsigned long totalUp = 0;
                        unsigned long totalDown = 0;
                        if(![[up objectAtIndex:0] isKindOfClass:[NSNumber class]]) totalUp = [up count];
                        if(![[down objectAtIndex:0] isKindOfClass:[NSNumber class]]) totalDown = [down count];
                        self.netVotes[i] = @(totalUp - totalDown);
                    }
                    else self.netVotes[i] = @0;
                }
            }
            [self.gridView reloadData];
        }];
     
    }];
    */
    //MAP CONTENT
    self.mapImage = [[UIImageView alloc] init];
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *mapPath = [NSString stringWithFormat:@"activeGames/%@/images/%@", [mapIV getGameName], [mapIV getMapName]];
    [[dBref child:mapPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.mapImage removeFromSuperview];
        NSURL *url = [NSURL URLWithString:(NSString *)snapshot.value];
        UIImage *map = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        self.mapImage = [[UIImageView alloc] initWithImage:map];
        [self.imageModule addSubview:self.mapImage];
        [self.imageModule sendSubviewToBack:self.mapImage];
        [self setNeedsUpdateConstraints];
        
    }];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumLineSpacing:0];
    [layout setMinimumInteritemSpacing:0];
    self.gridView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.userInteractionEnabled = YES;
    self.gridView.bounces = NO;
    self.gridView.bouncesZoom = NO;
    [self.gridView setDelegate:self];
    [self.gridView setDataSource:self];
    [self.gridView registerClass:[PGGridCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    self.contentWindow = [[UIScrollView alloc] init];
    self.contentWindow.delegate = self;
    [self.contentWindow setScrollEnabled:YES];
    self.contentWindow.bounces = NO;
    self.contentWindow.bouncesZoom = NO;
    [self.contentWindow setMinimumZoomScale:1.0];
    [self.contentWindow setMaximumZoomScale:5.0];
    self.contentWindow.userInteractionEnabled = YES;
    
    self.imageModule = [[UIView alloc] init];
    [self.imageModule addSubview:self.mapImage];
    [self.imageModule addSubview:self.gridView];
    [self.contentWindow addSubview:self.imageModule];
    [self addSubview:self.contentWindow];
    
    self.detailsBar = [[UITextField alloc] init];
    [self.detailsBar setPlaceholder:@"Info about this edit"];
    [self.detailsBar setTextAlignment:NSTextAlignmentCenter];
    [self.detailsBar setDelegate:self];
    [self.detailsBar setKeyboardType:UIKeyboardTypeAlphabet];
    [self.detailsBar setBackgroundColor:[UIColor lightGrayColor]];
    self.detailsBar.hidden = YES;
    [self addSubview:self.detailsBar];
    
    self.detailCharacterCount = [[UILabel alloc] init];
    self.detailCharacterCount.hidden = YES;
    [self.detailCharacterCount setBackgroundColor:[UIColor redColor]];
    [self.detailCharacterCount setTextColor:[UIColor whiteColor]];
    [self addSubview:self.detailCharacterCount];
    
    [self setNeedsUpdateConstraints];
    
    return self;
}

-(void) updateConstraints
{
    [self.contentWindow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.equalTo(self.mas_height);
        make.center.equalTo(self);
    }];
    
    [self.imageModule mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self);
        make.top.equalTo(self.contentWindow);
        make.left.equalTo(self.contentWindow);
    }];
    
    [self.mapImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self);
        make.top.left.equalTo(self.imageModule);
    }];
    
    [self.gridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self);
        make.top.left.equalTo(self.imageModule);
    }];
    
    [self.detailsBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.centerX.equalTo(self);
        make.top.equalTo(self);
    }];
    [self.detailCharacterCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.detailsBar.mas_bottom);
        make.right.equalTo(self);
    }];
    
    [super updateConstraints];
}

-(bool)hasItemAtIndex:(int)cell
{
    if([self.gridData isEqual:[NSNull null]]) return NO;
    return !([self.gridData[cell] isEqual:@(0)]);
}
-(void)gridSwitch
{
    self.gridNotHidden = !self.gridNotHidden;
    [self.gridView reloadData];
}
-(void)forceGrid:(BOOL)value
{
    self.gridNotHidden = value;
    [self.gridView reloadData];
}

-(void)reloadGridWithVoters:(BOOL)update
{
    /*
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *voterPath = [NSString stringWithFormat:@"activeGames/%@/gridVotes/%@", [self.mapInterface getGameName], [self.mapInterface getMapName]];
    if(update) [[dBref child:voterPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.netVotes = [[NSMutableArray alloc] initWithCapacity:self.gridSize*self.gridSize];
        NSMutableString *cell = (NSMutableString *) @"cell";
        for(int i = 0; i < (self.gridSize*self.gridSize); i++)
        {
            cell = [NSMutableString stringWithFormat:@"cell%d", i];
            if(![snapshot.value isKindOfClass:[NSNumber class]]){
                NSDictionary *voteDict = (NSDictionary *) snapshot.value[cell];
                if(voteDict != nil && ![voteDict isEqual:[NSNull null]])
                {
                    NSArray *up = (NSArray *) voteDict[@"upvote"];
                    NSArray *down = (NSArray *) voteDict[@"downvote"];
                    unsigned long totalUp = 0;
                    unsigned long totalDown = 0;
                    if(![[up objectAtIndex:0] isKindOfClass:[NSNumber class]]) totalUp = [up count];
                    if(![[down objectAtIndex:0] isKindOfClass:[NSNumber class]]) totalDown = [down count];
                    self.netVotes[i] = @(totalUp - totalDown);
                }
                else self.netVotes[i] = @0;
            }
        }
        [self.gridView reloadData];
    }];
     */
    //[self.gridView reloadData];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageModule;
}
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.gridView reloadData];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.gridSize*self.gridSize;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    long row = indexPath.row;
    //BOOL isAdmin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Rank"] isEqual:@6];
    PGGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    if(![self.gridData isEqual:[NSNull null]]){
        NSNumber *data = [self.gridData objectAtIndex:indexPath.row];
        /*
        if([data isEqualToNumber:@(-1)] && !isAdmin)
        {
            cell.hidden = YES;
            return cell;
        }
        else
        {
            [cell setHidden:NO];
        }
         */
        //BOOL star = [self.mapInterface getStarFilterValue] <= [(NSNumber *) self.netVotes[indexPath.row] integerValue];
        
        if(data.intValue != 0 && !cell.hidden){
            if(data.intValue == 1 && [self.mapInterface getViewFlag] & KeyView){
                [cell addImage:@"key"];
            }else if(data.intValue == 2 && [self.mapInterface getViewFlag] & CrownView){
                [cell addImage:@"king"];
            }else if(data.intValue == 3 && [self.mapInterface getViewFlag] & MoneyView){
                [cell addImage:@"money"];
            }
            if([self.mapInterface getCurrentCell] == indexPath.row && [self.mapInterface getStatusMode] == VoteMode) [cell setBackgroundColor:[UIColor yellowColor]];
            else [cell setBackgroundColor:[UIColor clearColor]];
            [cell setTintColor:[self.mapInterface getTintColor]];
        }
    }
    if(self.gridNotHidden){
        cell.layer.borderWidth = 1/self.contentWindow.zoomScale + 0.1;
        //if(![self.gridData isEqual:[NSNull null]] && ![self.gridData isKindOfClass:[NSNumber class]] && [[self.gridData objectAtIndex:indexPath.row] intValue] == -1 && isAdmin) cell.layer.borderColor = [UIColor redColor].CGColor;
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
    
    return CGSizeMake(self.frame.size.width/self.gridSize, (self.frame.size.height)/self.gridSize);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    int prevCellLoc = [self.mapInterface getCurrentCell];
    
    if([self.gridData isEqual:[NSNull null]]) return;
    
    [self.mapInterface updateCurrentCell:@(indexPath.row)];
    NSLog(@"SELECTED CELL : %ld", (long) indexPath.row);
    //CURRENT CELL INIT TO -1
    
    //Dehighlight last cell and highlight current cell
    if([self.mapInterface getStatusMode] != EditMode){
        if(prevCellLoc >= 0){
            UICollectionViewCell *prevCell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:prevCellLoc inSection:0]];
            prevCell.layer.borderWidth = 0;
            prevCell.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
        UICollectionViewCell *currentCell = [collectionView cellForItemAtIndexPath:indexPath];
        currentCell.layer.borderWidth = 1/self.contentWindow.zoomScale + 0.1;
        currentCell.layer.borderColor = [UIColor lightGrayColor].CGColor;
        currentCell.backgroundColor = [UIColor clearColor];
        return;
    }
    
    
    NSInteger geoID = [self.mapInterface getGeoID];
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isAdmin = [[defaults objectForKey:@"Rank"]  isEqual: @6];
    
    NSString *path = [NSString stringWithFormat:@"activeGames/%@/gridValues/%@", [self.mapInterface getGameName], [self.mapInterface getMapName]];
    //If isAdmin and we are removing cells. Remove cells by setting gData = -1
    if(isAdmin && [self.mapInterface getCellEditMode])
    {
        [[dBref child:path] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
            NSMutableArray *gVals = (NSMutableArray *) currentData.value;
            
            if([gVals isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
            
            if(prevCellLoc == -1)[gVals replaceObjectAtIndex:indexPath.row withObject:@(-1)];
            else
            {
                for(int i = prevCellLoc; i <= indexPath.row; i++){
                    [gVals replaceObjectAtIndex:i withObject:@(-1)];
                }
                [self.mapInterface updateCurrentCell:@(-1)];
            }
            currentData.value = gVals;
            return [FIRTransactionResult successWithValue:currentData];
        }];
        return;
    }
    //If isAdmin and we are not removing cell or placing icon, set cell to @0 (reset)
    if(isAdmin && geoID ==0 && ![self.mapInterface getCellEditMode])
    {
        [[dBref child:path] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
            NSMutableArray *gVals = (NSMutableArray *) currentData.value;
            
            if(gVals == NULL || [gVals isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
            
            [gVals replaceObjectAtIndex:indexPath.row withObject:@0];
            currentData.value = gVals;
            return[FIRTransactionResult successWithValue:currentData];
        }];
        return;
    }
    //User is attempting edit
    [[[dBref child:@"userList"] child:[defaults objectForKey:@"Username"]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSNumber *edits = snapshot.value[@"edits"];
        //Does user have privileg to edit and is the spot editable overide if admin
        if((![edits isEqualToNumber:@0] && [self.gridData[indexPath.row] isEqualToNumber:@0]) || isAdmin)
        {
            edits = isAdmin ? edits : @(edits.integerValue - 1);
            NSString *path = [NSString stringWithFormat:@"activeGames/%@/gridValues/%@", [self.mapInterface getGameName], [self.mapInterface getMapName]];
            
            [[dBref child:path] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
                
                NSMutableArray *gVals = (NSMutableArray *) currentData.value;
                if([gVals isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
                
                NSNumber *currentVal = gVals[indexPath.row];
                if(currentVal.integerValue == 0)[gVals replaceObjectAtIndex:indexPath.row withObject:@(geoID)];
                
                else if(isAdmin)
                {
                    if(currentVal.integerValue == geoID)[gVals replaceObjectAtIndex:indexPath.row withObject:@(0)];
                    else [gVals replaceObjectAtIndex:indexPath.row withObject:@(geoID)];
                }
                currentData.value = gVals;
                
                return [FIRTransactionResult successWithValue:currentData];
                
            } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
                //Add user to upvotes. Create if it doesnt exist
                if(committed)
                {
                    NSString *cell = [NSString stringWithFormat:@"cell%ld", (long)indexPath.row];
                    NSString *pathUpvote = [NSString stringWithFormat:@"activeGames/%@/gridVotes/%@/%@/upvote", [self.mapInterface getGameName], [self.mapInterface getMapName],cell];
                    NSString *pathDownvote = [NSString stringWithFormat:@"activeGames/%@/gridVotes/%@/%@/downvote", [self.mapInterface getGameName], [self.mapInterface getMapName],cell];
                    
                    //Since this cell doesn't have icon we know that there is no vote data so we set
                    if(isAdmin) [[dBref child:pathUpvote] setValue:@[@0] ];
                    else [[dBref child:pathUpvote] setValue:@[[defaults objectForKey:@"Username"]]];
                    [[dBref child:pathDownvote] setValue:@[@0]];
                    
                    NSString *editPath = [NSString stringWithFormat:@"userList/%@/edits", [defaults objectForKey:@"Username"]];
                    [[dBref child:editPath] setValue:edits];
                    
                    self.detailCharacterCount.hidden = NO;
                    self.detailsBar.hidden = NO;
                    [self.mapInterface updateStatusBarForEdit];
                    
                    [self.detailsBar becomeFirstResponder];
                    
                    [self.gridView reloadData];
                }
            }];
            
        }
    }];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //FIRST
    [self.mapInterface.navigationItem setHidesBackButton:YES];
    self.mapInterface.navigationItem.rightBarButtonItem.enabled = NO;
    textField.hidden = NO;
    self.detailCharacterCount.hidden = NO;
    self.detailCharacterCount.text = @"Characters left 75";
    textField.text = @"";
    self.details = [@"" mutableCopy];
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //THIRD
    [textField resignFirstResponder];
    textField.hidden = YES;
    self.detailCharacterCount.hidden = YES;
    textField.text = @"";
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //LAST
    [self.mapInterface.navigationItem setHidesBackButton:NO];
    self.mapInterface.navigationItem.rightBarButtonItem.enabled = YES;
    
    NSString *userName = [[[NSUserDefaults standardUserDefaults]objectForKey:@"Username"] stringByAppendingString:@":"];
    
    self.details =[NSMutableString  stringWithString:textField.text];
    self.details = [NSMutableString stringWithFormat:@"%@%@",userName,self.details];
    
    textField.text = @"";
    [textField resignFirstResponder];
    textField.hidden = YES;
    self.detailCharacterCount.hidden = YES;
    
    [self.gridView becomeFirstResponder];
    
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *path = [NSString stringWithFormat:@"activeGames/%@/gridDetails/%@/cell%d",[self.mapInterface getGameName], [self.mapInterface getMapName], [self.mapInterface getCurrentCell]];
    [[dBref child:path] setValue:self.details];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //SECOND
    NSCharacterSet *detailSet = [NSCharacterSet characterSetWithCharactersInString:@" .,+-()abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"];
    if([string rangeOfCharacterFromSet:[detailSet invertedSet]].location != NSNotFound) return NO;
    if(range.length + range.location > textField.text.length) return NO;
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength <= 75){
        self.detailCharacterCount.text = [NSString stringWithFormat:@"Characters left: %u", 75 - newLength];
        return YES;
    }else{
        return NO;
    }
}

@end
