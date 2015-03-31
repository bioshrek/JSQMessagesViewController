//
//  SKKeyboardItem.h
//  JSQMessages
//
//  Created by Shrek Wang on 3/30/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKKeyboardItem;

@protocol SKKeyboardManager <NSObject>

- (void)turnOffOtherKeyboardItemsWithSender:(SKKeyboardItem *)keyboardItem;

@end

@interface SKKeyboardItem : NSObject

@property (assign, nonatomic, getter=isOn) BOOL on;

@property (copy, nonatomic, readonly) NSString *keyboardIdentifier;

- (instancetype)initWithIdentifier:(NSString *)identifier
                           onBlock:(void (^)())onBlock
                          offBlock:(void (^)(SKKeyboardItem *sender))offBlock
                   keyboardManager:(id<SKKeyboardManager>)keyboardManager;

- (void)triggered;

- (void)turnOffByOtherKeyboard:(SKKeyboardItem *)otherKeyboardItem;

@end
