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


// Audio Record Session

typedef NS_ENUM(NSInteger, SKAudioRecordSessionState) {
    SKAudioRecordSessionStateOff = 0,
    SKAudioRecordSessionStateReady = 1,
    SKAudioRecordSessionStateRecording = 2,
    SKAudioRecordSessionStateCanceling = 3,
    SKAudioRecordSessionStateCompleted = 4,
    SKAudioRecordSessionStateCanceled = 5,
    SKAudioRecordSessionStateError = 6
};

// System Keyboard State

typedef NS_ENUM(NSInteger, SKSystemKeyboardStyle) {
    SKSystemKeyboardStyleDefault = 0,
    SKSystemKeyboardStyleEmoticon = 1,
};

CGFloat const kSKMessagesInputToolbarHeightDefault = 44.0f;

static void * kJSQMessagesInputToolbarKeyValueObservingContext = &kJSQMessagesInputToolbarKeyValueObservingContext;

@interface SKMessagesInputToolbar () <SKKeyboardManager>

@property (assign, nonatomic) BOOL jsq_isObserving;

@property (weak, nonatomic) UIButton *voiceRecordTriggerButton;
@property (weak, nonatomic) UIButton *voiceRecordStarterButton;

@property (weak, nonatomic) UIButton *emoticonTriggerButton;

@property (weak, nonatomic) UIButton *sendButton;
@property (weak, nonatomic) UIButton *mediaTriggerButton;

@property (strong, nonatomic) NSMutableArray *keyboardItems;
@property (weak, nonatomic) SKKeyboardItem *voiceRecordKeyboard;
@property (weak, nonatomic) SKKeyboardItem *systemKeyboard;
@property (weak, nonatomic) SKKeyboardItem *mediaKeyboard;

@property (weak, nonatomic) UIView *mediaKeyboardView;

@property (assign, nonatomic) SKSystemKeyboardStyle systemKeyboardStyle;

@property (assign, nonatomic) SKAudioRecordSessionState audioRecordSessionState;

@end

@implementation SKMessagesInputToolbar

#pragma mark - Getters

- (NSMutableArray *)keyboardItems
{
    if (!_keyboardItems) {
        _keyboardItems = [[NSMutableArray alloc] init];
    }
    return _keyboardItems;
}

#pragma mark - Life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.jsq_isObserving = NO;
    
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JSQMessagesToolbarContentView class]) owner:nil options:nil];
    JSQMessagesToolbarContentView *toolbarContentView = [nibViews firstObject];
    toolbarContentView.frame = self.frame;
    [self addSubview:toolbarContentView];
    [self jsq_pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    _contentView = toolbarContentView;
    
    [self jsq_addObservers];
    
    UIButton *voiceRecordStarterButton = [JSQMessagesToolbarButtonFactory voiceRecordStarterButton];
    [self.contentView addSubview:voiceRecordStarterButton];
    JSQMessagesComposerTextView *textView = self.contentView.textView;
    [voiceRecordStarterButton jsq_pinAllEdgesOfSubview:textView];
    voiceRecordStarterButton.hidden = YES;
    _voiceRecordStarterButton = voiceRecordStarterButton;
    
    
    UIView *leftBarContainerView = self.contentView.leftBarButtonContainerView;
    UIButton *voiceRecordTriggerButton = [JSQMessagesToolbarButtonFactory voiceRecordTriggerButton];
    [leftBarContainerView addSubview:voiceRecordTriggerButton];
    _voiceRecordTriggerButton = voiceRecordTriggerButton;
    UIButton *emoticonTriggerButton = [JSQMessagesToolbarButtonFactory emoticonTriggerButton];
    [leftBarContainerView addSubview:emoticonTriggerButton];
    _emoticonTriggerButton = emoticonTriggerButton;
    [leftBarContainerView jsq_pinSubview:voiceRecordTriggerButton toEdge:NSLayoutAttributeTop];
    [leftBarContainerView jsq_pinSubview:voiceRecordTriggerButton toEdge:NSLayoutAttributeLeading];
    [leftBarContainerView jsq_pinSubview:voiceRecordTriggerButton toEdge:NSLayoutAttributeBottom];
    [leftBarContainerView jsq_pinSubview:emoticonTriggerButton toEdge:NSLayoutAttributeTop];
    [leftBarContainerView jsq_pinSubview:emoticonTriggerButton toEdge:NSLayoutAttributeRight];
    [leftBarContainerView jsq_pinSubview:emoticonTriggerButton toEdge:NSLayoutAttributeBottom];
    [voiceRecordTriggerButton jsq_setLayoutAttribute:NSLayoutAttributeTrailing otherView:emoticonTriggerButton otherAttribute:NSLayoutAttributeLeading constant:0.0f];
    
    UIView *rightBarContainerView = self.contentView.rightBarButtonContainerView;
    UIButton *sendButton = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
    [rightBarContainerView addSubview:sendButton];
    [rightBarContainerView jsq_pinAllEdgesOfSubview:sendButton];
    _sendButton = sendButton;
    UIButton *mediaTriggerButton = [JSQMessagesToolbarButtonFactory mediaTriggerButton];
    [rightBarContainerView addSubview:mediaTriggerButton];
    [rightBarContainerView jsq_pinAllEdgesOfSubview:mediaTriggerButton];
    _mediaTriggerButton = mediaTriggerButton;
    
    [self toggleSendButtonEnabled];
}

- (void)dealloc
{
    [self jsq_removeObservers];
    _contentView = nil;
}

#pragma mark - Actions

- (void)jsq_leftBarButtonPressed:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender];
}

- (void)jsq_rightBarButtonPressed:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressRightBarButton:sender];
}

#pragma mark - Input toolbar

- (void)toggleSendButtonEnabled
{
    BOOL hasText = [self.contentView.textView hasText];
    // TODO:
    self.contentView.rightBarButtonItem.enabled = hasText;
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJSQMessagesInputToolbarKeyValueObservingContext) {
        if (object == self.contentView) {
            
            if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem))]) {
                
                [self.contentView.leftBarButtonItem removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.leftBarButtonItem addTarget:self
                                                       action:@selector(jsq_leftBarButtonPressed:)
                                             forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {
                
                [self.contentView.rightBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.rightBarButtonItem addTarget:self
                                                        action:@selector(jsq_rightBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
            }
            
            [self toggleSendButtonEnabled];
        }
    }
}

- (void)jsq_addObservers
{
    if (self.jsq_isObserving) {
        return;
    }
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];
    
    self.jsq_isObserving = YES;
}

- (void)jsq_removeObservers
{
    if (!_jsq_isObserving) {
        return;
    }
    
    @try {
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];
        
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];
    }
    @catch (NSException *__unused exception) { }
    
    _jsq_isObserving = NO;
}

#pragma mark - Audio Record Session State Change

- (void)setupKeyboardItems
{
    __weak SKMessagesInputToolbar *weakSelf = self;
    
    // audio record trigger button
    SKKeyboardItem *audioRecordKeyboard = [[SKKeyboardItem alloc] initWithIdentifier:@"audioRecordKeyboard" onBlock:^{
        [weakSelf setAudioRecordSessionState:SKAudioRecordSessionStateReady];
    } offBlock:^(SKKeyboardItem *sender) {
        [weakSelf setAudioRecordSessionState:SKAudioRecordSessionStateOff];
    } keyboardManager:self];
    [self.keyboardItems addObject:audioRecordKeyboard];
    _voiceRecordKeyboard = audioRecordKeyboard;
    
    SKKeyboardItem *systemKeyboard = [[SKKeyboardItem alloc] initWithIdentifier:@"systemKeyboard" onBlock:^{
        if (![self.contentView.textView isFirstResponder]) {
            [self.contentView.textView becomeFirstResponder];
        }
    } offBlock:^(SKKeyboardItem *sender) {
        if ([self.contentView.textView isFirstResponder]) {
            [self.contentView.textView resignFirstResponder];
        }
    } keyboardManager:self];
    [self.keyboardItems addObject:systemKeyboard];
    _systemKeyboard = systemKeyboard;
    
    SKKeyboardItem *mediaKeyboard = [[SKKeyboardItem alloc] initWithIdentifier:@"mediaKeyboard" onBlock:^{
        [weakSelf turnMediaKeyboardEnterState:YES sender:nil];
    } offBlock:^(SKKeyboardItem *sender) {
        [weakSelf turnMediaKeyboardEnterState:NO sender:sender];
    } keyboardManager:self];
    [self.keyboardItems addObject:mediaKeyboard];
    _mediaKeyboard = mediaKeyboard;
}

#pragma mark - Voice Record Keyboard

- (void)setupActionHandlersForVoiceRecordStarterButton
{
    // Audio Record Session State Transation:
    
    // [off] - voiceRecordTrigger button TOUCH UP INSIDE -> [ready]
    // [ready] - press any buttom except voiceRecordStarterButton -> [off]
    // [ready] - voiceRecordStarterButton TOUCH DOWN -> [recording]
    // [recording] - error happned during recording -> [error]
    // [error] - after error handled, few seconds later -> [ready]
    // [recording] - voiceRecordStaterButton TOUCH UP INSIDE -> [completed]
    // [completed] - after handling logic, few seconds later -> [ready]
    // [recording] - voiceRecordStarterButton TOUCH DRAGE EXIT -> [canceling]
    // [canceling] - voiceRecordStarterButton TOUCH DRAGE ENTER -> [recording]
    // [canceling] - voiceRecordStarterButton TOUCH UP OUTSIDE -> [canceled]
    // [canceled] - after handling logic, few seconds later -> [ready]
    
    [self.voiceRecordTriggerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.voiceRecordTriggerButton addTarget:self.voiceRecordKeyboard action:@selector(triggered) forControlEvents:UIControlEventTouchUpInside];
    
    [self.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDown];
    [self.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDragExit];
    [self.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchDragExist) forControlEvents:UIControlEventTouchDragExit];
    [self.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDragEnter];
    [self.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [self.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpOutside];
    [self.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)voiceRecordStarterButtonTouchDown
{
    if (SKAudioRecordSessionStateReady == self.audioRecordSessionState) {
        self.audioRecordSessionState = SKAudioRecordSessionStateRecording;
    }
}

- (void)voiceRecordStarterButtonTouchUpInside
{
    if (SKAudioRecordSessionStateRecording == self.audioRecordSessionState) {
        self.audioRecordSessionState = SKAudioRecordSessionStateCompleted;
    }
}

- (void)voiceRecordStarterButtonTouchDragExist
{
    if (SKAudioRecordSessionStateRecording == self.audioRecordSessionState) {
        self.audioRecordSessionState = SKAudioRecordSessionStateCanceling;
    }
}

- (void)voiceRecordStarterButtonTouchDragEnter
{
    if (SKAudioRecordSessionStateCanceling == self.audioRecordSessionState) {
        self.audioRecordSessionState = SKAudioRecordSessionStateRecording;
    }
}

- (void)voiceRecordStarterButtonTouchUpOutside
{
    if (SKAudioRecordSessionStateCanceling == self.audioRecordSessionState) {
        self.audioRecordSessionState = SKAudioRecordSessionStateCanceled;
    }
}

- (void)setAudioRecordSessionState:(SKAudioRecordSessionState)state
{
    __weak SKMessagesInputToolbar *weakSelf = self;
    
    switch (state) {
        case SKAudioRecordSessionStateOff: {
            // show voice trigger button
            // hide voice record starter button
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:YES];
            self.voiceRecordStarterButton.hidden = YES;
            [[XHVoiceRecordHUD sharedInstance] dismissCompleted:nil];
        } break;
        case SKAudioRecordSessionStateReady: {
            // hide voice trigger button
            // show voice record starter button
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            self.voiceRecordStarterButton.hidden = NO;
            [[XHVoiceRecordHUD sharedInstance] dismissCompleted:nil];
        } break;
        case SKAudioRecordSessionStateRecording: {
            // hide voice trigger button
            // voice record button visible and pressed
            // show recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            self.voiceRecordStarterButton.hidden = NO;
            [[XHVoiceRecordHUD sharedInstance] startRecordingHUDAtView:self.superview];
            
            // start recording audio
            [self.delegate startRecordingAudioWithErrorHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.audioRecordSessionState = SKAudioRecordSessionStateError;
                });
            }];
        } break;
        case SKAudioRecordSessionStateCanceling: {
            // hide voice trigger button
            // voice record button visible and pressed
            // hide recording HUD
            // show canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            self.voiceRecordStarterButton.hidden = NO;
            [[XHVoiceRecordHUD sharedInstance] didCanceling];
            
            // continue recording audio
        } break;
        case SKAudioRecordSessionStateCanceled: {
            // hide trigger button
            // voice record button visible
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            self.voiceRecordStarterButton.hidden = NO;
            [[XHVoiceRecordHUD sharedInstance] dismissCompleted:nil];
            
            // stop recording audio
            // discard recorded data
            // transation to SKAudioRecordSessionStateReady
            [self.delegate cancelRecordingAudioWithCompletionHandler:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.audioRecordSessionState = SKAudioRecordSessionStateReady;
                });
            }];
        } break;
        case SKAudioRecordSessionStateCompleted: {
            // hide trigger button
            // voice record button visible
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            self.voiceRecordStarterButton.hidden = NO;
            [[XHVoiceRecordHUD sharedInstance] dismissCompleted:nil];
            
            // stop recording audio
            // trigger sending audio message
            // transation to SKAudioRecordSessionStateReady state
            [self.delegate endRecordingAudioWithCompletionHandler:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.audioRecordSessionState = SKAudioRecordSessionStateReady;
                });
            }];
        } break;
        case SKAudioRecordSessionStateError: {
            // hide trigger button
            // voice record button visible and pressed
            // hide recording HUD
            // hide canceling HUD
            // show error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            self.voiceRecordStarterButton.hidden = NO;
            [[XHVoiceRecordHUD sharedInstance] showError];
            
            // stop recording audio
            // discard recorded data
            // transation to SKAudioRecordSessionStateReady state
            
        } break;
        default:
            break;
    }
}

- (void)setVoiceRecordTriggerButtonVisible:(BOOL)visible
{
    UIImage *normalImage = nil;
    UIImage *highlightedImage = nil;
    
    if (visible) {
        normalImage = [UIImage imageNamed:@"voice"];
        highlightedImage = [UIImage imageNamed:@"voice_HL"];
    } else {
        normalImage = [UIImage imageNamed:@"keyboard"];
        highlightedImage = [UIImage imageNamed:@"keyboard_HL"];
    }
    
    [self.voiceRecordTriggerButton setImage:normalImage forState:UIControlStateNormal];
    [self.voiceRecordTriggerButton setImage:highlightedImage forState:UIControlStateHighlighted];
}

#pragma mark - Media keyboard

- (void)setupActionHandlersForMediaKeyboardTriggerButton
{
    // [off] - mediaKeyboardTriggerButton TOUCH UP INSIDE -> [on]
    // [on] - any trigger button TOUCH UP INSIDE -> [off]
    
    [self.mediaTriggerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.mediaTriggerButton addTarget:self.mediaKeyboard action:@selector(triggered) forControlEvents:UIControlEventTouchUpInside];
}

- (void)turnMediaKeyboardEnterState:(BOOL)on sender:(SKKeyboardItem *)otherKeyboard
{
    if (on) {
        // hide mediaKeyboardTriggerButton
        // show media keyboard
        
        self.mediaTriggerButton.hidden = NO;
        self.sendButton.hidden = YES;
        UIView *keyboardView = [self.delegate mediaKeyboardView];
        [self.superview addSubview:keyboardView];
        [self jsq_setLayoutAttribute:NSLayoutAttributeBottom otherView:keyboardView otherAttribute:NSLayoutAttributeTop constant:0];
        _mediaKeyboardView = keyboardView;
        
    } else {  // off
        // show mediaKeyboardTriggerButton
        // hide mediaKeyboard
        
        self.mediaTriggerButton.hidden = YES;
        self.sendButton.hidden = NO;
        [self.mediaKeyboardView removeFromSuperview];
    }
}

#pragma mark - System keyboard

- (void)setupActionHandlersForSystemKeyboardTrigger
{
    // [off] - text view became first responder -> [default]
    // [default] - emoticon trigger button TOUCH UP INSIDE -> [emoticon]
    // [emoticon] - emoticon trigger button TOUCH UP INSIDE -> [default]
    // [off] - emoticon trigger button TOUCH UP INSIDE -> [emoticon]
    // [default/emoticon] - any trigger button pressed, or pin keybord to resign first responder -> [off]
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [self.emoticonTriggerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.emoticonTriggerButton addTarget:self action:@selector(emoticonTriggerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)emoticonTriggerButtonPressed:(UIButton *)sender
{
    if (self.systemKeyboard.isOn) {  // emoticon button act as a switch button
        [self switchSystemKeyboardStyle];
        [self keyboardWasShown:nil];
    } else {  // only when system keyboard off, emoticon button act as a trigger button
        self.systemKeyboardStyle = SKSystemKeyboardStyleEmoticon;
        [self.systemKeyboard triggered];
    }
}

- (void)switchSystemKeyboardStyle
{
    SKSystemKeyboardStyle style = SKSystemKeyboardStyleDefault;
    
    switch (self.systemKeyboardStyle) {
        case SKSystemKeyboardStyleDefault:
            style = SKSystemKeyboardStyleEmoticon;
            break;
        case SKSystemKeyboardStyleEmoticon:
            style = SKSystemKeyboardStyleDefault;
            break;
        default:
            break;
    }
    
    self.systemKeyboardStyle = style;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // turn off other keyboards
    self.systemKeyboard.on = YES;
    [self turnOffOtherKeyboardItemsWithSender:self.systemKeyboard];
    
    switch (self.systemKeyboardStyle) {
        case SKSystemKeyboardStyleDefault: {
            // show default style keyboard
            // show send button
            // show emoticon trigger button
            // text view become first responder
            UITextView *textView = self.contentView.textView;
            textView.inputView = nil;
            [textView reloadInputViews];
            self.mediaTriggerButton.hidden = YES;
            self.sendButton.hidden = NO;
            [self.emoticonTriggerButton setImage:[UIImage imageNamed:@"smiling-face"] forState:UIControlStateNormal];
            
        } break;
        case SKSystemKeyboardStyleEmoticon: {
            // show emoticon keyboard
            // show send button
            // hide emoticon trigger button
            // text view become first responder
            UITextView *textView = self.contentView.textView;
            textView.inputView = [self.delegate emoticonKeyboardView];
            [textView reloadInputViews];
            self.mediaTriggerButton.hidden = YES;
            self.sendButton.hidden = NO;
            [self.emoticonTriggerButton setImage:[UIImage imageNamed:@"laughing-face"] forState:UIControlStateNormal];
            
        } break;
        default: break;
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.systemKeyboard.on = NO;
    UITextView *textView = self.contentView.textView;
    textView.inputView = nil;
    self.mediaTriggerButton.hidden = NO;
    self.sendButton.hidden = YES;
    self.systemKeyboardStyle = SKSystemKeyboardStyleDefault;
    [self.emoticonTriggerButton setImage:[UIImage imageNamed:@"smiling-face"] forState:UIControlStateNormal];
}

#pragma mark - SKKeyboardManager

- (void)turnOffOtherKeyboardItemsWithSender:(SKKeyboardItem *)sender
{
    [self.keyboardItems enumerateObjectsUsingBlock:^(SKKeyboardItem *keyboardItem, NSUInteger idx, BOOL *stop) {
        if (![keyboardItem isEqual:sender]) {
            [keyboardItem turnOffByOtherKeyboard:sender];
        }
    }];
}

@end
