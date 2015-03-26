//
//  JSQMessagesCollectionViewCellOutgoingAudio.h
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellOutgoing.h"

// constants: layout constants

extern CGFloat const kOutgoingAudioDurationLeftRightSpacing;
extern CGFloat const kOutgoingAudioDurationLabelWidth;

extern CGFloat const kOutgoingAudioAnimationViewHeading;
extern CGFloat const kOutgoingAudioAnimationViewTrailing;
extern CGFloat const kOutgoingAudioAnimationViewTop;
extern CGFloat const kOutgoingAudioAnimationViewBottom;
extern CGFloat const kOutgoingAudioAnimationViewWidth;
extern CGFloat const kOutgoingAudioAnimationViewHeight;

extern NSTimeInterval kOutgoingAudioMaxVisibleDuration;
extern NSTimeInterval kOutgoingAudioMinVisibleDuration;


@interface JSQMessagesCollectionViewCellOutgoingAudio : JSQMessagesCollectionViewCellOutgoing

@property (weak, nonatomic, readonly) UIImageView *animationImageView;
@property (weak, nonatomic, readonly) NSLayoutConstraint *audioAnimationImageViewHeadingContraint;  // 20
@property (weak, nonatomic, readonly) NSLayoutConstraint *audioAnimationImageViewWidthContraint;  // 44
@property (weak, nonatomic, readonly) NSLayoutConstraint *audioAnimationImageViewHeightConstraint;  // 44

@property (weak, nonatomic, readonly) UILabel *durationLabel;
@property (weak, nonatomic, readonly) NSLayoutConstraint *durationLeftRightSpacingContraint;  // 8
@property (weak, nonatomic, readonly) NSLayoutConstraint *durationLabelWidthContraint;  // 54

@property (weak, nonatomic, readonly) UIImageView *playMarkImageView;

@end
