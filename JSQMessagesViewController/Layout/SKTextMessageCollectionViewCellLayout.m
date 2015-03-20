//
//  SKTextMessageCollectionViewCellLayout.m
//  JSQMessages
//
//  Created by shrek wang on 3/20/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKTextMessageCollectionViewCellLayout.h"

#import "UIImage+JSQMessages.h"
#import "SKTextMessageData.h"

// constants: layout attribute keys

NSString * const SKMessageLayoutAttributeTextViewFrameInsetsKey = @"SKMessageLayoutAttributeTextViewFrameInsetsKey";
NSString * const SKMessageLayoutAttributeTextViewContainerInsetsKey = @"SKMessageLayoutAttributeTextViewContainerInsetsKey";


@interface SKTextMessageCollectionViewCellLayout ()

@property (assign, nonatomic, readonly) NSUInteger bubbleImageAssetWidth;

@end

@implementation SKTextMessageCollectionViewCellLayout

- (id)init
{
    if (self = [super init]) {
        
        _bubbleImageAssetWidth = [UIImage jsq_bubbleCompactImage].size.width;
        
        _messageBubbleTextViewFrameInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 6.0f);
        _messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(7.0f, 14.0f, 7.0f, 14.0f);

    }
    return self;
}

- (CGSize)messageBubbleSizeForMessageContent:(id)messageContent maxWidth:(CGFloat)maxWidth
{
    NSParameterAssert([messageContent conformsToProtocol:@protocol(SKTextMessageData)]);
    
    id<SKTextMessageData> textMessage = (id<SKTextMessageData>)messageContent;
    
    //  from the cell xibs, there is a 2 point space between avatar and bubble
    CGFloat spacingBetweenAvatarAndBubble = 2.0f;
    CGFloat horizontalContainerInsets = self.messageBubbleTextViewTextContainerInsets.left + self.messageBubbleTextViewTextContainerInsets.right;
    CGFloat horizontalFrameInsets = self.messageBubbleTextViewFrameInsets.left + self.messageBubbleTextViewFrameInsets.right;
    
    CGFloat horizontalInsetsTotal = horizontalContainerInsets + horizontalFrameInsets + spacingBetweenAvatarAndBubble;
    CGFloat maximumTextWidth = maxWidth - horizontalInsetsTotal;
    
    CGRect stringRect = [[textMessage attributedText] boundingRectWithSize:CGSizeMake(maximumTextWidth, CGFLOAT_MAX)
                                                                   options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                                   context:nil];
    CGSize stringSize = CGRectIntegral(stringRect).size;
    
    CGFloat verticalContainerInsets = self.messageBubbleTextViewTextContainerInsets.top + self.messageBubbleTextViewTextContainerInsets.bottom;
    CGFloat verticalFrameInsets = self.messageBubbleTextViewFrameInsets.top + self.messageBubbleTextViewFrameInsets.bottom;
    
    //  add extra 2 points of space, because `boundingRectWithSize:` is slightly off
    //  not sure why. magix. (shrug) if you know, submit a PR
    CGFloat verticalInsets = verticalContainerInsets + verticalFrameInsets + 2.0f;
    
    //  same as above, an extra 2 points of magix
    CGFloat finalWidth = MAX(stringSize.width + horizontalInsetsTotal, self.bubbleImageAssetWidth) + 2.0f;
    
    CGSize finalSize = CGSizeMake(finalWidth, stringSize.height + verticalInsets);
    
    return finalSize;
}

- (void)configCustomLayoutAttributes:(JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes
{
    [layoutAttributes.customAttributes setObject:[NSValue valueWithUIEdgeInsets:self.messageBubbleTextViewFrameInsets]
                                          forKey:SKMessageLayoutAttributeTextViewFrameInsetsKey];
    [layoutAttributes.customAttributes setObject:[NSValue valueWithUIEdgeInsets:self.messageBubbleTextViewTextContainerInsets]
                                          forKey:SKMessageLayoutAttributeTextViewContainerInsetsKey];
}

@end
