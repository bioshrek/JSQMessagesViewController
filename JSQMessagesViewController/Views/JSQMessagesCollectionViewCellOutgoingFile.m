//
//  JSQMessagesCollectionViewCellOutgoingFile.m
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellOutgoingFile.h"

// constants: layout constants
CGFloat const kOutgoingFileIconViewWidth = 44.0f;
CGFloat const kOutgoingFileIconViewHeight = 44.0f;
CGFloat const kOutgoingFileIconViewHeading = 15.0f;
CGFloat const kOutgoingSpacingBetweenFileIconAndFileNameLabel = 8.0f;
CGFloat const kOutgoingFileNameLabelTrailing = 20.0f;
CGFloat const kOutgoingFileNameLabelFontSize = 14.0f;
CGFloat const kOutgoingFileNameLabelTop = 14.0f;
CGFloat const kOutgoingVerticalSpacingBetweenFileNameLabelAndFileSizeLabel = 0.0f;
CGFloat const kOutgoingFileSizeLabelHeight = 21.0f;
CGFloat const kOutgoingFileSizeBottom = 14.0f;

@interface JSQMessagesCollectionViewCellOutgoingFile ()

@property (weak, nonatomic) IBOutlet UIImageView *fileIconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconViewWidthConstraint;  // 44.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconViewHeightConstraint;  // 44.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconViewHeadingContraint;  // 15.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconNameSpacing;  // 8.0f

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameLabelTrailingConstraint;  // 20.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameLabelTopConstraint;  // 15.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameSizeVerticalSpacing;  // 0.0f


@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileSizeHeight;  // 21.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileSizeBottomContraint;  // 15.0f


@end

@implementation JSQMessagesCollectionViewCellOutgoingFile

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.fileNameLabel.text = nil;
    self.fileSizeLabel.text = nil;
    self.fileIconView.image = nil;
}

@end
