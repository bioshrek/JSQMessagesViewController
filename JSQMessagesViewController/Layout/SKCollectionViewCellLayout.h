//
//  SKCollectionViewCellLayout.h
//  JSQMessages
//
//  Created by shrek wang on 3/20/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "JSQMessagesCollectionViewLayoutAttributes.h"

// constants: layout attribute keys
extern NSString * const SKMessageLayoutAttributeTextViewFrameInsetsKey;
extern NSString * const SKMessageLayoutAttributeTextViewContainerInsetsKey;

@protocol SKCollectionViewCellLayout <NSObject>

- (CGSize)messageBubbleSizeForMessageContent:(id)messageContent maxWidth:(CGFloat)maxWidth;

- (void)configCustomLayoutAttributes:(JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes;

@end
