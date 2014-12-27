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

- (void)updateTextMessageState:(SKMessageState)textMessageState forItemAtIndexPath:(NSIndexPath *)indexPath;

@end
