//
//  SKMessagesViewController.m
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMessagesViewController.h"

#import "SKMessagesCollectionViewCellIncoming.h"
#import "SKMessagesCollectionViewCellOutgoing.h"

#import "SKMessageData.h"

@interface SKMessagesViewController ()

@end

@implementation SKMessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // register new collection cells
    [self.collectionView registerNib:[SKMessagesCollectionViewCellIncoming nib]
          forCellWithReuseIdentifier:[SKMessagesCollectionViewCellIncoming cellReuseIdentifier]];
    [self.collectionView registerNib:[SKMessagesCollectionViewCellIncoming nib]
          forCellWithReuseIdentifier:[SKMessagesCollectionViewCellIncoming mediaCellReuseIdentifier]];
    [self.collectionView registerNib:[SKMessagesCollectionViewCellOutgoing nib]
            forCellWithReuseIdentifier:[SKMessagesCollectionViewCellOutgoing cellReuseIdentifier]];
    [self.collectionView registerNib:[SKMessagesCollectionViewCellOutgoing nib]
          forCellWithReuseIdentifier:[SKMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier]];
    
    // override
    self.incomingCellIdentifier = [SKMessagesCollectionViewCellIncoming cellReuseIdentifier];
    self.incomingMediaCellIdentifier = [SKMessagesCollectionViewCellIncoming mediaCellReuseIdentifier];
    self.outgoingCellIdentifier = [SKMessagesCollectionViewCellOutgoing cellReuseIdentifier];
    self.outgoingMediaCellIdentifier = [SKMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier];
}

// override point


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    id<JSQMessageData> message = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    if (![message conformsToProtocol:@protocol(SKMessageData)]) {
        return cell;
    }
    id<SKMessageData> messageItem = (id<SKMessageData>)message;
    
    NSParameterAssert(messageItem != nil);
    
    NSString *messageSenderId = [messageItem senderId];
    NSParameterAssert(messageSenderId != nil);
    
    BOOL isOutgoingMessage = [messageSenderId isEqualToString:self.senderId];
    
    if (isOutgoingMessage && [cell isKindOfClass:[SKMessagesCollectionViewCellOutgoing class]]) {
        // outgoing message
        
        SKMessagesCollectionViewCellOutgoing *outgoingCell = (SKMessagesCollectionViewCellOutgoing *)cell;
        [outgoingCell configSendingStatusWithMessage:messageItem];
    }
    
    if (!isOutgoingMessage && [cell isKindOfClass:[SKMessagesCollectionViewCellIncoming class]]) {
        // incoming message
        
        SKMessagesCollectionViewCellIncoming *incomingCell = (SKMessagesCollectionViewCellIncoming *)cell;
        [incomingCell configReceivingStatusWithMessage:messageItem];
    }
    
    return cell;
}

#pragma mark - update messages

- (void)updateItemWithUUID:(NSString *)uuid
                   handler:(void (^)(NSIndexPath *,
                                     id<SKMessageData>,
                                     JSQMessagesCollectionViewCell *))updateHandler
                  complete:(void (^)())completionCallback
{
    if ([uuid length] <= 0) {
        if (completionCallback) completionCallback();
    }
    
    __weak SKMessagesViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // locate item
        NSInteger sectionCount = [weakSelf.collectionView.dataSource numberOfSectionsInCollectionView:weakSelf.collectionView];
        NSInteger itemCount = 0;
        NSIndexPath *indexPath = nil;
        id<JSQMessageData> message = nil;
        id<SKMessageData> messageItem = nil;
        BOOL found = NO;
        for (NSInteger section = 0; section < sectionCount; section++) {
            itemCount = [weakSelf.collectionView.dataSource collectionView:weakSelf.collectionView numberOfItemsInSection:section];
            for (NSInteger i = 0; i < itemCount; i++) {
                indexPath = [NSIndexPath indexPathForItem:i inSection:section];
                message = [weakSelf.collectionView.dataSource collectionView:weakSelf.collectionView messageDataForItemAtIndexPath:indexPath];
                if ([message conformsToProtocol:@protocol(SKMessageData)]) {
                    messageItem = (id<SKMessageData>)message;
                    if ([[messageItem uuid] isEqualToString:uuid]) {
                        found = YES;
                        break;
                    }
                }
            }
        }
        
        if (found) {
            UICollectionViewCell *cell = [weakSelf.collectionView cellForItemAtIndexPath:indexPath];
            if (updateHandler) updateHandler(indexPath, messageItem, (JSQMessagesCollectionViewCell *)cell);
        }
        if (completionCallback) completionCallback();
    });
}

@end
