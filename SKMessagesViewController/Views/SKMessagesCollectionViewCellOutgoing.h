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

#import "SKButton.h"

@interface SKMessagesCollectionViewCellOutgoing : JSQMessagesCollectionViewCellOutgoing

@property (weak, nonatomic, readonly) MRActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic, readonly) SKButton *errorIndicatorButton;

@end
