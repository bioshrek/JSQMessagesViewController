//
//  SKMessage.m
//  JSQMessages
//
//  Created by shrek wang on 12/14/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMessage.h"

@interface SKMessage ()

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                         isMedia:(BOOL)isMedia
                            uuid:(NSString *)uuid
                           state:(SKMessageState)state;

@end

@implementation SKMessage

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                  attributedText:(NSAttributedString *)attributedText
                            uuid:(NSString *)uuid
                           state:(SKMessageState)state
{
    NSParameterAssert(attributedText != nil);
    
    self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date isMedia:NO uuid:uuid state:state];
    if (self) {
        _attributedText = [attributedText copy];
    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(SKMediaItem *)media
                            uuid:(NSString *)uuid
                           state:(SKMessageState)state
{
    NSParameterAssert(media != nil);
    
    self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date isMedia:YES uuid:uuid state:state];
    if (self) {
        _media = media;
    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                         isMedia:(BOOL)isMedia
                            uuid:(NSString *)uuid
                           state:(SKMessageState)state
{
    NSParameterAssert(senderId != nil);
    NSParameterAssert(senderDisplayName != nil);
    NSParameterAssert(date != nil);
    NSParameterAssert([uuid length]);
    
    self = [super init];
    if (self) {
        _senderId = [senderId copy];
        _senderDisplayName = [senderDisplayName copy];
        _date = [date copy];
        _isMediaMessage = isMedia;
        _uuid = [uuid copy];
        _state = state;
    }
    return self;
}

- (id)init
{
    NSAssert(NO, @"%s is not a valid initializer for %@.", __PRETTY_FUNCTION__, [self class]);
    return nil;
}

- (void)dealloc
{
    _senderId = nil;
    _senderDisplayName = nil;
    _date = nil;
    _attributedText = nil;
    _media = nil;
    _uuid = nil;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SKMessage *aMessage = (SKMessage *)object;
    return [aMessage.uuid isEqualToString:self.uuid];
}

- (NSUInteger)hash
{
    NSUInteger contentHash = self.isMediaMessage ? self.media.hash : self.attributedText.hash;
    
    return self.senderId.hash ^ self.date.hash ^ contentHash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: senderId=%@, senderDisplayName=%@, date=%@, isMediaMessage=%@, attributedText=%@, media=%@, uuid=%@>",
            [self class], self.senderId, self.senderDisplayName, self.date, @(self.isMediaMessage), self.attributedText, self.media, self.uuid];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _senderId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderId))];
        _senderDisplayName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderDisplayName))];
        _date = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(date))];
        _isMediaMessage = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isMediaMessage))];
        _attributedText = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(attributedText))];
        _media = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(media))];
        _uuid = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(uuid))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.senderId forKey:NSStringFromSelector(@selector(senderId))];
    [aCoder encodeObject:self.senderDisplayName forKey:NSStringFromSelector(@selector(senderDisplayName))];
    [aCoder encodeObject:self.date forKey:NSStringFromSelector(@selector(date))];
    [aCoder encodeBool:self.isMediaMessage forKey:NSStringFromSelector(@selector(isMediaMessage))];
    [aCoder encodeObject:self.attributedText forKey:NSStringFromSelector(@selector(attributedText))];
    [aCoder encodeObject:self.uuid forKey:NSStringFromSelector(@selector(uuid))];
    
    if ([self.media conformsToProtocol:@protocol(NSCoding)]) {
        [aCoder encodeObject:self.media forKey:NSStringFromSelector(@selector(media))];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    if (self.isMediaMessage) {
        return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:self.date
                                                             media:self.media
                                                              uuid:self.uuid
                                                             state:self.state];
    }
    
    return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:self.date
                                                attributedText:self.attributedText
                                                          uuid:self.uuid
                                                         state:self.state];
}


@end
