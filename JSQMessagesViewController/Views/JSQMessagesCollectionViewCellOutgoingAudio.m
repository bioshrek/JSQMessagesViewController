//
//  JSQMessagesCollectionViewCellOutgoingAudio.m
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellOutgoingAudio.h"

@interface JSQMessagesCollectionViewCellOutgoingAudio ()

@property (weak, nonatomic) IBOutlet UIImageView *animationImageView;

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
