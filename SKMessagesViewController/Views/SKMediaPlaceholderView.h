//
//  SKMediaPlaceholderView.h
//  JSQMessages
//
//  Created by shrek wang on 12/23/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MRProgress.h"

@interface SKMediaPlaceholderView : UIView

@property (nonatomic, weak, readonly) UIImageView *backgroundImageView;
@property (nonatomic, weak, readonly) UIView *mediaTextInfoHolderView;
@property (nonatomic, weak, readonly) UILabel *mediaNameLabel;
@property (nonatomic, weak, readonly) UILabel *mediaSizeLabel;

@property (nonatomic, weak, readonly) MRCircularProgressView *circularProgressView;

+ (instancetype)view;

@end
