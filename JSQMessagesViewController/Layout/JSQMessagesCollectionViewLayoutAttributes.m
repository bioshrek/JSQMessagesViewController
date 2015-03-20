//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesCollectionViewLayoutAttributes.h"


@interface JSQMessagesCollectionViewLayoutAttributes ()

- (CGSize)jsq_correctedAvatarSizeFromSize:(CGSize)size;

- (CGFloat)jsq_correctedLabelHeightForHeight:(CGFloat)height;

@end


@implementation JSQMessagesCollectionViewLayoutAttributes

#pragma mark - Getters

- (NSMutableDictionary *)customAttributes
{
    if (!_customAttributes) {
        _customAttributes = [[NSMutableDictionary alloc] init];
    }
    return _customAttributes;
}

#pragma mark - Setters

- (void)setAvatarViewSize:(CGSize)avatarViewSize
{
    NSParameterAssert(avatarViewSize.width >= 0.0f && avatarViewSize.height >= 0.0f);
    _avatarViewSize = [self jsq_correctedAvatarSizeFromSize:avatarViewSize];
}

- (void)setCellTopLabelHeight:(CGFloat)cellTopLabelHeight
{
    NSParameterAssert(cellTopLabelHeight >= 0.0f);
    _cellTopLabelHeight = [self jsq_correctedLabelHeightForHeight:cellTopLabelHeight];
}

- (void)setMessageBubbleTopLabelHeight:(CGFloat)messageBubbleTopLabelHeight
{
    NSParameterAssert(messageBubbleTopLabelHeight >= 0.0f);
    _messageBubbleTopLabelHeight = [self jsq_correctedLabelHeightForHeight:messageBubbleTopLabelHeight];
}

- (void)setCellBottomLabelHeight:(CGFloat)cellBottomLabelHeight
{
    NSParameterAssert(cellBottomLabelHeight >= 0.0f);
    _cellBottomLabelHeight = [self jsq_correctedLabelHeightForHeight:cellBottomLabelHeight];
}

#pragma mark - Utilities

- (CGSize)jsq_correctedAvatarSizeFromSize:(CGSize)size
{
    //  cap avatar sizes to a minimum of (1.0, 1.0)
    //  layout constraints sometimes throw warnings when they equal 0.0
    //  prevent this with a size that is too small to notice
    CGFloat correctedWidth = MAX(ceilf(size.width), 1.0f);
    CGFloat correctedHeight = MAX(ceilf(size.height), 1.0f);
    return CGSizeMake(correctedWidth, correctedHeight);
}

- (CGFloat)jsq_correctedLabelHeightForHeight:(CGFloat)height
{
    //  cap label heights to a minimum of 1.0
    //  layout constraints sometimes throw warnings when they equal 0.0
    //  prevent this with a size that is too small to notice
    return MAX(ceilf(height), 1.0f);
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (self.representedElementCategory == UICollectionElementCategoryCell) {
        JSQMessagesCollectionViewLayoutAttributes *layoutAttributes = (JSQMessagesCollectionViewLayoutAttributes *)object;
        
        if (!CGSizeEqualToSize(layoutAttributes.avatarViewSize, self.avatarViewSize)
            || (int)layoutAttributes.cellTopLabelHeight != (int)self.cellTopLabelHeight
            || (int)layoutAttributes.messageBubbleTopLabelHeight != (int)self.messageBubbleTopLabelHeight
            || (int)layoutAttributes.cellBottomLabelHeight != (int)self.cellBottomLabelHeight) {
            return NO;
        }
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    return [self.indexPath hash];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQMessagesCollectionViewLayoutAttributes *copy = [super copyWithZone:zone];
    
    if (copy.representedElementCategory != UICollectionElementCategoryCell) {
        return copy;
    }

    copy.avatarViewSize = self.avatarViewSize;
    copy.cellTopLabelHeight = self.cellTopLabelHeight;
    copy.messageBubbleTopLabelHeight = self.messageBubbleTopLabelHeight;
    copy.cellBottomLabelHeight = self.cellBottomLabelHeight;
    
    return copy;
}

@end
