//
//  SKTextMessagesCollectionViewCellOutgoing.m
//  JSQMessages
//
//  Created by shrek wang on 3/20/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKTextMessagesCollectionViewCellOutgoing.h"

@implementation SKTextMessagesCollectionViewCellOutgoing

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentRight;
    self.cellBottomLabel.textAlignment = NSTextAlignmentRight;
}

- (void)applyMessageContentData:(id<SKMessageContent>)messageContent
{
    [super applyMessageContentData:messageContent];
    
    self.textView.textColor = [UIColor blackColor];
}

@end
