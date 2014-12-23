//
//  SKBorderView.h
//  JSQMessages
//
//  Created by shrek wang on 12/23/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKBorderView : UIView

@property (nonatomic, copy) UIColor *topBorderColor;
@property (nonatomic, copy) UIColor *bottomBorderColor;
@property (nonatomic, copy) UIColor *leftBorderColor;
@property (nonatomic, copy) UIColor *rightBorderColor;

@property (nonatomic, assign) UIEdgeInsets borderLineWidths;

@end
