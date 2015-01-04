//
//  SKMediaPlaceholderView.h
//  JSQMessages
//
//  Created by shrek wang on 12/23/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MRProgress.h"

#import "JSQMediaView.h"

#import "MAKVONotificationCenter.h"

@interface SKMediaView : JSQMediaView

@property (nonatomic, weak, readonly) UIImageView *backgroundImageView;
@property (nonatomic, weak, readonly) UIView *mediaTextInfoHolderView;
@property (nonatomic, weak, readonly) UILabel *mediaNameLabel;
@property (nonatomic, weak, readonly) UILabel *mediaSizeLabel;

@property (weak, nonatomic, readonly) UIView *progressHolderView;
@property (weak, nonatomic, readonly) NSLayoutConstraint *progressHolderViewCenterYConstraint;
@property (nonatomic, weak, readonly) MRCircularProgressView *circularProgressView;
@property (weak, nonatomic, readonly) NSLayoutConstraint *circularProgressViewCenterXConstraint;
@property (weak, nonatomic, readonly) UILabel *progressLabel;
@property (weak, nonatomic, readonly) NSLayoutConstraint *progressLabelCenterXConstraint;

@property (nonatomic, weak, readonly) UIButton *mediaIconButton;
@property (weak, nonatomic, readonly) NSLayoutConstraint *mediaIconButtonCenterYConstraint;

@end
