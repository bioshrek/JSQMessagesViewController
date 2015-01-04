//
//  SKMediaItem.m
//  JSQMessages
//
//  Created by shrek wang on 1/2/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKMediaItem.h"

@implementation SKMediaItem

- (instancetype)initWithMediaDisplaySize:(CGSize)mediaDisplaySize
                       progressTotalUnitCount:(int64_t)progressTotalUnitCount
                              mediaTitle:(NSString *)mediaTitle
                               mediaSize:(int64_t)mediaSize
{
    NSParameterAssert(progressTotalUnitCount > 0);
    NSParameterAssert([mediaTitle length]);
    NSParameterAssert(mediaSize > 0);
    
    if (self = [super init]) {
        _mediaDisplaySize = mediaDisplaySize;
        _progress = [NSProgress progressWithTotalUnitCount:progressTotalUnitCount];
        _mediaTitle = [mediaTitle copy];
        _mediaSize = mediaSize;
        _mediaState = SKMessageMediaStateDraft;
    }
    return self;
}

- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%dx%d", (int)self.mediaDisplaySize.width, (int)self.mediaDisplaySize.height] hash];
}

- (BOOL)shouldShowMediaTextInfoForMediaState:(SKMessageMediaState)mediaState
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return NO;
}

- (UIImage *)mediaIconForMediaState:(SKMessageMediaState)mediaState
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSString *)mediaDescriptionForMediaState:(SKMessageMediaState)mediaState
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (UIImage *)thumbnailForMediaState:(SKMessageMediaState)mediaState
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

@end
