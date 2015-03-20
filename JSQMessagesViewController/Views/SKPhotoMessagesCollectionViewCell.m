//
//  SKMediaMessagesCollectionViewCell.m
//  JSQMessages
//
//  Created by shrek wang on 3/5/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKPhotoMessagesCollectionViewCell.h"

@interface SKPhotoMessagesCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SKPhotoMessagesCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    _imageView = nil;
}

#pragma mark - setter

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.imageView.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.imageView.highlighted = selected;
}

#pragma mark - Collection view cell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    // nothing to do
}

- (void)applyMessageContentData:(id<SKMessageContent>)messageContent
{
    [super applyMessageContentData:messageContent];
    
    // lazy load image, so client code should set image through imageView.
}

#pragma mark - utils

- (void)sk_updateConstraint:(NSLayoutConstraint *)constraint withConstant:(CGFloat)constant
{
    if (constraint.constant == constant) {
        return;
    }
    
    constraint.constant = constant;
}

@end
