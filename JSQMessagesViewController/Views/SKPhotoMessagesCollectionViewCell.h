//
//  SKMediaMessagesCollectionViewCell.h
//  JSQMessages
//
//  Created by shrek wang on 3/5/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCell.h"

@interface SKPhotoMessagesCollectionViewCell : JSQMessagesCollectionViewCell

/**
 *  The media view of the cell. This view displays the contents of a media message.
 *
 *  @warning If this value is non-nil, then textView and messageBubbleImageView will both be `nil`.
 */
@property (weak, nonatomic, readonly) UIImageView *imageView;

@end
