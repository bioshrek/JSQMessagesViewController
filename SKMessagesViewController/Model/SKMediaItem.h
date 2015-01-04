//
//  SKMediaItem.h
//  JSQMessages
//
//  Created by shrek wang on 1/2/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SKMessagesCollectionViewDataSource.h"

@interface SKMediaItem : NSObject

@property (nonatomic, assign, readonly) CGSize mediaDisplaySize;

@property (nonatomic, strong) NSProgress *progress;

@property (nonatomic, copy, readonly) NSString *mediaTitle;

@property (nonatomic, assign, readonly) int64_t mediaSize;

@property (nonatomic, assign) SKMessageMediaState mediaState;

- (BOOL)shouldShowMediaTextInfoForMediaState:(SKMessageMediaState)mediaState;

- (UIImage *)mediaIconForMediaState:(SKMessageMediaState)mediaState;

- (NSString *)mediaDescriptionForMediaState:(SKMessageMediaState)mediaState;

- (UIImage *)thumbnailForMediaState:(SKMessageMediaState)mediaState;

- (instancetype)initWithMediaDisplaySize:(CGSize)mediaDisplaySize
                       progressTotalUnitCount:(int64_t)progressTotalUnitCount
                              mediaTitle:(NSString *)mediaTitle
                               mediaSize:(int64_t)mediaSize;

@end
