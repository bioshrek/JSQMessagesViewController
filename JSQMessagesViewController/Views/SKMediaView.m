//
//  SKMediaView.m
//  JSQMessages
//
//  Created by shrek wang on 12/27/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMediaView.h"

#import "JSQMessagesMediaViewBubbleImageMasker.h"

@implementation SKMediaView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commentInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self commentInit];
}

- (void)commentInit
{
    [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:self isOutgoing:self.appliesMediaViewMaskAsOutgoing];
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    if (_appliesMediaViewMaskAsOutgoing != appliesMediaViewMaskAsOutgoing) {
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:self isOutgoing:appliesMediaViewMaskAsOutgoing];
    }
    _appliesMediaViewMaskAsOutgoing = appliesMediaViewMaskAsOutgoing;
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
