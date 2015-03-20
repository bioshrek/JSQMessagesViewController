//
//  SKTextMessagesCollectionViewCell.h
//  JSQMessages
//
//  Created by shrek wang on 3/5/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCell.h"

@interface SKTextMessagesCollectionViewCell : JSQMessagesCollectionViewCell

/**
 *  Returns the text view of the cell. This text view contains the message body text.
 *
 *  @warning If mediaView returns a non-nil view, then this value will be `nil`.
 */
@property (weak, nonatomic, readonly) JSQMessagesCellTextView *textView;

/**
 *  Returns the bubble image view of the cell that is responsible for displaying message bubble images.
 *
 *  @warning If mediaView returns a non-nil view, then this value will be `nil`.
 */
@property (weak, nonatomic, readonly) UIImageView *messageBubbleImageView;

@end
