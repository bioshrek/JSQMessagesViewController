//
//  SKMessagesCollectionViewDataSource.h
//  JSQMessages
//
//  Created by shrek wang on 12/27/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewDataSource.h"

// type: media state

typedef NS_ENUM(NSInteger, SKMessageMediaState) {
    SKMessageMediaStateDraft = 1,
    SKMessageMediaStateUploading = 2,
    SKMessageMediaStateUploadingFailure = 3,
    SKMessageMediaStateUploaded = 4,
    SKMessageMediaStateToBeDownloaded = 5,
    SKMessageMediaStateDownloading = 6,
    SKMessageMediaStateDownloadingFailure = 7,
    SKMessageMediaStateDownloaded = 8,
    SKMessageMediaStateReviewed = 9,
};

@protocol SKMessagesCollectionViewDataSource <NSObject>

@optional

// message state
- (SKMessageState)collectionView:(JSQMessagesCollectionView *)collectionView messageStateForItemAtIndexPath:(NSIndexPath *)indexPath;

// update message state
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateMessageState:(SKMessageState)textMessageState forItemAtIndexPath:(NSIndexPath *)indexPath;

// media message state
- (SKMessageMediaState)collectionView:(JSQMessagesCollectionView *)collectionView mediaStateForItemAtIndexPath:(NSIndexPath *)indexPath;

// update media message state
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath;

// media message progress
- (NSProgress *)collectionView:(JSQMessagesCollectionView *)collectionView mediaProgressForItemAtIndexPath:(NSIndexPath *)indexPath;

// update media message progress
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateMediaProgress:(NSProgress *)progress forItemAtIndexPath:(NSIndexPath *)indexPath;

// media title
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView mediaNameAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath;

// media size
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView mediaSizeAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath;

// should show media title, size for states
- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView shouldShowMediaTextInfoForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath;

// media icon for states
- (UIImage *)collectionView:(JSQMessagesCollectionView *)collectionView mediaIconForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath;

// media description for states
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView mediaDescriptionForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath;

// media thumbnail
- (UIImage *)collectionView:(JSQMessagesCollectionView *)collectionView thumbnailForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath;

@end
