//
//  PGMapModel.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGMapModel.h"

#import "Firebase.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PGMapModel ()

@property (nonatomic, strong) NSString *mapPath;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic) BOOL clean;
@property (nonatomic) int cleanIndex;
@end

@implementation PGMapModel

-(id)initWithController:(PGMapViewController *)vc andMapPath:(NSString *)path
{
    self = [super init];
    self.clean = NO;
    self.cleanIndex = -1;
    self.mapPath = path;
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
    if(self.userName == nil) [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:@"Map Model couldn't find user"];
    return self;
}

-(void)checkSlate
{
    if(self.clean) [self removeNodeAtIndex:self.cleanIndex];
}
-(void)createNode
{
    __block int index;
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[dBref child:self.mapPath] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableDictionary *mapData = (NSMutableDictionary *) currentData.value;
        if([mapData isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
        NSMutableArray *locations = (NSMutableArray *) [mapData objectForKey:@"tagLocations"];
        NSMutableArray *comments = (NSMutableArray *) [mapData objectForKey:@"tagComments"];
        NSMutableArray *votes = (NSMutableArray *) [mapData objectForKey:@"tagVotes"];
        NSNumber *checkout = (NSNumber *) [mapData objectForKey:@"checkout"];
        index = [locations count];
        [locations addObject:@{@"type":@0,@"x":@0,@"y":@0}];
        [comments addObject:@"Place holder"];
        [votes addObject:@{@"upvotes":@[@"admin"] , @"downvotes":@[@"admin"]}];
        [mapData setObject:locations forKey:@"tagLocations"];
        [mapData setObject:comments forKey:@"tagComments"];
        [mapData setObject:votes forKey:@"tagVotes"];
        [mapData setObject:@(1+[checkout intValue]) forKey:@"checkout"];
        currentData.value = mapData;
        return [FIRTransactionResult successWithValue:currentData];
        
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        if(error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:@"Couldn't create blank node for map data"];
        }
        if(committed)
        {
            self.clean = YES;
            self.cleanIndex = index;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGCleanNodeSuccess" object:@(index)];
        }
    }];
}

-(void)setCommentAtIndex:(int)index withText:(NSString *)comment
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[[dBref child:self.mapPath] child:@"tagComments"] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableArray *comments = (NSMutableArray *)currentData.value;
        if([comments isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
        if(comment != nil) [comments replaceObjectAtIndex:index withObject:comment];
        currentData.value = comments;
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        if(error)
        {
            [self checkSlate];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:@"Couldn't add comment"];
        }
        if(committed)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGTagCommentSuccess" object:nil];
        }
    }];
}
-(void)addUserToVoters:(BOOL)upvoteFlag atIndex:(int)index forTotal:(int)amount
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *voteGroup = upvoteFlag ? @"upvotes" : @"downvotes";
    NSString *voteCell = [NSString stringWithFormat:@"%@/tagVotes/%d/%@",self.mapPath,index,voteGroup];
    [[dBref child:voteCell] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSArray *userList = (NSArray *)snapshot.value;
        if(![userList containsObject:self.userName])
        {
            [[dBref child:voteCell] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
                NSMutableArray *userList = (NSMutableArray *) currentData.value;
                if([userList isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
                if([userList containsObject:@"admin"]) [userList removeAllObjects];
                for(int i = 0; i < amount; i++)
                {
                    [userList addObject:self.userName];
                }
                currentData.value = userList;
                return [FIRTransactionResult successWithValue:currentData];
                
            } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
                if(error)
                {
                    [self checkSlate];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:@"Couldn't add user to voter list"];
                }
                if(committed)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PGTagVoteSuccess" object:nil];
                }
            }];
        }
    }];
}
-(void)setTagLocationX:(float)x Y:(float)y atIndex:(int)index withType:(int)type
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[[dBref child:self.mapPath] child:@"tagLocations"] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableArray *tagLocationsDict = (NSMutableArray *) currentData.value;
        if([tagLocationsDict isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
        NSDictionary *cord = @{@"type":@(type),@"x":@(x),@"y":@(y)};
        [tagLocationsDict replaceObjectAtIndex:index withObject:cord];
        currentData.value = tagLocationsDict;
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        if(error)
        {
            [self checkSlate];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:error.localizedDescription];
        }
        if(committed)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGTagLocationSuccess" object:nil];
        }
    }];
}

-(void)removeNodeAtIndex:(int)index
{
    //If two removes happen simultaneously due to collission detection and topmost isnt removed first this will bug
    //Need to not track index rather track x,y percs and compare and find.
    __block bool stagingFlag = NO;
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[dBref child:self.mapPath] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableDictionary *mapData = (NSMutableDictionary *) currentData.value;
        if([mapData isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
        NSNumber *checkout = (NSNumber *) [mapData objectForKey:@"checkout"];
        if([checkout intValue] > 0)
        {
            stagingFlag = YES;
            return [FIRTransactionResult successWithValue:currentData];
        }
        NSMutableArray *locations = (NSMutableArray *) [mapData objectForKey:@"tagLocations"];
        NSMutableArray *comments = (NSMutableArray *) [mapData objectForKey:@"tagComments"];
        NSMutableArray *votes = (NSMutableArray *) [mapData objectForKey:@"tagVotes"];
        [locations removeObjectAtIndex:index];
        [comments removeObjectAtIndex:index];
        [votes removeObjectAtIndex:index];
        currentData.value = mapData;
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        if(error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
            [self removeNodeAtIndex:index];
        }
        if(committed)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGNodeRemovalSucces" object:@(index)];
        }
        if(stagingFlag)
        {
            [self removeNodeAtIndex:index];
        }
    }];
}

-(void)commentAtIndex:(int)index
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *path = [NSString stringWithFormat:@"%@/tagComments/%d", self.mapPath, index];
    [[dBref child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *testAgainst = @"Place holder";
        NSString *comment = (NSString *) snapshot.value;
        if([comment isEqualToString:testAgainst])[[NSNotificationCenter defaultCenter] postNotificationName:@"PGCommentRetreval" object:@""];
        else [[NSNotificationCenter defaultCenter] postNotificationName:@"PGCommentRetreval" object:comment];
    }];
}

-(void)iconsForMap
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    NSString *path = [NSString stringWithFormat:@"%@/icons",self.mapPath];
    [[dBref child:path] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSArray *icons = (NSArray *) snapshot.value;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PGIconListRetreval" object:icons];
    }];
}

-(void)returnCheckout
{
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[dBref child:self.mapPath] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableDictionary *mapData = (NSMutableDictionary *) currentData.value;
        if([mapData isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
        NSNumber *checkout = (NSNumber *) [mapData objectForKey:@"checkout"];
        [mapData setObject:@([checkout intValue] -1) forKey:@"checkout"];
        currentData.value = mapData;
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
        if(error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        if(committed)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGReturnedCheckout" object:nil];
        }
    }];
}

@end
