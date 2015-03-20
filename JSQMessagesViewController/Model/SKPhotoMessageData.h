//
//  SKPhotoMessageData.h
//  JSQMessages
//
//  Created by shrek wang on 3/20/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SKMessageContent.h"

@protocol SKPhotoMessageData <SKMessageContent>

- (CGSize)photoDisplaySize;

@end
