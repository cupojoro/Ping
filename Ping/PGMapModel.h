//
//  PGMapModel.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PGMapViewController.h"

@interface PGMapModel : NSObject

-(id)initWithController:(PGMapViewController *)vc andMapPath:(NSString *)path;

-(void)createNode;
-(void)addUserToVoters:(BOOL)upvoteFlag atIndex:(int)index forTotal:(int)amount;
-(void)setTagLocationX:(float)x Y:(float)y atIndex:(int)index withType:(int)type;
-(void)setCommentAtIndex:(int)index withText:(NSString *)comment;
-(void)removeNodeAtIndex:(int)index;
-(void)commentAtIndex:(int)index;
-(void)iconsForMap;
-(void)returnCheckout;
@end
