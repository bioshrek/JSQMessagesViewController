//
//  SKMessagesViewController.h
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessagesViewController.h"

#import "SKMessageData.h"

#import "MRProgress.h"

#import "SKMessagesCollectionViewDataSource.h"



@interface SKMessagesViewController : JSQMessagesViewController <SKMessagesCollectionViewDataSource>

#pragma mark - Actions

// update mesage state
// notice: called in UI thread
- (void)updateMessageState:(SKMessageState)messageState forItemAtIndexPath:(NSIndexPath *)indexPath;

// update media state
// notice: called in UI thread
- (void)updateMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath;

// update media message progress
// notice: called in UI thread
- (void)updateMediaProgress:(NSProgress *)progress forItemAtIndexPath:(NSIndexPath *)indexPath;

@end
