//
//  SKMessagesViewController.m
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMessagesViewController.h"

#import "JSQMessagesCollectionViewCellIncoming.h"
#import "SKMessagesCollectionViewCellOutgoing.h"

#import "SKMessageData.h"

#import "JSQMessageBubbleImageDataSource.h"
#import "JSQMessageAvatarImageDataSource.h"

#import "SKMediaViewIncoming.h"
#import "SKMediaViewOutgoing.h"

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
    
    // message state
    [self renderCell:cell withMessageState:[self collectionView:collectionView messageStateForItemAtIndexPath:indexPath] isMediaMessage:isMediaMessage];
    
    return cell;
}

- (void)renderCell:(JSQMessagesCollectionViewCell *)cell withMessageState:(SKMessageState)messageState isMediaMessage:(BOOL)isMediaMessage
{
    if (nil == cell) return;
    
    if ([cell isKindOfClass:[SKMessagesCollectionViewCellOutgoing class]]) {  // outgoing
        SKMessagesCollectionViewCellOutgoing *outgoingCell = (SKMessagesCollectionViewCellOutgoing *)cell;
        
        if (isMediaMessage) {  // media message
            [outgoingCell.activityIndicatorView removeFromSuperview];
            [outgoingCell.errorIndicatorButton removeFromSuperview];
        } else {  // text message
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
}

- (void)renderMediaView:(SKMediaView *)skMediaView withMediaState:(SKMessageMediaState)mediaState indexPath:(NSIndexPath *)indexPath
{
    if (nil == skMediaView) return;
    
    NSAttributedString *mediaDescriptionForState = nil;
    UIImage *mediaIconForState = nil;
    NSAttributedString *mediaNameText = nil;
    NSAttributedString *mediaSizeText = nil;
    BOOL shouldShowMediaTextInfo = NO;
    
    // text info view
    shouldShowMediaTextInfo = [self collectionView:self.collectionView shouldShowMediaTextInfoForMediaState:mediaState forItemAtIndexPath:indexPath];
    if (shouldShowMediaTextInfo) {
        mediaNameText = [self collectionView:self.collectionView mediaNameAttributedTextForItemAtIndexPath:indexPath];
        mediaSizeText = [self collectionView:self.collectionView mediaSizeAttributedTextForItemAtIndexPath:indexPath];
        
        skMediaView.mediaTextInfoHolderView.hidden = NO;
        skMediaView.mediaNameLabel.attributedText = mediaNameText;
        skMediaView.mediaSizeLabel.attributedText = mediaSizeText;
    } else {
        skMediaView.mediaTextInfoHolderView.hidden = YES;
    }
    
    // media icon, media description, progress
    mediaDescriptionForState = [self collectionView:self.collectionView mediaDescriptionForMediaState:mediaState forItemAtIndexPath:indexPath];
    if (SKMessageMediaStateUploading == mediaState ||
               SKMessageMediaStateDownloading == mediaState) {
        skMediaView.mediaIconButton.hidden = YES;
        
        skMediaView.circularProgressView.borderWidth = 1.0f;
        skMediaView.circularProgressView.lineWidth = 25.0f;
        [skMediaView.circularProgressView.valueLabel removeFromSuperview];
        skMediaView.progressLabel.attributedText = mediaDescriptionForState;
        skMediaView.progressHolderView.hidden = NO;  // show progress
    } else {
        mediaIconForState = [self collectionView:self.collectionView mediaIconForMediaState:mediaState forItemAtIndexPath:indexPath];
        
        if (mediaIconForState || mediaDescriptionForState) {
            [skMediaView.mediaIconButton setAttributedTitle:mediaDescriptionForState forState:UIControlStateNormal];
            [skMediaView.mediaIconButton setImage:mediaIconForState forState:UIControlStateNormal];
            skMediaView.mediaIconButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
            skMediaView.mediaIconButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
            skMediaView.mediaIconButton.hidden = NO;
        } else {
            skMediaView.mediaIconButton.hidden = YES;
        }
        
        skMediaView.progressHolderView.hidden = YES;  // hide progress
    }
}

- (void)renderMediaView:(SKMediaView *)skMediaView withMediaProgress:(NSProgress *)progress
{
    if (nil == skMediaView || nil == progress) return;
    
    skMediaView.circularProgressView.progress = progress.fractionCompleted;
}

#pragma mark - JSQMessages CollectionView DataSource

// media view display size
- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView mediaViewDisplaySizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGSizeMake(315.0f, 225.0f);
    }
    
    return CGSizeMake(210.0f, 150.0f);
}

// media view
- (JSQMediaView *)collectionView:(JSQMessagesCollectionView *)collectionView mediaViewForItemAtIndexPath:(NSIndexPath *)indexPath isOutgoing:(BOOL)isOutgoing
{
    NSString *reuseIdentifier = isOutgoing ? [SKMediaViewOutgoing reuseIdentifier] : [SKMediaViewIncoming reuseIdentifier];
    JSQMediaView *mediaView = [collectionView dequeueReusableMediaViewWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    SKMediaView *skMediaView = (SKMediaView *)mediaView;
    NSAssert(nil != skMediaView, @"media view can't be nil");
    
    // media state
    SKMessageMediaState mediaState = [self collectionView:collectionView mediaStateForItemAtIndexPath:indexPath];
    [self renderMediaView:skMediaView withMediaState:mediaState indexPath:indexPath];
    
    // media progress
    if (SKMessageMediaStateUploading == mediaState ||
        SKMessageMediaStateDownloading == mediaState) {
        [self renderMediaView:skMediaView withMediaProgress:[self collectionView:collectionView mediaProgressForItemAtIndexPath:indexPath]];
    }
    
    // media thumbnail
    UIImage *thumbnail = [self collectionView:collectionView thumbnailForMediaState:mediaState forItemAtIndexPath:indexPath];
    skMediaView.backgroundImageView.image = thumbnail;
    
    return mediaView;
}

// media placeholder view
- (JSQMediaView *)collectionView:(JSQMessagesCollectionView *)collectionView mediaPlaceholderViewForItemAtIndexPath:(NSIndexPath *)indexPath isOutgoing:(BOOL)isOutgoing
{
    NSString *reuseIdentifier = isOutgoing ? [SKMediaViewOutgoing reuseIdentifier] : [SKMediaViewIncoming reuseIdentifier];
    JSQMediaView *mediaView = [collectionView dequeueReusableMediaViewWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    SKMediaView *skMediaView = (SKMediaView *)mediaView;
    NSAssert(nil != skMediaView, @"media view can't be nil");
    
    // media state
    SKMessageMediaState mediaState = [self collectionView:collectionView mediaStateForItemAtIndexPath:indexPath];
    [self renderMediaView:skMediaView withMediaState:mediaState indexPath:indexPath];
    
    // media progress
    if (SKMessageMediaStateUploading == mediaState ||
        SKMessageMediaStateDownloading == mediaState) {
        [self renderMediaView:skMediaView withMediaProgress:[self collectionView:collectionView mediaProgressForItemAtIndexPath:indexPath]];
    }
    
    // media thumbnail
    UIImage *thumbnail = [self collectionView:collectionView thumbnailForMediaState:mediaState forItemAtIndexPath:indexPath];
    skMediaView.backgroundImageView.image = thumbnail;
    
    return mediaView;
}

#pragma mark - SKMessages CollectionView DataSource

// message state
- (SKMessageState)collectionView:(JSQMessagesCollectionView *)collectionView messageStateForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return SKMessageStateDraft;
}

// update message state
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateMessageState:(SKMessageState)textMessageState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
}

// media state
- (SKMessageMediaState)collectionView:(JSQMessagesCollectionView *)collectionView mediaStateForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return SKMessageMediaStateDraft;
}

// update media state
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
}

// media message progress
- (NSProgress *)collectionView:(JSQMessagesCollectionView *)collectionView mediaProgressForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

// update media message progress
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateMediaProgress:(NSProgress *)progress forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
}

// media title
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView mediaNameAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

// media size
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView mediaSizeAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

// should show media title, size for states
- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView shouldShowMediaTextInfoForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return NO;
}

// media icon for states
- (UIImage *)collectionView:(JSQMessagesCollectionView *)collectionView mediaIconForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

// media description for states
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView mediaDescriptionForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

// media thumbnail
- (UIImage *)collectionView:(JSQMessagesCollectionView *)collectionView thumbnailForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

#pragma mark - Actions

- (void)updateMessageState:(SKMessageState)messageState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // update data source
    [self collectionView:self.collectionView updateMessageState:messageState forItemAtIndexPath:indexPath];
    
    BOOL isMediaMessage = [self.collectionView.dataSource collectionView:self.collectionView isMediaMessageForItemAtIndexPath:indexPath];
    
    // if message visible, update message view
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self renderCell:cell withMessageState:messageState isMediaMessage:isMediaMessage];
}

- (void)updateMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // update data source
    [self collectionView:self.collectionView updateMediaState:mediaState forItemAtIndexPath:indexPath];
    
    // if media view visible, update media view
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    SKMediaView *skMediaView = nil;
    if ([cell isKindOfClass:[SKMessagesCollectionViewCellOutgoing class]]) {
        SKMessagesCollectionViewCellOutgoing *outgoingCell = (SKMessagesCollectionViewCellOutgoing *)cell;
        JSQMediaView *mediaView = outgoingCell.mediaView;
        
        if ([mediaView isKindOfClass:[SKMediaView class]]) {
            skMediaView = (SKMediaView *)mediaView;
        }
    } else if ([cell isKindOfClass:[JSQMessagesCollectionViewCellIncoming class]]) {
        JSQMessagesCollectionViewCellIncoming *incomingCell = (JSQMessagesCollectionViewCellIncoming *)cell;
        JSQMediaView *mediaView = incomingCell.mediaView;
        
        if ([mediaView isKindOfClass:[SKMediaView class]]) {
            skMediaView = (SKMediaView *)mediaView;
        }
    }
    if (nil == skMediaView) return;
    
    [self renderMediaView:skMediaView withMediaState:mediaState indexPath:indexPath];
}

- (void)updateMediaProgress:(NSProgress *)progress forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // update data source
    [self collectionView:self.collectionView updateMediaProgress:progress forItemAtIndexPath:indexPath];
    
    // if media view visible, update media view
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    SKMediaView *skMediaView = nil;
    if ([cell isKindOfClass:[SKMessagesCollectionViewCellOutgoing class]]) {
        SKMessagesCollectionViewCellOutgoing *outgoingCell = (SKMessagesCollectionViewCellOutgoing *)cell;
        JSQMediaView *mediaView = outgoingCell.mediaView;
        
        if ([mediaView isKindOfClass:[SKMediaView class]]) {
            skMediaView = (SKMediaView *)mediaView;
        }
    } else if ([cell isKindOfClass:[JSQMessagesCollectionViewCellIncoming class]]) {
        JSQMessagesCollectionViewCellIncoming *incomingCell = (JSQMessagesCollectionViewCellIncoming *)cell;
        JSQMediaView *mediaView = incomingCell.mediaView;
        
        if ([mediaView isKindOfClass:[SKMediaView class]]) {
            skMediaView = (SKMediaView *)mediaView;
        }
    }
    if (nil == skMediaView) return;
    
    [self renderMediaView:skMediaView withMediaProgress:progress];
}

@end
