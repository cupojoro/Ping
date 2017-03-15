//
//  PGHomeModel.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGHomeModel.h"

#import "Firebase.h"

@interface PGHomeModel ()


@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSMutableArray *gameTitles;
@property (nonatomic, strong) NSMutableArray *gameLocations;

@property (nonatomic) int gameIndex;
@property (nonatomic) BOOL clearFlag;

@end

@implementation PGHomeModel

-(id)init
{
    self = [super init];
    self.clearFlag = NO;
    return self;
}


#pragma  mark Getters

-(NSArray *)getSearchTitles
{
    return self.gameTitles;
}

-(NSArray *)getSearchDest
{
    return self.gameLocations;
}

#pragma mark Setters

-(void)setSearch:(NSString *)text
{
    [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"LastSearch"];
    self.searchText = text;
}

#pragma mark Query

-(void)retroCheck
{
    self.searchText = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastSearch"];
    if([self.searchText length] != 0) [[NSNotificationCenter defaultCenter] postNotificationName:@"PGRetroSearch" object:nil];
}

-(void) clearResults
{
    self.gameIndex = 0;
    self.gameTitles = [[NSMutableArray alloc] init];
    self.gameLocations = [[NSMutableArray alloc] init];
    self.clearFlag = YES;
}

-(void) addGameValue:(NSString *) title andDestination:(NSString *)destination
{
    [self.gameTitles addObject:title];
    [self.gameLocations addObject:destination];
    self.gameIndex++;
}

-(void) querySearchResults
{
    if(!self.clearFlag) [self clearResults];
    
    NSString *currentSearch = self.searchText;
    FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
    [[dBref child:@"gameList"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *children = (NSDictionary *) snapshot.value;
        [self queryChildren:children onTerm:currentSearch];
        self.clearFlag = NO;
        
        if([self.gameTitles count] == 0)
        {
            [self addGameValue:[NSString stringWithFormat:@"Could not find map data for : %@", self.searchText] andDestination:@""];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PGQueryComplete" object:nil];
    }];
}

-(void) queryChildren:(NSDictionary *)children onTerm:(NSString *)search
{
    if([children objectForKey:search])
    {
        //KEY EXISTS
        if([[children objectForKey:search] isKindOfClass:[NSString class]])
        {
            //EITHER THE DATA PATH OR A REWORD
            NSString *data = (NSString *) [children objectForKey:search];
            if([data containsString:@"gameData:"])
            {
                [self addGameValue:search andDestination:data];
            }
            else
            {
                NSString *updatedData = (NSString *) [children objectForKey:data];
                [self addGameValue:data andDestination:updatedData];
            }
        }
        else
        {
            //VAGUE SEARCH TERM ARRAY
            NSArray *rewords = (NSArray *) [children objectForKey:search];
            for(NSString *gameName in rewords)
            {
                [self queryChildren:children onTerm:gameName];
            }
        }
    }
}
@end
