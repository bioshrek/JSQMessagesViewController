//
//  SKKeyboardItem.m
//  JSQMessages
//
//  Created by Shrek Wang on 3/30/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKKeyboardItem.h"

@interface SKKeyboardItem()

@property (copy, nonatomic) void (^onBlock)();
@property (copy, nonatomic) void (^offBlock)(SKKeyboardItem *sender);
@property (weak, nonatomic) id<SKKeyboardManager> keyboardManager;

@end

@implementation SKKeyboardItem

- (instancetype)initWithIdentifier:(NSString *)identifier
                           onBlock:(void (^)())onBlock
                          offBlock:(void (^)(SKKeyboardItem *sender))offBlock
                   keyboardManager:(id<SKKeyboardManager>)keyboardManager
{
    NSParameterAssert(identifier);
    
    if (self = [super init]) {
        _keyboardIdentifier = [identifier copy];
        _onBlock = [onBlock copy];
        _offBlock = [offBlock copy];
        _keyboardManager = keyboardManager;
    }
    return self;
}

- (void)triggered
{
    BOOL currentState = self.isOn;
    // flip state
    _on = !currentState;
    
    if (currentState) {  // on -> off
        if (self.offBlock) self.offBlock(self);
    } else {  // off -> on
        [self.keyboardManager turnOffOtherKeyboardItemsWithSender:self];
        if (self.onBlock) self.onBlock();
    }
}

- (void)turnOffByOtherKeyboard:(SKKeyboardItem *)otherKeyboardItem
{
    if (self.offBlock) self.offBlock(otherKeyboardItem);
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (nil == object || ![object isKindOfClass:[SKKeyboardItem class]]) {
        return NO;
    }
    
    SKKeyboardItem *otherItem = (SKKeyboardItem *)object;
    return [otherItem.keyboardIdentifier isEqualToString:self.keyboardIdentifier];
}

@end