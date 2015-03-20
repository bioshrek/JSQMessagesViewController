//
//  SKMessageContent.h
//  JSQMessages
//
//  Created by shrek wang on 3/20/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SKMessageContent <NSObject>

- (NSUInteger)hash;

- (NSString *)cellIdentifier;  // data -> view

- (Class)layoutClass;  // data -> layout

@end
