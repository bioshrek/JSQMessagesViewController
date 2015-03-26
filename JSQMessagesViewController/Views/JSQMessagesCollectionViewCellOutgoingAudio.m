//
//  JSQMessagesCollectionViewCellOutgoingAudio.m
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellOutgoingAudio.h"

// constants: layout constants

CGFloat const kOutgoingAudioDurationLeftRightSpacing = 8.0f;
CGFloat const kOutgoingAudioDurationLabelWidth = 54.0f;

CGFloat const kOutgoingAudioAnimationViewHeading = 20.0f;
CGFloat const kOutgoingAudioAnimationViewTrailing = 8.0f;
CGFloat const kOutgoingAudioAnimationViewTop = 8.0f;
CGFloat const kOutgoingAudioAnimationViewBottom = 8.0f;
CGFloat const kOutgoingAudioAnimationViewWidth = 44.0f;
CGFloat const kOutgoingAudioAnimationViewHeight = 44.0f;

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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
