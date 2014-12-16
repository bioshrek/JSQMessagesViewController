//
//  SKMessagesCollectionViewCellOutgoing.h
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellOutgoing.h"

#import "MRProgress.h"

@interface SKMessagesCollectionViewCellOutgoing : JSQMessagesCollectionViewCellOutgoing

@property (weak, nonatomic, readonly) MRCircularProgressView *circularProgressView;

@property (weak, nonatomic, readonly) MRActivityIndicatorView *activityIndicatorView;

@end
