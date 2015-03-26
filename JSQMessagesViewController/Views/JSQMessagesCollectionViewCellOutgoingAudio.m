//
//  JSQMessagesCollectionViewCellOutgoingAudio.m
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellOutgoingAudio.h"

#import "UIImageView+JSQMessages.h"

// constants: layout constants

CGFloat const kOutgoingAudioDurationLeftRightSpacing = 8.0f;
CGFloat const kOutgoingAudioDurationLabelWidth = 54.0f;

CGFloat const kOutgoingAudioAnimationViewHeading = 20.0f;
CGFloat const kOutgoingAudioAnimationViewTrailing = 20.0f;
CGFloat const kOutgoingAudioAnimationViewTop = 10.0f;
CGFloat const kOutgoingAudioAnimationViewBottom = 10.0f;
CGFloat const kOutgoingAudioAnimationViewWidth = 20.0f;
CGFloat const kOutgoingAudioAnimationViewHeight = 20.0f;

NSTimeInterval kOutgoingAudioMaxVisibleDuration = 5 * 60.0f;  // 5 minutes
NSTimeInterval kOutgoingAudioMinVisibleDuration = 1.0f;  // 1 second


@interface JSQMessagesCollectionViewCellOutgoingAudio ()

@property (weak, nonatomic) IBOutlet UIImageView *animationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioAnimationImageViewHeadingContraint;  // 20
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioAnimationImageViewWidthContraint;  // 44
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioAnimationImageViewHeightConstraint;  // 44

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLeftRightSpacingContraint;  // 54
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelWidthContraint;  // 8

@property (weak, nonatomic) IBOutlet UIImageView *playMarkImageView;

@end

@implementation JSQMessagesCollectionViewCellOutgoingAudio

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.animationImageView configAsAudioDurationAnimationWithColor:[UIColor blackColor] outgoing:YES];
}

// override
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.durationLabel.text = nil;
    self.durationLabel.hidden = NO;
    self.animationImageView.hidden = NO;
    [self.animationImageView stopAnimating];
    self.playMarkImageView.hidden = NO;
}

@end
