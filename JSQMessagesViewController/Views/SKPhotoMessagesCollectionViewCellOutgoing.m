//
//  SKPhotoMessagesCollectionViewCellOutgoing.m
//  JSQMessages
//
//  Created by shrek wang on 3/20/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKPhotoMessagesCollectionViewCellOutgoing.h"

@implementation SKPhotoMessagesCollectionViewCellOutgoing

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentRight;
    self.cellBottomLabel.textAlignment = NSTextAlignmentRight;
}

@end
