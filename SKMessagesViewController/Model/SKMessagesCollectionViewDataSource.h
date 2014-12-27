//
//  SKMessagesCollectionViewDataSource.h
//  JSQMessages
//
//  Created by shrek wang on 12/27/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewDataSource.h"

@protocol SKMessagesCollectionViewDataSource <NSObject>

@optional

// text message state
- (SKMessageState)collectionView:(JSQMessagesCollectionView *)collectionView textMessageStateForItemAtIndexPath:(NSIndexPath *)indexPath;

// update text message state
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateTextMessageState:(SKMessageState)textMessageState forItemAtIndexPath:(NSIndexPath *)indexPath;

@end
