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

#import "JSQMessageBubbleImageDataSource.h"
#import "JSQMessageAvatarImageDataSource.h"

@interface SKMessagesViewController ()

@end

@implementation SKMessagesViewController

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // override
    [self.collectionView registerNib:[SKMessagesCollectionViewCellOutgoing nib]
          forCellWithReuseIdentifier:[SKMessagesCollectionViewCellOutgoing cellReuseIdentifier]];
    [self.collectionView registerNib:[SKMessagesCollectionViewCellOutgoing nib]
          forCellWithReuseIdentifier:[SKMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier]];
    self.outgoingCellIdentifier = [SKMessagesCollectionViewCellOutgoing cellReuseIdentifier];
    self.outgoingMediaCellIdentifier = [SKMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier];
}

#pragma mark - Collection view data source

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    id<JSQMessagesCollectionViewDataSource> messageDataSource = collectionView.dataSource;
    
    BOOL isMediaMessage = [messageDataSource collectionView:collectionView isMediaMessageForItemAtIndexPath:indexPath];
    
    if (!isMediaMessage) {
        [self renderCell:cell withTextMessageState:[self collectionView:collectionView textMessageStateForItemAtIndexPath:indexPath]];
    }
    
    return cell;
}

- (void)renderCell:(JSQMessagesCollectionViewCell *)cell withTextMessageState:(SKMessageState)messageState
{
    if (nil == cell) return;
    
    if ([cell isKindOfClass:[SKMessagesCollectionViewCellOutgoing class]]) {
        SKMessagesCollectionViewCellOutgoing *outgoingCell = (SKMessagesCollectionViewCellOutgoing *)cell;
        if (SKMessageStateSending == messageState) {
            [outgoingCell.activityIndicatorView startAnimating];
            outgoingCell.activityIndicatorView.hidden = NO;
            outgoingCell.errorIndicatorButton.hidden = YES;
        } else if (SKMessageStateSendingFailure == messageState) {
            outgoingCell.activityIndicatorView.hidden = YES;
            [outgoingCell.activityIndicatorView stopAnimating];
            outgoingCell.errorIndicatorButton.hidden = NO;
        } else {
            outgoingCell.activityIndicatorView.hidden = YES;
            [outgoingCell.activityIndicatorView stopAnimating];
            outgoingCell.errorIndicatorButton.hidden = YES;
        }
    }
}

#pragma mark - SKMessages CollectionView DataSource

// text message state
- (SKMessageState)collectionView:(JSQMessagesCollectionView *)collectionView textMessageStateForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return SKMessageStateDraft;
}

// update text message state
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateTextMessageState:(SKMessageState)textMessageState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
}

#pragma mark - Actions

- (void)updateTextMessageState:(SKMessageState)textMessageState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // update data source
    [self collectionView:self.collectionView updateTextMessageState:textMessageState forItemAtIndexPath:indexPath];
    
    // if text message visible, update text message view
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self renderCell:cell withTextMessageState:textMessageState];
}

@end
