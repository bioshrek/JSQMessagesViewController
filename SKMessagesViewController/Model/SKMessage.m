//
//  SKMessage.m
//  JSQMessages
//
//  Created by shrek wang on 12/14/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMessage.h"

@implementation SKMessage

#pragma mark - life cycle

- (instancetype)initWithSenderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date attributedText:(NSAttributedString *)attributedText uuid:(NSString *)uuid state:(SKMessageState)state
{
    NSParameterAssert([uuid length]);
    
    if (self = [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date attributedText:attributedText]) {
        _uuid = [uuid copy];
        _state = state;
    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date media:(id<JSQMessageMediaData>)media uuid:(NSString *)uuid state:(SKMessageState)state
{
    NSParameterAssert([uuid length]);
    
    if (self = [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date media:media]) {
        _uuid = [uuid copy];
        _state = state;
    }
    return self;
}

@end
