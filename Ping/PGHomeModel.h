//
//  PGHomeModel.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGHomeModel : NSObject

-(void)setSearch:(NSString *)text;
-(void)querySearchResults;
-(void)retroCheck;

-(NSArray *)getSearchTitles;
-(NSArray *)getSearchDest;

@end
