//
//  JSQAudioItem.m
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQAudioItem.h"

@implementation JSQAudioItem

- (instancetype)initWithDuration:(NSTimeInterval)duration
{
    if (self = [super init]) {
        _duration = duration;
    }
    return self;
}

- (NSUInteger)hash
{
    return (NSUInteger)self.duration;
}

@end
