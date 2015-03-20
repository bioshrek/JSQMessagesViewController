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

#import "JSQMessageMediaData.h"

/**
 *  The `JSQMessageData` protocol defines the common interface through which 
 *  a `JSQMessagesViewController` and `JSQMessagesCollectionView` interact with message model objects.
 *
 *  It declares the required and optional methods that a class must implement so that instances of that class 
 *  can be displayed properly within a `JSQMessagesCollectionViewCell`.
 *
 *  Two concrete classes that conform to this protocol are provided in the library. See `JSQTextMessage` and `JSQMediaMessage`.
 *
 *  @see JSQMessage.
 *  @see JSQTextMessage.
 *  @see JSQMediaMessage.
 */
@protocol JSQMessageData <NSObject>

@required

/**
 *  @return A string identifier that uniquely identifies the user who sent the message.
 *
 *  @discussion If you need to generate a unique identifier, consider using 
 *  `[[NSProcessInfo processInfo] globallyUniqueString]`
 *
 *  @warning You must not return `nil` from this method. This value must be unique.
 */
- (NSString *)senderId;

/**
 *  @return The display name for the user who sent the message.
 *
 *  @warning You must not return `nil` from this method.
 */
- (NSString *)senderDisplayName;

/**
 *  @return The date that the message was sent.
 *
 *  @warning You must not return `nil` from this method.
 */
- (NSDate *)date;


@end
