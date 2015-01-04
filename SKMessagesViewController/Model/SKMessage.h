//
//  SKMessage.h
//  JSQMessages
//
//  Created by shrek wang on 12/14/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessage.h"

#import "JSQMessagesCollectionView.h"

#import "SKMediaItem.h"

@interface SKMessage : NSObject

/**
 *  Returns the string identifier that uniquely identifies the user who sent the message.
 */
@property (copy, nonatomic, readonly) NSString *senderId;

/**
 *  Returns the display name for the user who sent the message. This value does not have to be unique.
 */
@property (copy, nonatomic, readonly) NSString *senderDisplayName;

/**
 *  Returns the date that the message was sent.
 */
@property (copy, nonatomic, readonly) NSDate *date;

/**
 *  Returns a boolean value specifying whether or not the message contains media.
 *  If `NO`, the message contains text. If `YES`, the message contains media.
 *  The value of this property depends on how the object was initialized.
 */
@property (assign, nonatomic, readonly) BOOL isMediaMessage;

/**
 *  Returns the body text of the message, or `nil` if the message is a media message.
 *  That is, if `isMediaMessage` is equal to `YES` then this value will be `nil`.
 */
@property (copy, nonatomic, readonly) NSAttributedString *attributedText;

/**
 *  Returns the media item attachment of the message, or `nil` if the message is not a media message.
 *  That is, if `isMediaMessage` is equal to `NO` then this value will be `nil`.
 */
@property (copy, nonatomic, readonly) SKMediaItem *media;

@property (nonatomic, assign) SKMessageState state;

@property (nonatomic, copy, readonly) NSString *uuid;

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                  attributedText:(NSAttributedString *)attributedText
                            uuid:(NSString *)uuid
                           state:(SKMessageState)state;

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(SKMediaItem *)media
                            uuid:(NSString *)uuid
                           state:(SKMessageState)state;

@end
