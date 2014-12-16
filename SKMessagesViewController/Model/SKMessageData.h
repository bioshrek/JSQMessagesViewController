//
//  SKMessageData.h
//  JSQMessages
//
//  Created by shrek wang on 12/17/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSQMessageData.h"

// type: message transfer state
typedef NS_ENUM(NSInteger, SKMessageState) {
    SKMessageStateDraft = 1,
    SKMessageStateSending = 2,
    SKMessageStateSent = 3,
    SKMessageStateReceiving = 4,
    SKMessageStateReceived = 5,
    SKMessageStateRead = 6
};

@protocol SKMessageData <JSQMessageData>

- (NSString *)uuid;

- (SKMessageState)state;
- (void)setState:(SKMessageState)state;

@optional

- (NSProgress *)progress;
- (void)setProgress:(NSProgress *)progress;

@end
