//
//  PGGamePageViewController.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-14.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGGamePageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(id)initWith:(NSString *)gameName At:(NSString *)gamePath;

@end
