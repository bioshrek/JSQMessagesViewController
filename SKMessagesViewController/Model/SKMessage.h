//
//  SKMessage.h
//  JSQMessages
//
//  Created by shrek wang on 12/14/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessage.h"

#import "SKMessageData.h"

@interface SKMessage : JSQMessage <SKMessageData>

// text message: isIndeterminate ? is transfering : not transfering
// media message: fractionCopleted
@property (nonatomic, strong) NSProgress *progress;

@property (nonatomic, assign) SKMessageState state;

@property (nonatomic, copy, readonly) NSString *uuid;

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date attributedText:(NSAttributedString *)attributedText
                            uuid:(NSString *)uuid
                           state:(SKMessageState)state;

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date media:(id<JSQMessageMediaData>)media
                            uuid:(NSString *)uuid
                           state:(SKMessageState)state;

@end
