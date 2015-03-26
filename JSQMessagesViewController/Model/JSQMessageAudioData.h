//
//  JSQAudioItem.h
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSQMessageAudioData <NSObject>

- (NSTimeInterval)duration;

- (NSUInteger)hash;

@end
