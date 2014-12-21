//
//  SKMessagesCollectionViewCellOutgoing.h
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellOutgoing.h"

#import "MRProgress.h"

#import "SKMessageData.h"

@interface SKMessagesCollectionViewCellOutgoing : JSQMessagesCollectionViewCellOutgoing

@property (weak, nonatomic, readonly) MRCircularProgressView *circularProgressView;

@property (weak, nonatomic, readonly) MRActivityIndicatorView *activityIndicatorView;

#pragma mark - rendering

- (void)configSendingStatusWithMessage:(id<SKMessageData>)message;

@end
