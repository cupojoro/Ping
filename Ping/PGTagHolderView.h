//
//  PGTagHolderView.h
//  Ping
//
//  Created by Joseph Ross on 2017-02-18.
//  Copyright © 2017 Joseph Ross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGTagHolderView : UIImageView

-(id)initWithImage:(NSString *)imageName andFrame:(CGRect) frame;
-(id)initWithNoImageAndFrame:(CGRect)frame;
-(void)updateImage:(NSString *)imageName;
@end
