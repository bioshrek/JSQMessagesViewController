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

#import "JSQMessage.h"

#import "JSQMessagesCollectionViewCellOutgoing.h"
#import "JSQMessagesCollectionViewCellIncoming.h"

#import "JSQMessagesCollectionViewCellOutgoingAudio.h"
#import "JSQMessagesCollectionViewCellIncomingAudio.h"

#import "JSQMessagesCollectionViewCellOutgoingFile.h"
#import "JSQMessagesCollectionViewCellIncomingFile.h"

@interface JSQMessage ()

@end



@implementation JSQMessage

#pragma mark - Initialization

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                     attributedText:(NSAttributedString *)attributedText
{
    return [[JSQMessage alloc] initWithSenderId:senderId
                              senderDisplayName:displayName
                                           date:[NSDate date]
                                 attributedText:attributedText];
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                  attributedText:(NSAttributedString *)attributedText
{
    NSParameterAssert(attributedText != nil);
    
    self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date messageType:JSQMessageDataTypeText];
    if (self) {
        _attributedText = [attributedText copy];
    }
    return self;
}

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                              media:(id<JSQMessageMediaData>)media
{
    return [[JSQMessage alloc] initWithSenderId:senderId
                              senderDisplayName:displayName
                                           date:[NSDate date]
                                          media:media];
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<JSQMessageMediaData>)media
{
    NSParameterAssert(media != nil);
    
    self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date messageType:JSQMessageDataTypeImage];
    if (self) {
        _media = media;
    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                     messageType:(JSQMessageDataType)messageType
{
    NSParameterAssert(senderId != nil);
    NSParameterAssert(senderDisplayName != nil);
    NSParameterAssert(date != nil);
    
    self = [super init];
    if (self) {
        _senderId = [senderId copy];
        _senderDisplayName = [senderDisplayName copy];
        _date = [date copy];
        _messageType = messageType;
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
    
    JSQMessage *aMessage = (JSQMessage *)object;
    
    if (self.messageType != aMessage.messageType) {
        return NO;
    }
    
    BOOL hasEqualContent = self.messageType ? [self.media isEqual:aMessage.media] : [self.attributedText isEqualToAttributedString:aMessage.attributedText];
    
    return [self.senderId isEqualToString:aMessage.senderId]
            && [self.senderDisplayName isEqualToString:aMessage.senderDisplayName]
            && ([self.date compare:aMessage.date] == NSOrderedSame)
            && hasEqualContent;
}

- (NSUInteger)hash
{
    NSUInteger contentHash = 0;
    
    switch (self.messageType) {
        case JSQMessageDataTypeText:
            contentHash = [self.attributedText hash];
            break;
        case JSQMessageDataTypeImage:
        case JSQMessageDataTypeVideo:
            contentHash = [self.media hash];
            break;
        case JSQMessageDataTypeAudio:
            contentHash = [self.media hash];
            break;
        case JSQMessageDataTypeFile:
            contentHash = [self.file hash];
            break;
        default:
            break;
    }
    
    return self.senderId.hash ^ self.date.hash ^ contentHash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: senderId=%@, senderDisplayName=%@, date=%@, mediaMessageType=%@, attributedText=%@, media=%@>",
            [self class], self.senderId, self.senderDisplayName, self.date, @(self.messageType), self.attributedText, self.media];
}

- (id)debugQuickLookObject
{
    return [self.media mediaView] ?: [self.media mediaPlaceholderView];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _senderId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderId))];
        _senderDisplayName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderDisplayName))];
        _date = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(date))];
        _messageType = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(messageType))];
        _attributedText = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(attributedText))];
        _media = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(media))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.senderId forKey:NSStringFromSelector(@selector(senderId))];
    [aCoder encodeObject:self.senderDisplayName forKey:NSStringFromSelector(@selector(senderDisplayName))];
    [aCoder encodeObject:self.date forKey:NSStringFromSelector(@selector(date))];
    [aCoder encodeInteger:self.messageType forKey:NSStringFromSelector(@selector(messageType))];
    [aCoder encodeObject:self.attributedText forKey:NSStringFromSelector(@selector(attributedText))];
    
    if ([self.media conformsToProtocol:@protocol(NSCoding)]) {
        [aCoder encodeObject:self.media forKey:NSStringFromSelector(@selector(media))];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQMessage *message = nil;
    
    switch (self.messageType) {
        case JSQMessageDataTypeText:
            message = [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                        senderDisplayName:self.senderDisplayName
                                                                     date:self.date
                                                           attributedText:self.attributedText];
            break;
        case JSQMessageDataTypeImage:
        case JSQMessageDataTypeVideo:
            message = [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                        senderDisplayName:self.senderDisplayName
                                                                     date:self.date
                                                                    media:self.media];
            break;
        case JSQMessageDataTypeAudio:
            message = [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                        senderDisplayName:self.senderDisplayName
                                                                     date:self.date
                                                                    audio:self.audio];
            break;
        case JSQMessageDataTypeFile:
            message = [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                        senderDisplayName:self.senderDisplayName
                                                                     date:self.date
                                                                     file:self.file];
            break;
        default:
            break;
    }
    
    return message;
}

- (NSString *)reusableCellIdentifierForOutgoing:(BOOL)outgoing
{
    NSString *identifier = nil;
    
    switch (self.messageType) {
        case JSQMessageDataTypeText:
            identifier = outgoing ? [JSQMessagesCollectionViewCellOutgoing cellReuseIdentifier] : [JSQMessagesCollectionViewCellIncoming cellReuseIdentifier];
            break;
        case JSQMessageDataTypeImage:
        case JSQMessageDataTypeVideo:
            identifier = outgoing ? [JSQMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier] : [JSQMessagesCollectionViewCellIncoming mediaCellReuseIdentifier];
            break;
        case JSQMessageDataTypeAudio:
            identifier = outgoing ? [JSQMessagesCollectionViewCellOutgoingAudio cellReuseIdentifier] : [JSQMessagesCollectionViewCellIncomingAudio cellReuseIdentifier];
            break;
        case JSQMessageDataTypeFile:
            identifier = outgoing ? [JSQMessagesCollectionViewCellOutgoingFile cellReuseIdentifier] : [JSQMessagesCollectionViewCellIncomingFile cellReuseIdentifier];
            break;
        default:
            break;
    }
    
    return identifier;
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           audio:(id<JSQMessageAudioData>)audio
{
    if (self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date messageType:JSQMessageDataTypeAudio]) {
        _audio = audio;
    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                            file:(id<JSQMessageFileData>)file
{
    if (self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date messageType:JSQMessageDataTypeFile]) {
        _file = file;
    }
    return self;
}

@end
