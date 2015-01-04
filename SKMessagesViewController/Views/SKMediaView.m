//
//  SKMediaPlaceholderView.m
//  JSQMessages
//
//  Created by shrek wang on 12/23/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMediaView.h"

// K-V-O context
NSString * const kHiddenKeyPath = @"hidden";
NSString * const kAttributedTextKeyPath = @"attributedText";

// layout constants
CGFloat const kProgressHolderViewCenterY = 24.0f;
CGFloat const kCircularProgressViewCenterX = 60.0f;
CGFloat const kProgressLabelCenterX = -29.0f;
CGFloat const kErrorButtonCenterY = 24.0f;
CGFloat const kMediaIconViewCenterY = 24.0f;
//CGFloat const k

@interface SKMediaView ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIView *mediaTextInfoHolderView;
@property (nonatomic, weak) IBOutlet UILabel *mediaNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *mediaSizeLabel;


@property (weak, nonatomic) IBOutlet UIView *progressHolderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressHolderViewCenterYConstraint;
@property (nonatomic, weak) IBOutlet MRCircularProgressView *circularProgressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularProgressViewCenterXConstraint;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelCenterXConstraint;

@property (nonatomic, weak) IBOutlet UIButton *mediaIconButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaIconButtonCenterYConstraint;

@end

@implementation SKMediaView

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInitSKMediaView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self commonInitSKMediaView];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.backgroundImageView.image = nil;
    self.mediaNameLabel.attributedText = nil;
    self.mediaSizeLabel.attributedText = nil;
    self.circularProgressView.progress = 0;
    [self.mediaIconButton setImage:nil forState:UIControlStateNormal];
    [self.mediaIconButton setAttributedTitle:nil forState:UIControlStateNormal];
}

#pragma mark - KVO

- (void)commonInitSKMediaView
{
    __weak SKMediaView *weakSelf = self;
    
    // listent to visibility of text info view
    [self.mediaTextInfoHolderView addObserver:self keyPath:kHiddenKeyPath options:NSKeyValueObservingOptionNew block:^(MAKVONotification *notification) {
        id newValue = notification.newValue;
        BOOL textInfoViewHidden = newValue ? [newValue boolValue] : NO;
        
        // progress holder view center y
        weakSelf.progressHolderViewCenterYConstraint.constant = textInfoViewHidden ? 0.0f : kProgressHolderViewCenterY;
        
        // error button center y
        weakSelf.mediaIconButtonCenterYConstraint.constant = textInfoViewHidden ? 0.0f : kErrorButtonCenterY;
    }];
    
    // listen to visibility of progress label
    [self.progressLabel addObserver:self keyPath:kAttributedTextKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial block:^(MAKVONotification *notification) {
        
        id attributedText = notification.newValue;
        if ([NSNull null] == attributedText) {
            weakSelf.circularProgressViewCenterXConstraint.constant = 0;
            weakSelf.progressLabel.hidden = YES;
        } else {
            weakSelf.circularProgressViewCenterXConstraint.constant = kCircularProgressViewCenterX;
            weakSelf.progressLabel.hidden = NO;
        }
    }];
    
    [self.mediaIconButton.titleLabel setNumberOfLines:2];
}

@end
