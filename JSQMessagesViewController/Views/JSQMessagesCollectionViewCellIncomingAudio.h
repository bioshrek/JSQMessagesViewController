//
//  JSQAudioMessagesCollectionViewCell.h
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellIncoming.h"

@interface JSQMessagesCollectionViewCellIncomingAudio : JSQMessagesCollectionViewCellIncoming

@property (weak, nonatomic, readonly) UIImageView *animationImageView;
@property (weak, nonatomic, readonly) NSLayoutConstraint *audioAnimationImageViewHeadingContraint;  // 20
@property (weak, nonatomic, readonly) NSLayoutConstraint *audioAnimationImageViewWidthContraint;  // 20
@property (weak, nonatomic, readonly) NSLayoutConstraint *audioAnimationImageViewHeightConstraint;  // 20

@property (weak, nonatomic, readonly) UILabel *durationLabel;
@property (weak, nonatomic, readonly) NSLayoutConstraint *durationLeftRightSpacingContraint;  // 8
@property (weak, nonatomic, readonly) NSLayoutConstraint *durationLabelWidthContraint;  // 54

@property (weak, nonatomic, readonly) UIImageView *playMarkImageView;


@end
