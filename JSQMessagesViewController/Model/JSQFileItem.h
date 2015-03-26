//
//  JSQFileItem.h
//  JSQMessages
//
//  Created by shrek wang on 3/27/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSQMessageFileData.h"

@interface JSQFileItem : NSObject <JSQMessageFileData>

@property (copy, nonatomic, readonly) NSString *filename;
@property (copy, nonatomic, readonly) NSString *fileSize;

- (instancetype)initWithFileName:(NSString *)fileName bytes:(int64_t)bytes;

@end
