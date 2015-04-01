//
//  SKToolbarContentView.m
//  JSQMessages
//
//  Created by Shrek Wang on 3/31/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKToolbarContentView.h"

#import "SKKeyboardItem.h"

#import "XHVoiceRecordHUD.h"

#import "UIView+JSQMessages.h"

#import "SKToolbar.h"

@interface SKToolbarContentView ()

@property (weak, nonatomic) IBOutlet UIButton *voiceRecordTriggerButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceRecordStarterButton;

@property (weak, nonatomic) IBOutlet UIButton *emoticonTriggerButton;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *mediaTriggerButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;


@end

@implementation SKToolbarContentView

#pragma mark - Life cycle

+ (instancetype)loadFromNib
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
    NSArray *views = [nib instantiateWithOwner:nil options:nil];
    return [views firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self jsq_configureTextView:self.textView];
    [self configureButton:self.sendButton];
    [self configureButton:self.voiceRecordStarterButton];
    
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)jsq_configureTextView:(UITextView *)textView
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    CGFloat cornerRadius = 6.0f;
    
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.borderWidth = 0.5f;
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.layer.cornerRadius = cornerRadius;
    
    textView.scrollIndicatorInsets = UIEdgeInsetsMake(cornerRadius, 0.0f, cornerRadius, 0.0f);
    
    textView.textContainerInset = UIEdgeInsetsMake(4.0f, 2.0f, 4.0f, 2.0f);
    textView.contentInset = UIEdgeInsetsMake(1.0f, 0.0f, 1.0f, 0.0f);
    
    textView.scrollEnabled = YES;
    textView.scrollsToTop = NO;
    textView.userInteractionEnabled = YES;
    
    textView.font = [UIFont systemFontOfSize:16.0f];
    textView.textColor = [UIColor blackColor];
    textView.textAlignment = NSTextAlignmentNatural;
    
    textView.contentMode = UIViewContentModeRedraw;
    textView.dataDetectorTypes = UIDataDetectorTypeNone;
    textView.keyboardAppearance = UIKeyboardAppearanceDefault;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDefault;
    
    textView.text = nil;
}

- (void)configureButton:(UIButton *)button
{
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.cornerRadius = 5.0f;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIView overrides

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.textView setNeedsDisplay];
}

@end
