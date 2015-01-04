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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "JSQMediaView.h"

@class JSQMessagesCollectionView;
@protocol JSQMessageData;
@protocol JSQMessageBubbleImageDataSource;
@protocol JSQMessageAvatarImageDataSource;


// type: message state

typedef NS_ENUM(NSInteger, SKMessageState) {
    SKMessageStateDraft = 1,
    SKMessageStateSending = 2,
    SKMessageStateSendingFailure = 3,
    SKMessageStateSent = 4,
    SKMessageStateReceived = 5,
    SKMessageStateRead = 6,
};

/**
 *  An object that adopts the `JSQMessagesCollectionViewDataSource` protocol is responsible for providing the data and views
 *  required by a `JSQMessagesCollectionView`. The data source object represents your app’s messaging data model
 *  and vends information to the collection view as needed.
 */
@protocol JSQMessagesCollectionViewDataSource <UICollectionViewDataSource>

@required

/**
 *  Asks the data source for the current sender's display name, that is, the current user who is sending messages.
 *
 *  @return An initialized string describing the current sender to display in a `JSQMessagesCollectionViewCell`.
 *  
 *  @warning You must not return `nil` from this method. This value does not need to be unique.
 */
- (NSString *)senderDisplayName;

/**
 *  Asks the data source for the current sender's unique identifier, that is, the current user who is sending messages.
 *
 *  @return An initialized string identifier that uniquely identifies the current sender.
 *
 *  @warning You must not return `nil` from this method. This value must be unique.
 */
- (NSString *)senderId;

/**
 *  Asks the data source for the message bubble image data that corresponds to the specified message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return An initialized object that conforms to the `JSQMessageBubbleImageDataSource` protocol. You may return `nil` from this method if you do not
 *  want the specified item to display a message bubble image.
 *
 *  @discussion It is recommended that you utilize `JSQMessagesBubbleImageFactory` to return valid `JSQMessagesBubbleImage` objects.
 *  However, you may provide your own data source object as long as it conforms to the `JSQMessageBubbleImageDataSource` protocol.
 *  
 *  @warning Note that providing your own bubble image data source objects may require additional 
 *  configuration of the collectionView layout object, specifically regarding its `messageBubbleTextViewFrameInsets` and `messageBubbleTextViewTextContainerInsets`.
 *
 *  @see JSQMessagesBubbleImageFactory.
 *  @see JSQMessagesCollectionViewFlowLayout.
 */
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the avatar image data that corresponds to the specified message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A initialized object that conforms to the `JSQMessageAvatarImageDataSource` protocol. You may return `nil` from this method if you do not want
 *  the specified item to display an avatar.
 *
 *  @discussion It is recommended that you utilize `JSQMessagesAvatarImageFactory` to return valid `JSQMessagesAvatarImage` objects.
 *  However, you may provide your own data source object as long as it conforms to the `JSQMessageAvatarImageDataSource` protocol.
 *
 *  @see JSQMessagesAvatarImageFactory.
 *  @see JSQMessagesCollectionViewFlowLayout.
 */
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  Asks the data source for the text to display in the `cellTopLabel` for the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A configured attributed string or `nil` if you do not want text displayed for the item at indexPath.
 *  Return an attributed string with `nil` attributes to use the default attributes.
 *
 *  @see JSQMessagesCollectionViewCell.
 */
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the text to display in the `messageBubbleTopLabel` for the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A configured attributed string or `nil` if you do not want text displayed for the item at indexPath.
 *  Return an attributed string with `nil` attributes to use the default attributes.
 *
 *  @see JSQMessagesCollectionViewCell.
 */
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the text to display in the `cellBottomLabel` for the the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A configured attributed string or `nil` if you do not want text displayed for the item at indexPath.
 *  Return an attributed string with `nil` attributes to use the default attributes.
 *
 *  @see JSQMessagesCollectionViewCell.
 */
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @return A string identifier that uniquely identifies the user who sent the message.
 *
 *  @discussion If you need to generate a unique identifier, consider using
 *  `[[NSProcessInfo processInfo] globallyUniqueString]`
 *
 *  @warning You must not return `nil` from this method. This value must be unique.
 */
- (NSString *)collectionView:(JSQMessagesCollectionView *)collectionView senderIdForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @return The display name for the user who sent the message.
 *
 *  @warning You must not return `nil` from this method.
 */
- (NSString *)collectionView:(JSQMessagesCollectionView *)collectionView senderDisplayNameForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @return The date that the message was sent.
 *
 *  @warning You must not return `nil` from this method.
 */
- (NSDate *)collectionView:(JSQMessagesCollectionView *)collectionView dateForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @return An integer that can be used as a table address in a hash table structure.
 */
- (NSUInteger)collectionView:(JSQMessagesCollectionView *)collectionView hashForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  This method is used to determine if the message data item contains text or media.
 *  If this method returns `YES`, an instance of `JSQMessagesViewController` will ignore
 *  the `text` method of this protocol when dequeuing a `JSQMessagesCollectionViewCell`
 *  and only call the `media` method.
 *
 *  Similarly, if this method returns `NO` then the `media` method will be ignored and
 *  and only the `text` method will be called.
 *
 *  @return A boolean value specifying whether or not this is a media message or a text message.
 *  Return `YES` if this item is a media message, and `NO` if it is a text message.
 */
- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView isMediaMessageForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  @return The body text of the message.
 *
 *  @warning You must not return `nil` from this method.
 */
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @return The frame size for the mediaView when displayed in a `JSQMessagesCollectionViewCell`.
 *
 *  @discussion You should return an appropriate size value to be set for the mediaView's frame
 *  based on the contents of the view, and the frame and layout of the `JSQMessagesCollectionViewCell`
 *  in which mediaView will be displayed.
 *
 *  @warning You must return a size with non-zero, positive width and height values.
 */
- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView mediaViewDisplaySizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @return An initialized `UIView` object that represents the data for this media object.
 *
 *  @discussion You may return `nil` from this method while the media data is being downloaded.
 */
- (JSQMediaView *)collectionView:(JSQMessagesCollectionView *)collectionView mediaViewForItemAtIndexPath:(NSIndexPath *)indexPath isOutgoing:(BOOL)isOutgoing;

/**
 *  @return A placeholder media view to be displayed if mediaView is not yet available, or `nil`.
 *  For example, if mediaView will be constructed based on media data that must be downloaded,
 *  this placeholder view will be used until mediaView is not `nil`.
 *
 *  @discussion If you do not need support for a placeholder view, then you may simply return the
 *  same value here as mediaView. Otherwise, consider using `JSQMessagesMediaPlaceholderView`.
 *
 *  @warning You must not return `nil` from this method.
 *
 *  @see JSQMessagesMediaPlaceholderView.
 */
- (JSQMediaView *)collectionView:(JSQMessagesCollectionView *)collectionView mediaPlaceholderViewForItemAtIndexPath:(NSIndexPath *)indexPath isOutgoing:(BOOL)isOutgoing;

/**
 *  @return An integer that can be used as a table address in a hash table structure.
 */
- (NSUInteger)collectionView:(JSQMessagesCollectionView *)collectionView mediaHashForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
