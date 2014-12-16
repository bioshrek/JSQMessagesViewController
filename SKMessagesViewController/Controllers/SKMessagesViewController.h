//
//  SKMessagesViewController.h
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessagesViewController.h"

#import "SKMessageData.h"

@interface SKMessagesViewController : JSQMessagesViewController

- (void)updateItemWithUUID:(NSString *)uuid
                   handler:(void (^)(NSIndexPath *indexPath,
                                     id<SKMessageData> message,
                                     JSQMessagesCollectionViewCell *cell))updateHandler
                  complete:(void (^)())completionCallback;

@end
