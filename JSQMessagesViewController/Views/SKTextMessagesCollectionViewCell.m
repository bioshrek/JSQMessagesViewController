//
//  SKTextMessagesCollectionViewCell.m
//  JSQMessages
//
//  Created by shrek wang on 3/5/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKTextMessagesCollectionViewCell.h"

#import "SKTextMessageCollectionViewCellLayout.h"
#import "JSQMessagesCollectionViewLayoutAttributes.h"

#import "SKTextMessageData.h"

@interface SKTextMessagesCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *messageBubbleImageView;

@property (weak, nonatomic) IBOutlet JSQMessagesCellTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTopVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewAvatarHorizontalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewMarginHorizontalSpaceConstraint;


@property (assign, nonatomic) UIEdgeInsets textViewFrameInsets;

@end

@implementation SKTextMessagesCollectionViewCell

#pragma mark - life cycle

- (void)dealloc
{
    _textView = nil;
    _messageBubbleImageView = nil;
}

#pragma mark - setter

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    self.messageBubbleImageView.backgroundColor = backgroundColor;
    self.messageBubbleContainerView.backgroundColor = backgroundColor;
}


- (void)setTextViewFrameInsets:(UIEdgeInsets)textViewFrameInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(textViewFrameInsets, self.textViewFrameInsets)) {
        return;
    }
    
    [self sk_updateConstraint:self.textViewTopVerticalSpaceConstraint withConstant:textViewFrameInsets.top];
    [self sk_updateConstraint:self.textViewBottomVerticalSpaceConstraint withConstant:textViewFrameInsets.bottom];
    [self sk_updateConstraint:self.textViewAvatarHorizontalSpaceConstraint withConstant:textViewFrameInsets.right];
    [self sk_updateConstraint:self.textViewMarginHorizontalSpaceConstraint withConstant:textViewFrameInsets.left];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.messageBubbleImageView.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.messageBubbleImageView.highlighted = selected;
}

#pragma mark - getter

- (UIEdgeInsets)textViewFrameInsets
{
    return UIEdgeInsetsMake(self.textViewTopVerticalSpaceConstraint.constant,
                            self.textViewMarginHorizontalSpaceConstraint.constant,
                            self.textViewBottomVerticalSpaceConstraint.constant,
                            self.textViewAvatarHorizontalSpaceConstraint.constant);
}

#pragma mark - Collection view cell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.textView.text = nil;
    self.textView.attributedText = nil;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    JSQMessagesCollectionViewLayoutAttributes *attributes = (JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes;
    UIEdgeInsets textViewTextContainerInsets = [(NSValue *)[attributes.customAttributes objectForKey:SKMessageLayoutAttributeTextViewContainerInsetsKey] UIEdgeInsetsValue];
    UIEdgeInsets textViewFrameInsets = [(NSValue *)[attributes.customAttributes objectForKey:SKMessageLayoutAttributeTextViewFrameInsetsKey] UIEdgeInsetsValue];
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.textView.textContainerInset, textViewTextContainerInsets)) {
        self.textView.textContainerInset = textViewTextContainerInsets;
    }
    
    self.textViewFrameInsets = textViewFrameInsets;
}

- (void)applyMessageContentData:(id<SKMessageContent>)messageContent
{
    [super applyMessageContentData:messageContent];
    
    NSParameterAssert([messageContent conformsToProtocol:@protocol(SKTextMessageData)]);
    
    id<SKTextMessageData> textMessage = (id<SKTextMessageData>)messageContent;
    
    [self.textView.textStorage setAttributedString:[textMessage attributedText]];
    self.messageBubbleImageView.image = [textMessage messageBubbleImage];
    self.messageBubbleImageView.highlightedImage = [textMessage messageBubbleHighlightedImage];
    
    self.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : self.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
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
