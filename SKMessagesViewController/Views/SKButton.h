//
//  SKButton.h
//  SKButtons
//
//  Created by shrek wang on 12/22/14.
//  Copyright (c) 2014 shrek wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKButton : UIButton

@property (nonatomic, assign) CGFloat borderWidth;

@property (nonatomic, copy) UIColor *borderColor;

@property (nonatomic, assign) CGFloat cornerRadius;

- (void)becomeRoundIfPossible;

@end
