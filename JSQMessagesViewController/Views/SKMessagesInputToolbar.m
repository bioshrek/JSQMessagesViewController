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
    SKAudioRecordSessionStatePaused = 3,
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

@interface SKMessagesInputToolbar () <SKToolbarKeyboardDelegate, UITextViewDelegate, SKKeyboardManager>

@property (assign, nonatomic) BOOL jsq_isObserving;

@property (strong, nonatomic) NSMutableArray *keyboardItems;
@property (weak, nonatomic) SKKeyboardItem *voiceRecordKeyboard;
@property (weak, nonatomic) SKKeyboardItem *systemKeyboard;
@property (weak, nonatomic) SKKeyboardItem *mediaKeyboard;

@property (assign, nonatomic) SKSystemKeyboardStyle systemKeyboardStyle;

@property (assign, nonatomic) SKAudioRecordSessionState audioRecordSessionState;

@property (copy, nonatomic) void (^systemKeyboardOffBlock)();

@property (strong, nonatomic) XHVoiceRecordHUD *voiceRecordHUD;

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

- (XHVoiceRecordHUD *)voiceRecordHUD
{
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [XHVoiceRecordHUD instance];
    }
    return _voiceRecordHUD;
}

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
    
    self.keyboardDelegate = self;
    self.contentView.textView.delegate = self;
    
    self.systemKeyboardStyle = SKSystemKeyboardStyleDefault;
    
    [self setupKeyboardItems];
    [self setupActionHandlersForVoiceRecordStarterButton];
    [self setupActionHandlersForSystemKeyboardTrigger];
    [self setupActionHandlersForMediaKeyboardTriggerButton];
    [self turnOffOtherKeyboardItemsWithSender:nil completion:nil];
}

- (void)dealloc
{
    _contentView = nil;
}

#pragma mark - Keyboard Items

- (void)setupKeyboardItems
{
    __weak SKMessagesInputToolbar *weakSelf = self;
    
    // audio record trigger button
    SKKeyboardItem *audioRecordKeyboard = [[SKKeyboardItem alloc] initWithIdentifier:@"audioRecordKeyboard" onBlock:^{
        [weakSelf setAudioRecordSessionState:SKAudioRecordSessionStateReady];
    } offBlock:^(SKKeyboardItem *sender, void (^completionBlock)()) {
        [weakSelf setAudioRecordSessionState:SKAudioRecordSessionStateOff];
        if (completionBlock) completionBlock();
    } keyboardManager:self];
    [self.keyboardItems addObject:audioRecordKeyboard];
    _voiceRecordKeyboard = audioRecordKeyboard;
    
    SKKeyboardItem *systemKeyboard = [[SKKeyboardItem alloc] initWithIdentifier:@"systemKeyboard" onBlock:^{
        if (![weakSelf.textView isFirstResponder]) {
            [weakSelf.textView becomeFirstResponder];
        } else {
            [weakSelf configButtonsWithSystemState:YES];
        }
    } offBlock:^(SKKeyboardItem *sender, void (^completionBlock)()) {
        if ([weakSelf.textView isFirstResponder]) {
            self.systemKeyboardOffBlock = completionBlock;
            [weakSelf.textView resignFirstResponder];
        } else {
            [weakSelf configButtonsWithSystemState:NO];
            if (completionBlock) completionBlock();
        }
    } keyboardManager:self];
    [self.keyboardItems addObject:systemKeyboard];
    _systemKeyboard = systemKeyboard;
    
    SKKeyboardItem *mediaKeyboard = [[SKKeyboardItem alloc] initWithIdentifier:@"mediaKeyboard" onBlock:^{
        [weakSelf turnMediaKeyboardEnterState:YES sender:nil];
    } offBlock:^(SKKeyboardItem *sender, void (^completionBlock)()) {
        [weakSelf turnMediaKeyboardEnterState:NO sender:sender];
        if (completionBlock) completionBlock();
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
    
    [self.contentView.voiceRecordTriggerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.voiceRecordTriggerButton addTarget:self.voiceRecordKeyboard action:@selector(triggered) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDown];
    [self.contentView.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.contentView.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDragExit];
    [self.contentView.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchDragExist) forControlEvents:UIControlEventTouchDragExit];
    [self.contentView.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDragEnter];
    [self.contentView.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [self.contentView.voiceRecordStarterButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpOutside];
    [self.contentView.voiceRecordStarterButton addTarget:self action:@selector(voiceRecordStarterButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
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
        self.audioRecordSessionState = SKAudioRecordSessionStatePaused;
    }
}

- (void)voiceRecordStarterButtonTouchDragEnter
{
    if (SKAudioRecordSessionStatePaused == self.audioRecordSessionState) {
        self.audioRecordSessionState = SKAudioRecordSessionStateRecording;
    }
}

- (void)voiceRecordStarterButtonTouchUpOutside
{
    if (SKAudioRecordSessionStatePaused == self.audioRecordSessionState) {
        self.audioRecordSessionState = SKAudioRecordSessionStateCanceled;
    }
}

- (void)setAudioRecordSessionState:(SKAudioRecordSessionState)state
{
    _audioRecordSessionState = state;
    
    __weak SKMessagesInputToolbar *weakSelf = self;
    
    switch (state) {
        case SKAudioRecordSessionStateOff: {
            // show voice trigger button
            // hide voice record starter button
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:YES];
            [self setTextViewVisible:YES];
            [self.voiceRecordHUD dismissCompleted:nil];
        } break;
        case SKAudioRecordSessionStateReady: {
            // hide voice trigger button
            // show voice record starter button
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            [self setTextViewVisible:NO];
            [self.voiceRecordHUD dismissCompleted:nil];
        } break;
        case SKAudioRecordSessionStateRecording: {
            // hide voice trigger button
            // voice record button visible and pressed
            // show recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            [self setTextViewVisible:NO];
            [self.voiceRecordHUD startRecordingHUDAtView:self.contextView];
            
            // resume recording audio
            [self.delegate resumeRecordingAudioWithVoiceVolumn:^(CGFloat peakPower) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.voiceRecordHUD.peakPower = peakPower;
                });
            } errorHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.audioRecordSessionState = SKAudioRecordSessionStateError;
                });
            }];
        } break;
        case SKAudioRecordSessionStatePaused: {
            // hide voice trigger button
            // voice record button visible and pressed
            // hide recording HUD
            // show canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            [self setTextViewVisible:NO];
            [self.voiceRecordHUD didCanceling];
            
            // pause recording audio
            [self.delegate pauseRecordingAudio];
        } break;
        case SKAudioRecordSessionStateCanceled: {
            // hide trigger button
            // voice record button visible
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            [self setTextViewVisible:NO];
            [self.voiceRecordHUD dismissCompleted:nil];
            
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
            [self setTextViewVisible:NO];
            [self.voiceRecordHUD dismissCompleted:nil];
            
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
            [self setTextViewVisible:NO];
            [self.voiceRecordHUD showError];
            
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
        normalImage = [UIImage imageNamed:@"keyborad"];
        highlightedImage = [UIImage imageNamed:@"keyborad_HL"];
    }
    
    [self.contentView.voiceRecordTriggerButton setImage:normalImage forState:UIControlStateNormal];
    [self.contentView.voiceRecordTriggerButton setImage:highlightedImage forState:UIControlStateHighlighted];
}

- (void)setTextViewVisible:(BOOL)visible
{
    self.contentView.textView.hidden = !visible;
    self.contentView.voiceRecordStarterButton.hidden = visible;
}

#pragma mark - Media keyboard

- (void)setupActionHandlersForMediaKeyboardTriggerButton
{
    // [off] - mediaKeyboardTriggerButton TOUCH UP INSIDE -> [on]
    // [on] - any trigger button TOUCH UP INSIDE -> [off]
    
    [self.contentView.mediaTriggerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.mediaTriggerButton addTarget:self.mediaKeyboard action:@selector(triggered) forControlEvents:UIControlEventTouchUpInside];
}

- (void)turnMediaKeyboardEnterState:(BOOL)on sender:(SKKeyboardItem *)sender
{
    if (on) {
        // hide mediaKeyboardTriggerButton
        // show media keyboard
        
        self.contentView.mediaTriggerButton.hidden = NO;
        self.contentView.sendButton.hidden = YES;
        [self.delegate showMediaKeyboardViewWithCompeltion:^(CGFloat keyboardHeight) {
            keyboardHeight = MAX(0, keyboardHeight);
            [self jsq_setToolbarBottomLayoutGuideConstant:keyboardHeight];
        }];
    } else {  // off
        // show mediaKeyboardTriggerButton
        // hide mediaKeyboard
        
        [self.delegate hideMediaKeyboardView];
        
        // when system keyboard trigger media keyboard hidden,
        // it means keyboard already visible, so don't adjust toolbar bottom constraint.
        if (![sender isEqual:self.systemKeyboard]) {
            [self jsq_setToolbarBottomLayoutGuideConstant:0.0f];
            self.contentView.mediaTriggerButton.hidden = NO;
        }
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
    
    [self.contentView.emoticonTriggerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.emoticonTriggerButton addTarget:self action:@selector(emoticonTriggerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.sendButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sendButtonPressed:(UIButton *)sender
{
    [self.delegate sendButtonDidPressed:self.contentView.textView];
}

- (void)emoticonTriggerButtonPressed:(UIButton *)sender
{
    if ([self.textView isFirstResponder]) {  // emoticon button act as a switch button
        [self switchSystemKeyboardStyle];
    } else {  // only when system keyboard off, emoticon button act as a trigger button
        self.systemKeyboardStyle = SKSystemKeyboardStyleEmoticon;
        [self reloadSystemKeyboard:[self.delegate emoticonKeyboardView]];
        [self.textView becomeFirstResponder];
    }
}

- (void)switchSystemKeyboardStyle
{
    SKSystemKeyboardStyle style = SKSystemKeyboardStyleDefault;
    UIView *keyboardView = nil;
    
    switch (self.systemKeyboardStyle) {
        case SKSystemKeyboardStyleDefault: {
            style = SKSystemKeyboardStyleEmoticon;
            keyboardView = [self.delegate emoticonKeyboardView];
        } break;
        case SKSystemKeyboardStyleEmoticon: {
            style = SKSystemKeyboardStyleDefault;
        } break;
        default:
            break;
    }
    
    self.systemKeyboardStyle = style;
    [self reloadSystemKeyboard:keyboardView];
}

- (void)reloadSystemKeyboard:(UIView *)keyboard
{
    if (![self.textView.inputView isEqual:keyboard]) {
        self.textView.inputView = keyboard;
        [self.textView reloadInputViews];
    } else {
        [self configButtonsWithSystemState:YES];
    }
}

- (void)configButtonsWithSystemState:(BOOL)on
{
    if (on) {  // on
        switch (self.systemKeyboardStyle) {
            case SKSystemKeyboardStyleDefault: {
                // show default style keyboard
                // show send button
                // show emoticon trigger button
                // text view become first responder
                
                [self toggleSendButtonEnabled];
                [self.contentView.emoticonTriggerButton setImage:[UIImage imageNamed:@"smiling-face"] forState:UIControlStateNormal];
                
            } break;
            case SKSystemKeyboardStyleEmoticon: {
                // show emoticon keyboard
                // show send button
                // hide emoticon trigger button
                // text view become first responder
                [self toggleSendButtonEnabled];
                [self.contentView.emoticonTriggerButton setImage:[UIImage imageNamed:@"laughing-face"] forState:UIControlStateNormal];
                
            } break;
            default: break;
        }
    } else {  // off
        self.contentView.mediaTriggerButton.hidden = NO;
        self.contentView.sendButton.hidden = YES;
        [self.contentView.emoticonTriggerButton setImage:[UIImage imageNamed:@"smiling-face"] forState:UIControlStateNormal];
    }
}

- (void)toggleSendButtonEnabled
{
    BOOL hasText = [self.textView hasText];
    self.contentView.sendButton.hidden = !hasText;
    self.contentView.mediaTriggerButton.hidden = hasText;
}

#pragma mark - Keyboard Delegate

- (void)keyboardDidChangeFrame:(CGRect)keyboardFrame
{
    
}

- (void)keyboardDidShow
{
    // turn off other keyboards
    [self turnOffOtherKeyboardItemsWithSender:self.systemKeyboard completion:nil];
    [self configButtonsWithSystemState:YES];
}

- (void)keyboardDidHide
{
    UITextView *textView = self.textView;
    textView.inputView = nil;
    self.systemKeyboardStyle = SKSystemKeyboardStyleDefault;
    [self configButtonsWithSystemState:NO];
    
    if (self.systemKeyboardOffBlock) {
        self.systemKeyboardOffBlock();
        self.systemKeyboardOffBlock = nil;
    }
}

#pragma mark - SKKeyboardManager

- (void)turnOffOtherKeyboardItemsWithSender:(SKKeyboardItem *)sender completion:(void (^)())completionBlock
{
    [self recursiveTurnOffKeyboardItems:self.keyboardItems sender:sender completion:completionBlock];
}

- (void)recursiveTurnOffKeyboardItems:(NSArray *)keyboardItems sender:(SKKeyboardItem *)sender completion:(void (^)())completionBlock
{
    __weak SKMessagesInputToolbar *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger count = [keyboardItems count];
        if (count) {
            SKKeyboardItem *keyboardItem = [keyboardItems firstObject];
            if ([keyboardItem isEqual:sender]) {
                [weakSelf recursiveTurnOffKeyboardItems:[keyboardItems subarrayWithRange:NSMakeRange(1, count - 1)] sender:sender completion:completionBlock];
            } else {
                [keyboardItem turnOffByOtherKeyboard:sender completion:^{
                    [weakSelf recursiveTurnOffKeyboardItems:[keyboardItems subarrayWithRange:NSMakeRange(1, count - 1)] sender:sender completion:completionBlock];
                }];
            }
        } else {
            if (completionBlock) completionBlock();
        }
    });
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView != self.textView) {
        return;
    }
    
    //    if (![textView isFirstResponder]) [textView becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView != self.textView) {
        return;
    }
    
    [self toggleSendButtonEnabled];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView != self.textView) {
        return NO;
    }
    
    [self toggleSendButtonEnabled];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView != self.textView) {
        return;
    }
    
    //    if ([textView isFirstResponder]) [textView resignFirstResponder];
}

@end
