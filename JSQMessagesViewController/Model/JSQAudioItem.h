//
//  JSQAudioItem.h
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSQMessageAudioData.h"

@interface JSQAudioItem : NSObject <JSQMessageAudioData>

@property (assign, nonatomic, readonly) NSTimeInterval duration;

- (instancetype)initWithDuration:(NSTimeInterval)duration;

@end
