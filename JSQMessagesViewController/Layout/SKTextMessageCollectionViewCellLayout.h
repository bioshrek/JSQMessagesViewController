//
//  SKTextMessageCollectionViewCellLayout.h
//  JSQMessages
//
//  Created by shrek wang on 3/20/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKCollectionViewCellLayout.h"

@interface SKTextMessageCollectionViewCellLayout : NSObject <SKCollectionViewCellLayout>

/**
 *  The inset of the frame of the text view within the `messageBubbleContainerView` of each `JSQMessagesCollectionViewCell`.
 *  The inset values should be positive and are applied in the following ways:
 *
 *  1. The right value insets the text view frame on the side adjacent to the avatar image
 *      (or where the avatar would normally appear). For outgoing messages this is the right side,
 *      for incoming messages this is the left side.
 *
 *  2. The left value insets the text view frame on the side opposite the avatar image
 *      (or where the avatar would normally appear). For outgoing messages this is the left side,
 *      for incoming messages this is the right side.
 *
 *  3. The top value insets the top of the frame.
 *
 *  4. The bottom value insets the bottom of the frame.
 *
 *  @discussion The default value is `{0.0f, 0.0f, 0.0f, 6.0f}`.
 *
 *  @warning Adjusting this value is an advanced endeavour and not recommended.
 *  You will only need to adjust this value should you choose to provide your own bubble image assets.
 *  Changing this value may also require you to manually calculate the itemSize for each cell
 *  in the layout by overriding the delegate method `collectionView:layout:sizeForItemAtIndexPath:`
 */
@property (assign, nonatomic) UIEdgeInsets messageBubbleTextViewFrameInsets;

/**
 *  The inset of the text container's layout area within the text view's content area in each `JSQMessagesCollectionViewCell`.
 *  The specified inset values should be positive.
 *
 *  @discussion The default value is `{7.0f, 14.0f, 7.0f, 14.0f}`.
 *
 *  @warning Adjusting this value is an advanced endeavour and not recommended.
 *  You will only need to adjust this value should you choose to provide your own bubble image assets.
 *  Changing this value may also require you to manually calculate the itemSize for each cell
 *  in the layout by overriding the delegate method `collectionView:layout:sizeForItemAtIndexPath:`
 */
@property (assign, nonatomic) UIEdgeInsets messageBubbleTextViewTextContainerInsets;

@end
