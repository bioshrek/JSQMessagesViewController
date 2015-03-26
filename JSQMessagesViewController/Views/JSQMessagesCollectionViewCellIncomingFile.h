//
//  JSQMessagesCollectionViewCellIncomingFile.h
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellIncoming.h"

@interface JSQMessagesCollectionViewCellIncomingFile : JSQMessagesCollectionViewCellIncoming

@property (weak, nonatomic, readonly) UIImageView *fileIconView;
@property (weak, nonatomic, readonly) UILabel *fileNameLabel;
@property (weak, nonatomic, readonly) UILabel *fileSizeLabel;

@end
