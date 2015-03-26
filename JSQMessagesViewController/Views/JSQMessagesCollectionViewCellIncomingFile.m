//
//  JSQMessagesCollectionViewCellIncomingFile.m
//  JSQMessages
//
//  Created by shrek wang on 3/25/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellIncomingFile.h"

@interface JSQMessagesCollectionViewCellIncomingFile ()

@property (weak, nonatomic) IBOutlet UIImageView *fileIconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconViewHeadingContraint;  // 15.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconNameSpacing;  // 8.0f

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameLabelTrailingConstraint;  // 15.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameLabelTopConstraint;  // 15.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameSizeVerticalSpacing;  // 0.0f

@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileSizeHeight;  // 21.0f
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileSizeBottomContraint;  // 15.0f

@end

@implementation JSQMessagesCollectionViewCellIncomingFile

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.fileNameLabel.text = nil;
    self.fileSizeLabel.text = nil;
    self.fileIconView.image = nil;
}

@end
