//
//  JSQMessagesCollectionViewCellOutgoingFile.h
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellOutgoing.h"

// layout constants

extern CGFloat const kOutgoingFileIconViewWidth;
extern CGFloat const kOutgoingFileIconViewHeight;
extern CGFloat const kOutgoingFileIconViewHeading;  // this should be the value of fileNameLabelTrailing for incoming message
extern CGFloat const kOutgoingSpacingBetweenFileIconAndFileNameLabel;
extern CGFloat const kOutgoingFileNameLabelTrailing;  // this should be the value of fileIconViewHeading for incoming message
extern CGFloat const kOutgoingFileNameLabelFontSize;
extern CGFloat const kOutgoingFileNameLabelTop;
extern CGFloat const kOutgoingVerticalSpacingBetweenFileNameLabelAndFileSizeLabel;
extern CGFloat const kOutgoingFileSizeLabelHeight;
extern CGFloat const kOutgoingFileSizeBottom;

@interface JSQMessagesCollectionViewCellOutgoingFile : JSQMessagesCollectionViewCellOutgoing

@property (weak, nonatomic, readonly) UIImageView *fileIconView;
@property (weak, nonatomic, readonly) UILabel *fileNameLabel;
@property (weak, nonatomic, readonly) UILabel *fileSizeLabel;

@end
