//
//  PGHomeViewController.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-04.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGHomeViewController : UIViewController <UIScrollViewDelegate, UISearchBarDelegate>

-(void)cellPicked:(id)sender;
-(void)featureGameTap: (UITapGestureRecognizer *) sender;

@end
