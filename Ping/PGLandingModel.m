//
//  PGLandingModel.m
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import "PGLandingModel.h"

#import "Firebase.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface PGLandingModel ()

@property (nonatomic) BOOL firstLogin;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSNumber *rank;
@property (nonatomic, strong) PGLandingViewController *controller;

@end
@implementation PGLandingModel

-(id)init:(PGLandingViewController *)creator
{
    self = [super init];
    
    self.firstLogin = NO;
    self.controller = creator;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Joe(1)" forKey:@"Username"]; //CHANGE THIS LINE TO ACCES OTHER ACCOUNTS
    [defaults setObject:@0 forKey:@"Rank"]; //NEED THIS WHEN CHANGIND DEVICES
    self.userName = [defaults objectForKey:@"Username"];
    //self.userName = nil;
    if(self.userName == nil){
        self.firstLogin = YES;
    }else self.rank = [defaults objectForKey:@"Rank"];
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        NSLog(@"ANON SIGNIN");
        if(!self.firstLogin) [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(login) userInfo:nil repeats:NO];
    }];
    return self;
}

-(BOOL)getFirstLogin
{
    return self.firstLogin;
}

-(void)login
{
    if(!self.firstLogin){
        FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
        //USERLIST IS JUST NAMES. USER:%@ is actual user entry.
        NSString *userInfoPath = [NSString stringWithFormat:@"user:%@", self.userName];
        //DATE STRING FOR LOGIN
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:date];
        [[dBref child:userInfoPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSString *lastLogin = (NSString *) snapshot.value[@"login"];
            NSDate *lastLoginDate = [dateFormatter dateFromString:lastLogin];
            NSTimeInterval timeBetween = [date timeIntervalSinceDate:lastLoginDate];
            NSInteger hours = timeBetween / 3600;
            NSNumber *dBRank = (NSNumber *) snapshot.value[@"rank"];
            BOOL rankChange = ![dBRank isEqualToNumber:self.rank];
            //IF MORE THAN 12 HOURS OR RANK WAS MANUALLY CHANGED UPDATE USER DATA
            if(hours > 12 || rankChange){
                NSLog(@"12 HOUR RESET");
                NSString *path = [NSString stringWithFormat:@"user:%@/login", self.userName];
                [[dBref child:path] setValue:dateString];
                [[NSUserDefaults standardUserDefaults] setValue:dBRank forKey:@"Rank"];
                self.rank = dBRank;
                NSNumber *countReset = @10000;
                NSNumber *editReset = @10000;
                switch (dBRank.integerValue)
                {
                    case 0:
                        countReset = @5;
                        editReset = @0;
                        break;
                    case 1:
                        countReset = @10;
                        editReset = @0;
                        break;
                    case 2:
                        countReset = @15;
                        editReset = @1;
                        break;
                    case 3:
                        countReset = @20;
                        editReset = @5;
                        break;
                    case 4:
                        countReset = @30;
                        editReset = @10;
                        break;
                    case 5:
                        countReset = @10000;
                        editReset = @10000;
                        break;
                    case 6:
                        countReset = @10000;
                        editReset = @10000;
                        break;
                    default:
                        countReset = @0;
                        editReset = @0;
                        break;
                }
                [[[dBref child:userInfoPath] child:@"soft"] setValue:countReset];
                [[[dBref child:userInfoPath] child:@"edits"] setValue:editReset];
            }
            
            [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                
                NSLog(@"USERNAME : %@", self.userName);
                NSLog(@"RANK : %@", self.rank);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PGLoginComplete" object:nil];
            }];
        }];
        
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:@"Attempting to login with defaults not set"];
    }
}

-(void)validateUsername:(NSString *)name
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.userName = name;
        if(self.userName.length < 1 || self.userName == nil) return;
        NSString *contains = [self.userName lowercaseString];
        if([contains containsString:@"admin"])
        {
            dispatch_async( dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:@"Username cannot contain any form of the word 'ADMIN'"];
            });
            return;
        }
        NSString *officialUsername = [self.userName stringByAppendingString:@"(1)"];
        __block NSNumber *updatedIndex;
        FIRDatabaseReference *dBref = [[FIRDatabase database] reference];
        [[dBref child:@"userList"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSArray *userList = (NSArray *) snapshot.value;
            if([userList indexOfObject:officialUsername] != NSNotFound){
                //USER EXISTS, GET USERINFO, FIND CURRENT INDEX AND ITERATE
                NSString *userInfoPath = [NSString stringWithFormat:@"user:%@", officialUsername];
                [[dBref child:userInfoPath] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
                    NSMutableDictionary *userInfo = (NSMutableDictionary *) currentData.value;
                    if([userInfo isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
                    NSNumber *currentIndex = (NSNumber *) userInfo[@"currentIndex"];
                    updatedIndex = [NSNumber numberWithInteger:[currentIndex integerValue] + 1];
                    [userInfo setObject:updatedIndex forKey:@"currentIndex"];
                    currentData.value = userInfo;
                    return [FIRTransactionResult successWithValue:currentData];
                } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
                    if(error)
                    {
                        dispatch_async( dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:@"User entry error on index."];
                        });
                    }
                    //WE MAKE SURE THAT THE CURRENT INDEX IS UPDATED BEFORE WE COMMMIT TO THE USERNAME SUFFIX
                    if(committed)
                    {
                        NSMutableString *finalName = [[NSMutableString alloc] initWithString:name];
                        [finalName appendString:[NSString stringWithFormat:@"(%@)", [updatedIndex stringValue]]];
                        [[NSUserDefaults standardUserDefaults] setObject:finalName forKey:@"Username"];
                        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"Rank"];
                        NSDate *date = [NSDate date];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSString *dateString = [dateFormatter stringFromDate:date];
                        //SINCE WE HAVE CONFIRMED SUFFIX WE NOW CAN ADD TO USERLIST
                        [[dBref child:@"userList"] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
                            NSMutableArray *userNames = (NSMutableArray *) currentData.value;
                            if([userNames isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
                            [userNames addObject:finalName];
                            currentData.value = userNames;
                            return [FIRTransactionResult successWithValue:currentData];
                        } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
                            if(error)
                            {
                                dispatch_async( dispatch_get_main_queue(), ^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:@"User entry error on adding to user list"];
                                });
                            }
                            //IF NAME SUCCESFULLY ADDED TO USERLIST WE CAN NOW CREATE THE USERINFO ENTRY
                            if(committed)
                            {
                                NSString *userEntry = [NSString stringWithFormat:@"user:%@", finalName];
                                [[dBref child:userEntry] setValue:@{@"rank":@0, @"hard":@5, @"soft":@5,@"edits":@0,@"login":dateString}];
                                //POST NOTIFICATION
                                self.firstLogin = NO;
                                self.userName = finalName;
                                self.rank = @0;
                                dispatch_async( dispatch_get_main_queue(), ^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PGUserEntryCreated" object:nil];
                                });
                            }
                        }];
                    }
                }];
            }else{
                //NO USER
                [[NSUserDefaults standardUserDefaults] setObject:officialUsername forKey:@"Username"];
                [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"Rank"];
                NSDate *date = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *dateString = [dateFormatter stringFromDate:date];
                //ADD TO USERLIST
                [[dBref child:@"userList"] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
                    NSMutableArray *userNames = (NSMutableArray *) currentData.value;
                    if([userNames isEqual:[NSNull null]]) return [FIRTransactionResult successWithValue:currentData];
                    [userNames addObject:officialUsername];
                    currentData.value = userNames;
                    return [FIRTransactionResult successWithValue:currentData];
                } andCompletionBlock:^(NSError * _Nullable error, BOOL committed, FIRDataSnapshot * _Nullable snapshot) {
                    if(error)
                    {
                        dispatch_async( dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGError" object:@"User entry error on adding to userlist"];
                        });
                    }
                    //NAME ADDED TO USERLIST, NOW CREATE ENTRY
                    if(committed)
                    {
                        NSString *userEnry = [NSString stringWithFormat:@"user:%@", officialUsername];
                        [[dBref child:userEnry] setValue:@{@"rank":@0, @"hard":@5, @"soft":@5,@"edits":@0,@"login":dateString, @"currentIndex":@1}];
                        //POST NOTIFICATION
                        self.firstLogin = NO;
                        self.userName = officialUsername;
                        self.rank = @0;
                        dispatch_async( dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"PGUserEntryCreated" object:nil];
                        });
                    }
                }];
            }
        }];
    });
}
@end
