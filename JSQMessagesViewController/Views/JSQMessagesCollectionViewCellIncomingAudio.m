//
//  JSQAudioMessagesCollectionViewCell.m
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellIncomingAudio.h"

#import "UIImageView+JSQMessages.h"

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
    
    [self.animationImageView configAsAudioDurationAnimationWithColor:[UIColor whiteColor] outgoing:NO];
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
