//
//  SKMessagesCollectionViewCellIncoming.h
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellIncoming.h"

#import "MRProgress.h"

#import "SKMessageData.h"

@interface SKMessagesCollectionViewCellIncoming : JSQMessagesCollectionViewCellIncoming

@property (weak, nonatomic, readonly) MRCircularProgressView *circularProgressView;

#pragma mark - rendering

- (void)configReceivingStatusWithMessage:(id<SKMessageData>)message;

@end
