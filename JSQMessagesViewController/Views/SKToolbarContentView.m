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

@interface SKToolbarContentView () <SKKeyboardManager>

@property (weak, nonatomic) IBOutlet UIButton *voiceRecordTriggerButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceRecordStarterButton;

@property (weak, nonatomic) IBOutlet UIButton *emoticonTriggerButton;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *mediaTriggerButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) NSMutableArray *keyboardItems;
@property (weak, nonatomic) SKKeyboardItem *voiceRecordKeyboard;
@property (weak, nonatomic) SKKeyboardItem *systemKeyboard;
@property (weak, nonatomic) SKKeyboardItem *mediaKeyboard;

@property (assign, nonatomic) SKSystemKeyboardStyle systemKeyboardStyle;

@property (assign, nonatomic) SKAudioRecordSessionState audioRecordSessionState;
@end

@implementation SKToolbarContentView

#pragma mark - Getters

- (NSMutableArray *)keyboardItems
{
    if (!_keyboardItems) {
        _keyboardItems = [[NSMutableArray alloc] init];
    }
    return _keyboardItems;
}

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
    
    [self setupKeyboardItems];
    [self setupActionHandlersForVoiceRecordStarterButton];
    [self setupActionHandlersForSystemKeyboardTrigger];
    [self setupActionHandlersForMediaKeyboardTriggerButton];
    [self turnOffOtherKeyboardItemsWithSender:nil];
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

#pragma mark - UIView overrides

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.textView setNeedsDisplay];
}

#pragma mark - Keyboard Items

- (void)setupKeyboardItems
{
    __weak SKToolbarContentView *weakSelf = self;
    
    // audio record trigger button
    SKKeyboardItem *audioRecordKeyboard = [[SKKeyboardItem alloc] initWithIdentifier:@"audioRecordKeyboard" onBlock:^{
        [weakSelf setAudioRecordSessionState:SKAudioRecordSessionStateReady];
    } offBlock:^(SKKeyboardItem *sender) {
        [weakSelf setAudioRecordSessionState:SKAudioRecordSessionStateOff];
    } keyboardManager:self];
    [self.keyboardItems addObject:audioRecordKeyboard];
    _voiceRecordKeyboard = audioRecordKeyboard;
    
    SKKeyboardItem *systemKeyboard = [[SKKeyboardItem alloc] initWithIdentifier:@"systemKeyboard" onBlock:^{
        if (![weakSelf.textView isFirstResponder]) {
            [weakSelf.textView becomeFirstResponder];
        }
    } offBlock:^(SKKeyboardItem *sender) {
        if ([weakSelf.textView isFirstResponder]) {
            [weakSelf.textView resignFirstResponder];
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
    __weak SKToolbarContentView *weakSelf = self;
    
    switch (state) {
        case SKAudioRecordSessionStateOff: {
            // show voice trigger button
            // hide voice record starter button
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:YES];
            [self setTextViewVisible:YES];
            [[XHVoiceRecordHUD sharedInstance] dismissCompleted:nil];
        } break;
        case SKAudioRecordSessionStateReady: {
            // hide voice trigger button
            // show voice record starter button
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            [self setTextViewVisible:NO];
            [[XHVoiceRecordHUD sharedInstance] dismissCompleted:nil];
        } break;
        case SKAudioRecordSessionStateRecording: {
            // hide voice trigger button
            // voice record button visible and pressed
            // show recording HUD
            // hide canceling HUD
            // hide error HUD
            
            [self setVoiceRecordTriggerButtonVisible:NO];
            [self setTextViewVisible:NO];
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
            [self setTextViewVisible:NO];
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
            [self setTextViewVisible:NO];
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
            [self setTextViewVisible:NO];
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
            [self setTextViewVisible:NO];
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

- (void)setTextViewVisible:(BOOL)visible
{
    self.textView.hidden = !visible;
    self.voiceRecordStarterButton.hidden = visible;
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
        
        [self setSendButtonVisible:NO];
        [self.delegate showMediaKeyboardView];
    } else {  // off
        // show mediaKeyboardTriggerButton
        // hide mediaKeyboard
        
        self.mediaTriggerButton.hidden = NO;
        [self.delegate hideMediaKeyboardView];
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
    [self.sendButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sendButtonPressed:(UIButton *)sender
{
    [self.delegate sendButtonDidPressed];
}

- (void)emoticonTriggerButtonPressed:(UIButton *)sender
{
    if ([self.textView isFirstResponder]) {  // emoticon button act as a switch button
        [self switchSystemKeyboardStyle];
        [self keyboardWasShown:nil];
    } else {  // only when system keyboard off, emoticon button act as a trigger button
        self.systemKeyboardStyle = SKSystemKeyboardStyleEmoticon;
        [self.textView becomeFirstResponder];
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
            UITextView *textView = self.textView;
            if (nil != textView.inputView) {
                textView.inputView = nil;
                [textView reloadInputViews];
            }
            [self setSendButtonVisible:YES];
            [self.emoticonTriggerButton setImage:[UIImage imageNamed:@"smiling-face"] forState:UIControlStateNormal];
            
        } break;
        case SKSystemKeyboardStyleEmoticon: {
            // show emoticon keyboard
            // show send button
            // hide emoticon trigger button
            // text view become first responder
            UITextView *textView = self.textView;
            UIView *keyboardView = [self.delegate emoticonKeyboardView];
            if (![keyboardView isEqual:self.inputView]) {
                textView.inputView = keyboardView;
                [textView reloadInputViews];
            }
            [self setSendButtonVisible:YES];
            [self.emoticonTriggerButton setImage:[UIImage imageNamed:@"laughing-face"] forState:UIControlStateNormal];
            
        } break;
        default: break;
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.systemKeyboard.on = NO;
    UITextView *textView = self.textView;
    textView.inputView = nil;
    [self setSendButtonVisible:NO];
    self.systemKeyboardStyle = SKSystemKeyboardStyleDefault;
    [self.emoticonTriggerButton setImage:[UIImage imageNamed:@"smiling-face"] forState:UIControlStateNormal];
}

- (void)setSendButtonVisible:(BOOL)visible
{
    self.sendButton.hidden = !visible;
    self.mediaTriggerButton.hidden = visible;
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
