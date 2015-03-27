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

CGFloat const kSKMessagesInputToolbarHeightDefault = 44.0f;

static void * kJSQMessagesInputToolbarKeyValueObservingContext = &kJSQMessagesInputToolbarKeyValueObservingContext;

@interface SKMessagesInputToolbar ()

@property (assign, nonatomic) BOOL jsq_isObserving;

@property (weak, nonatomic) UIButton *voiceRecordStarterButton;

@end

@implementation SKMessagesInputToolbar

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
    
    self.contentView.leftBarButtonItem = [JSQMessagesToolbarButtonFactory voiceRecordTriggerButton];
    self.contentView.rightBarButtonItem = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
    
    UIButton *voiceRecordStarterButton = [JSQMessagesToolbarButtonFactory voiceRecordStarterButton];
    [self.contentView addSubview:voiceRecordStarterButton];
    JSQMessagesComposerTextView *textView = self.contentView.textView;
    [voiceRecordStarterButton jsq_pinSubview:textView toEdge:NSLayoutAttributeTop];
    [voiceRecordStarterButton jsq_pinSubview:textView toEdge:NSLayoutAttributeLeft];
    [voiceRecordStarterButton jsq_pinSubview:textView toEdge:NSLayoutAttributeBottom];
    [voiceRecordStarterButton jsq_pinSubview:textView toEdge:NSLayoutAttributeRight];
    voiceRecordStarterButton.hidden = YES;
    self.voiceRecordStarterButton = voiceRecordStarterButton;
    
    
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
}

- (void)audioRecordSessionEnterState:(SKAudioRecordSessionState)state
{
    switch (state) {
        case SKAudioRecordSessionStateOff: {
            // show voice trigger button
            // hide voice record starter button
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
        } break;
        case SKAudioRecordSessionStateReady: {
            // hide voice trigger button
            // show voice record starter button
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
        } break;
        case SKAudioRecordSessionStateRecording: {
            // hide voice trigger button
            // voice record button visible and pressed
            // show recording HUD
            // hide canceling HUD
            // hide error HUD
            
            // start recording audio
        } break;
        case SKAudioRecordSessionStateCanceling: {
            // hide voice trigger button
            // voice record button visible and pressed
            // hide recording HUD
            // show canceling HUD
            // hide error HUD
            
            // continue recording audio
        } break;
        case SKAudioRecordSessionStateCanceled: {
            // hide trigger button
            // voice record button visible
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            // stop recording audio
            // discard recorded data
            // transation to SKAudioRecordSessionStateReady
        } break;
        case SKAudioRecordSessionStateCompleted: {
            // hide trigger button
            // voice record button visible
            // hide recording HUD
            // hide canceling HUD
            // hide error HUD
            
            // stop recording audio
            // trigger sending audio message
            // transation to SKAudioRecordSessionStateReady state
        } break;
        case SKAudioRecordSessionStateError: {
            // hide trigger button
            // voice record button visible and pressed
            // hide recording HUD
            // hide canceling HUD
            // show error HUD
            
            // stop recording audio
            // discard recorded data
            // transation to SKAudioRecordSessionStateReady state
        } break;
        default:
            break;
    }
}

- (void)setupActionHandlersForEmoticonKeyboardTriggerButton
{
    // [off] - emoticonKeyboardTriggerButton TOUCH UP INSIDE -> [on]
    // [on] - any trigger button except voiceRecordStarterButton -> [off]
}

- (void)turnEmoticonKeyboardState:(BOOL)on sender:(id)otherKeyboard
{
    if (on) {
        // hide emoticonKeyboardTriggerButton
        // show emoticon keyboard
        // show send button
    } else {  // off
        // show emoticonKeyboardTriggerButton
        // hide emoticon keyboard
        // hide send button
    }
}

- (void)setupActionHandlersForMediaKeyboardTriggerButton
{
    // [off] - mediaKeyboardTriggerButton TOUCH UP INSIDE -> [on]
    // [on] - any trigger button TOUCH UP INSIDE -> [off]
}

- (void)mediaKeyboardEnterState:(BOOL)on
{
    if (on) {
        // hide mediaKeyboardTriggerButton
        // show media keyboard
    } else {  // off
        // show mediaKeyboardTriggerButton
        // hide mediaKeyboard
    }
}

- (void)setupActionHandlersForSystemKeyboardTrigger
{
    // [off] - text view became first responder -> [on]
    // [on] - any trigger button pressed, or pin keybord to resign first responder -> [off]
}

- (void)systemKeyboardEnterState:(BOOL)on
{
    if (on) {
        // show system keyboard
        // show send button
    } else {  // off
        // hide system keyboard
        // hide send button
    }
}

- (void)turnRedioStyleKeyboard:(id)keyboard on:(BOOL)on
{
    if (on) {
        // turn off other keyboards, given the turned on one.
        // turn on keyboard
    } else {
        // turn off keyboard
    }
}

@end
