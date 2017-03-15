//
//  PGAdminControlView.h
//  Ping
//
//  Created by Joseph Ross on 2017-01-29.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGAdminControlView : UIView
-(id)initWithGameName: (NSString *) game andMapName: (NSString *) name;
-(BOOL)getCellEditMode;
@end
