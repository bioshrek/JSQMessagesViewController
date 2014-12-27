//
//  SKMessageData.h
//  JSQMessages
//
//  Created by shrek wang on 12/17/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSQMessageData.h"

#import "SKMessagesCollectionViewDataSource.h"

// type: message transfer state

@protocol SKMessageData <JSQMessageData>

- (NSString *)uuid;

- (SKMessageState)state;
- (void)setState:(SKMessageState)state;

@optional

- (NSProgress *)progress;
- (void)setProgress:(NSProgress *)progress;

@end
