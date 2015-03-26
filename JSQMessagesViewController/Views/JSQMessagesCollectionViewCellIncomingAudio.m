//
//  JSQAudioMessagesCollectionViewCell.m
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellIncomingAudio.h"

@interface JSQMessagesCollectionViewCellIncomingAudio ()

@property (weak, nonatomic) IBOutlet UIImageView *animationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioAnimationImageViewHeadingContraint;  // 20
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioAnimationImageViewWidthContraint;  // 44
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioAnimationImageViewHeightConstraint;  // 44

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLeftRightSpacingContraint;  // 8
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelWidthContraint;  // 54

@property (weak, nonatomic) IBOutlet UIImageView *playMarkImageView;



@end

@implementation JSQMessagesCollectionViewCellIncomingAudio

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.durationLabel.text = nil;
    self.durationLabel.hidden = NO;
    self.animationImageView.hidden = NO;
    self.playMarkImageView.hidden = NO;
}

// override
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.durationLabel.text = nil;
    self.durationLabel.hidden = NO;
    self.animationImageView.hidden = NO;
    self.playMarkImageView.hidden = NO;
}

#pragma mark - Actions

- (void)startPlaying
{
    [self.animationImageView startAnimating];
    self.playMarkImageView.hidden = YES;
}

- (void)stopPlaying
{
    [self.animationImageView stopAnimating];
}

@end
