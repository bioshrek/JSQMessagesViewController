//
//  SKMessagesInputToolbar.m
//  JSQMessages
//
//  Created by Shrek Wang on 3/27/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKMessagesInputToolbar.h"

#import "JSQMessagesComposerTextView.h"

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "UIView+JSQMessages.h"

#import "SKKeyboardItem.h"

#import "XHVoiceRecordHUD.h"

CGFloat const kSKMessagesInputToolbarHeightDefault = 44.0f;

static void * kJSQMessagesInputToolbarKeyValueObservingContext = &kJSQMessagesInputToolbarKeyValueObservingContext;

@interface SKMessagesInputToolbar () <UITextViewDelegate>

@property (assign, nonatomic) BOOL jsq_isObserving;

@property (weak, nonatomic) UIView *mediaKeyboardView;

@end

@implementation SKMessagesInputToolbar

#pragma mark - Life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.jsq_isObserving = NO;
    
    SKToolbarContentView *toolbarContentView = [SKToolbarContentView loadFromNib];
    toolbarContentView.frame = self.frame;
    [self addSubview:toolbarContentView];
    [self jsq_pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    _contentView = toolbarContentView;
    
    self.contentView.textView.delegate = self;
    
    [self toggleSendButtonEnabled];
}

- (void)dealloc
{
    _contentView = nil;
}

- (void)setDelegate:(id<SKToolbarCotentViewDelegate>)delegate
{
    self.contentView.delegate = delegate;
}

#pragma mark - Input toolbar

- (void)toggleSendButtonEnabled
{
    BOOL hasText = [self.contentView.textView hasText];
    // TODO:
    self.contentView.sendButton.enabled = hasText;
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView != self.contentView.textView) {
        return;
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView != self.contentView.textView) {
        return;
    }
    
    [self toggleSendButtonEnabled];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView != self.contentView.textView) {
        return NO;
    }
    
    [self toggleSendButtonEnabled];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView != self.contentView.textView) {
        return;
    }
    
    [textView resignFirstResponder];
}

@end
