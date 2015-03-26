//
//  JSQFileItem.m
//  JSQMessages
//
//  Created by shrek wang on 3/27/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQFileItem.h"

@implementation JSQFileItem

- (instancetype)initWithFileName:(NSString *)fileName bytes:(int64_t)bytes
{
    NSParameterAssert([fileName length]);
    NSParameterAssert(bytes >= 0);
    
    if (self = [super init]) {
        _filename = [fileName copy];
        _fileSize = [NSByteCountFormatter stringFromByteCount:bytes countStyle:NSByteCountFormatterCountStyleFile];
    }
    return self;
}

- (NSUInteger)hash
{
    return [self.filename hash];
}

@end
