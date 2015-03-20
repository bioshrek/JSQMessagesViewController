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

#import <UIKit/UIKit.h>

/**
 *  A `JSQMessagesCollectionViewLayoutAttributes` is an object that manages the layout-related attributes
 *  for a given `JSQMessagesCollectionViewCell` in a `JSQMessagesCollectionView`.
 */
@interface JSQMessagesCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes <NSCopying>

/**
 *  The size of the `avatarImageView` of a `JSQMessagesCollectionViewCell`.
 *  The size values should be greater than or equal to `0.0`.
 *
 *  @see JSQMessagesCollectionViewCell.
 */
@property (assign, nonatomic) CGSize avatarViewSize;

/**
 *  The height of the `cellTopLabel` of a `JSQMessagesCollectionViewCell`.
 *  This value should be greater than or equal to `0.0`.
 *
 *  @see JSQMessagesCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat cellTopLabelHeight;

/**
 *  The height of the `messageBubbleTopLabel` of a `JSQMessagesCollectionViewCell`.
 *  This value should be greater than or equal to `0.0`.
 *
 *  @see JSQMessagesCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat messageBubbleTopLabelHeight;

/**
 *  The height of the `cellBottomLabel` of a `JSQMessagesCollectionViewCell`.
 *  This value should be greater than or equal to `0.0`.
 *
 *  @see JSQMessagesCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat cellBottomLabelHeight;

/**
 *  The width of the `messageBubbleContainerView` of a `JSQMessagesCollectionViewCell`.
 *  This value should be greater than `0.0`.
 *
 *  @see JSQMessagesCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat messageBubbleContainerViewWidth;

/**
 *  Specific cell attributes which are not common among all cells.
 *  If your custom cell has attributes which is not defined in this class,
 *  you should access it through this dictionary.
 */
@property (strong, nonatomic) NSMutableDictionary *customAttributes;

@end
