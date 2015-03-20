//
//  SKTextMessagesCollectionViewCellIncoming.m
//  JSQMessages
//
//  Created by shrek wang on 3/20/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKTextMessagesCollectionViewCellIncoming.h"

@implementation SKTextMessagesCollectionViewCellIncoming

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
    self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)applyMessageContentData:(id<SKMessageContent>)messageContent
{
    [super applyMessageContentData:messageContent];
    
    self.textView.textColor = [UIColor whiteColor];
}

@end
